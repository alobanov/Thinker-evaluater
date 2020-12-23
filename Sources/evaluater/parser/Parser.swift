import Foundation

// (String) -> A?
// (String) -> (match: A?, rest: String)
// (inout String) -> A?
// (inout Substring) -> A?
public struct Parser<Input, Output> {
  public let run: (inout Input) -> Output?
}

extension Parser: ExpressibleByUnicodeScalarLiteral where Input == Substring, Output == Void {
  public typealias UnicodeScalarLiteralType = StringLiteralType
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Input == Substring, Output == Void {
  public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
}

extension Parser: ExpressibleByStringLiteral where Input == Substring, Output == Void {
  public typealias StringLiteralType = String
  
  public init(stringLiteral value: String) {
    self = .prefix(value[...])
  }
}

public extension Parser {
  typealias EvaluateResult = (match: Output?, rest: Input)
  
  func run(_ input: Input) -> EvaluateResult {
    var input = input
    let match = self.run(&input)
    return (match, input)
  }
}

public extension Parser {
  func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<Input, NewOutput> {
    .init { input in
      self.run(&input).map(f)
    }
  }
}

public extension Parser {
  func flatMap<NewOutput>(
    _ f: @escaping (Output) -> Parser<Input, NewOutput>
  ) -> Parser<Input, NewOutput> {
    .init { input in
      let original = input
      let output = self.run(&input)
      let newParser = output.map(f)
      guard let newOutput = newParser?.run(&input) else {
        input = original
        return nil
      }
      return newOutput
    }
  }
}

public extension Parser {
  static func always(_ output: Output) -> Self {
    Self { _ in output }
  }
  
  static var never: Self {
    Self { _ in nil }
  }
}

public extension Parser {
  static func oneOf(_ ps: [Self]) -> Self {
    .init { input in
      for p in ps {
        if let match = p.run(&input) {
          return match
        }
      }
      return nil
    }
  }
  
  static func oneOf(_ ps: Self...) -> Self {
    self.oneOf(ps)
  }
}

public extension Parser {
  func zeroOrMore(
    separatedBy separator: Parser<Input, Void> = .always(())
  ) -> Parser<Input, [Output]> {
    Parser<Input, [Output]> { input in
      var rest = input
      var matches: [Output] = []
      
      while let match = self.run(&input) {
        rest = input
        matches.append(match)
        
        if separator.run(&input) == nil {
          return matches
        }
        
//        if input {
//          return matches
//        }
      }
      input = rest
      return matches
    }
  }
}

public extension Parser
where Input: Collection,
      Output == Void,
      Input.Element: Equatable,
      Input.SubSequence == Input
{
  static func prefix(_ p: Input.SubSequence) -> Self {
    Self { input in
      guard input.starts(with: p)
      else { return nil }
      input.removeFirst(p.count)
      return ()
    }
  }
}

public extension Parser where Input == Substring, Output == Substring {
  static func prefix(while p: @escaping (Character) -> Bool) -> Self {
    Self { input in
      let output = input.prefix(while: p)
      input.removeFirst(output.count)
      return output
    }
  }
  
  static func prefix(upTo substring: Substring) -> Self {
    Self { input in
      guard let endIndex = input.range(of: substring)?.lowerBound
      else { return nil }
      
      let match = input[..<endIndex]
      input = input[endIndex...]
      return match
    }
  }
  
  static func prefix(through substring: Substring) -> Self {
    Self { input in
      guard let endIndex = input.range(of: substring)?.upperBound
      else { return nil }
      
      let match = input[..<endIndex]
      input = input[endIndex...]
      return match
    }
  }
}

// MARK: - Fluently Zipping Parsers

extension Parser {
  public func take<NewOutput>(_ p: Parser<Input, NewOutput>) -> Parser<Input, (Output, NewOutput)> {
    zip(self, p)
  }
  
  public func take<A, B, C>(_ p: Parser<Input, C>) -> Parser<Input, (A, B, C)> where Output == (A, B) {
    zip(self, p).map { ab, c in (ab.0, ab.1, c) }
  }
    
  public func skip<B>(_ p: Parser<Input, B>) -> Self {
    zip(self, p).map { a, _ in a }
  }
  
  public static func skip(_ p: Self) -> Parser<Input, Void> {
    p.map { _ in () }
  }
}

extension Parser where Output == Void {
  func take<A>(_ p: Parser<Input, A>) -> Parser <Input, A> {
    zip(self, p).map { _, a in a }
  }
}

// MARK: - ZIP

public func zip<Input, Output1, Output2>(
  _ p1: Parser<Input, Output1>,
  _ p2: Parser<Input, Output2>
) -> Parser<Input, (Output1, Output2)> {
  .init { input -> (Output1, Output2)? in
    let original = input
    guard let output1 = p1.run(&input) else {
      return nil
    }
    
    guard let output2 = p2.run(&input) else {
      input = original
      return nil
    }
    return (output1, output2)
  }
}

//public func zip<Output1, Output2, Output3>(
//  _ p1: Parser<Output1>,
//  _ p2: Parser<Output2>,
//  _ p3: Parser<Output3>
//) -> Parser<(Output1, Output2, Output3)> {
//  zip(p1, zip(p2, p3))
//    .map { output1, output23 in (output1, output23.0, output23.1) }
//}

// let locationName = Parser.prefix(while: { $0 != "," })
//public func zip<A, B, C, D>(
//  _ a: Parser<A>,
//  _ b: Parser<B>,
//  _ c: Parser<C>,
//  _ d: Parser<D>
//) -> Parser<(A, B, C, D)> {
//  zip(a, zip(b, c, d))
//    .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
//}
//
//public func zip<A, B, C, D, E>(
//  _ a: Parser<A>,
//  _ b: Parser<B>,
//  _ c: Parser<C>,
//  _ d: Parser<D>,
//  _ e: Parser<E>
//) -> Parser<(A, B, C, D, E)> {
//  zip(a, zip(b, c, d, e))
//    .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
//}

public extension Parser where Input == [String: String] {
  static func key(_ key: String, _ parser: Parser<Substring, Output>) -> Self {
    Self { dict in
      guard var value = dict[key]?[...]
      else { return nil }
      
      guard let output = parser.run(&value)
      else { return nil }
      
      dict[key] = value.isEmpty ? nil : String(value)
      return output
    }
  }
}
