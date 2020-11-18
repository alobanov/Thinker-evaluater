//
//  Thinker.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public struct ThinkerEvaluater {
  public typealias Result = (result: Bool?, rest: Substring)
  
  // MARK: - Primitive parsers
  
  // Comparison operator parser (11 == 34)
  public static let comparisonOperator = Parser.oneOf(
    Parser.prefix("==").map { ComparisonType.equal },
    Parser.prefix(">=").map { .greaterOrEqual },
    Parser.prefix("<=").map { .lessOrEqual },
    Parser.prefix(">").map { .greaterThan },
    Parser.prefix("<").map { .lessThan },
    Parser.prefix("!=").map { .notEqual }
  )

  // Logic operator parser (true && false || false)
  public static let logicOperatr = Parser.oneOf(
    Parser.prefix("&&").map { LogicType.and },
    Parser.prefix("||").map { .or },
    Parser.prefix("OR").map { .or },
    Parser.prefix("AND").map { .and },
    Parser.prefix("").map { .empty }
  )
  
  public static let whitespaceParser = Parser.oneOf(
    Parser.prefix(" ").map { EmptyCharType.whitespace },
    Parser.prefix("").map { .empty }
  )
  
  // MARK: - Composite parsers
  
  // Parser for "<whitespace><comparison><whitespace>" && "
  public let logicParser = zip(whitespaceParser, logicOperatr, whitespaceParser)
    .flatMap { val -> Parser<LogicType> in
      return Parser.always(val.1)
    }
  
  // Parser for "<whitespace><comparison><whitespace>" = " >= "
  public let comparisonSentenceParser = zip(Self.whitespaceParser, Self.comparisonOperator, Self.whitespaceParser)
    .flatMap { Parser.always($0.1) }
}
