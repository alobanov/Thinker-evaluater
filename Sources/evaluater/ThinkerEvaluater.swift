//
//  Thinker.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public enum AvailableType: Equatable {
  case bool(Bool), str(String), double(Double)
  
  var boolValue: Bool? {
    if case let .bool(val) = self {
      return val
    } else {
      return nil
    }
  }
  
  var strValue: String? {
    if case let .str(val) = self {
      return val
    } else {
      return nil
    }
  }
  
  var doubleValue: Double? {
    if case let .double(val) = self {
      return val
    } else {
      return nil
    }
  }
}

public enum ConditionOperatorType {
  case equal, greaterOrEqual, lessOrEqual, greaterThan, lessThan, notEqual
}

public enum LogicOperatorType: String {
  case and, or, empty, dummy, finish
  
  var operatorValue: String {
    switch self {
    case .and:
      return "&&"
    case .or:
      return "||"
    case .empty:
      return ""
    case .dummy, .finish:
      return ""
    }
  }
}

public enum NextType {
  case next, empty
}

public enum InteratorType {
  case endOfExpression(Bool), haveNext(Bool, LogicOperatorType)
}

typealias LogicValue = (Bool, LogicOperatorType)

public struct ThinkerEvaluater {
  // MARK: - Primitive parsers
  
  // Condition operator parser (11 == 34)
  public let conditionOperator = Parser.oneOf(
    Parser.prefix("==").map { ConditionOperatorType.equal },
    Parser.prefix(">=").map { .greaterOrEqual },
    Parser.prefix("<=").map { .lessOrEqual },
    Parser.prefix(">").map { .greaterThan },
    Parser.prefix("<").map { .lessThan },
    Parser.prefix("!=").map { .notEqual }
  )

  // Logic operator parser (true && false || false)
  public let logicOperatr = Parser.oneOf(
    Parser.prefix("&&").map { LogicOperatorType.and },
    Parser.prefix("||").map { .or },
    Parser.prefix("").map { .empty }
  )
  
  public let emptyCharsParser = Parser.oneOf(
    Parser.prefix(" ").map { NextType.next },
    Parser.prefix("").map { .empty }
  )

  // MARK: - Composites
  
  public func test(_ input: String) -> Bool? {
    let conditionParser = zip(
      emptyCharsParser,
      conditionOperator,
      emptyCharsParser
    ).flatMap { val -> Parser<ConditionOperatorType> in
      return Parser.always(val.1)
    }
    
    let expressionCondition = zip(
      Parser.universal,
      conditionParser,
      Parser.universal
    ).map { lhs, condition, rhs -> Bool in
      switch lhs {
      case let .bool(lhsValue):
        return compareBool(l: lhsValue, r: rhs.boolValue, op: condition)
      
      case let .double(lhsValue):
        return compareDouble(l: lhsValue, r: rhs.doubleValue, op: condition)
        
      case let .str(lhsValue):
        return compareString(l: lhsValue, r: rhs.strValue, op: condition)
      }
    }
    
    let res = expressionCondition.run(input)
    print("\n\n RESULT:", res, "\n\n")
    
    return res.match
  }
  
  public func evalOper(_ input: String) -> Bool? {
    let conditionParser = zip(
      emptyCharsParser,
      conditionOperator,
      emptyCharsParser
    ).flatMap { val -> Parser<ConditionOperatorType> in
      return Parser.always(val.1)
    }
    
    let logicParser = zip(
      emptyCharsParser,
      logicOperatr,
      emptyCharsParser
    ).flatMap { val -> Parser<LogicOperatorType> in
      return Parser.always(val.1)
    }
    
    let expressionCondition = zip(
      .int,
      conditionParser,
      .int
    ).map { lhs, condition, rhs -> Bool in
      switch condition {
      case .equal:
        return lhs == rhs
      case .greaterOrEqual:
        return lhs >= rhs
      case .lessOrEqual:
        return lhs <= rhs
      case .greaterThan:
        return lhs > rhs
      case .lessThan:
        return lhs < rhs
      case .notEqual:
        return lhs != rhs
      }
    }
    
    let compositeExpression = zip(expressionCondition, logicParser)
      .map { res, con -> InteratorType in
        switch con {
        case .empty:
          return .endOfExpression(res)
        default:
          return .haveNext(res, con)
        }
      }
    
    let parser = compositeExpression
      .zeroOrMore()
      .map {
        $0.reduce(LogicValue(false, .dummy)) { (current, value) in
          print("Exampla", current, value)
          
          switch value {
          case let .endOfExpression(result):
            
            switch current.1 {
            case .and:
              let newResult = current.0 && result
              print("Final composite logic:", current.0, "AND", result, "->", newResult)
              return (newResult, .finish)
            case .or:
              let newResult = current.0 || result
              print("Final composite logic:", current.0, "OR", result, "->", newResult)
              return (newResult, .finish)
              
            case .empty, .dummy, .finish:
              return (current.0, current.1)
            }
                    
          case let .haveNext(result, logicOperator):
            
            if current.1 == .dummy {
              return (result, logicOperator)
              
            } else {
                
              switch current.1 {
              case .and:
                let newResult = current.0 && result
                print("Composite logic:", current.0, "AND", result, "->", newResult)
                return (newResult, logicOperator)
              case .or:
                let newResult = current.0 || result
                print("Composite logic:", current.0, "OR", result, "->", newResult)
                return (newResult, logicOperator)
                
              case .empty, .dummy, .finish:
                return (current.0, current.1)
              }
              
            }
          }
        }
      }
    
    return parser.run(input).match?.0
  }
  
  public func prepare() {
    let conditionParser = zip(
      emptyCharsParser,
      conditionOperator,
      emptyCharsParser
    ).flatMap { val -> Parser<ConditionOperatorType> in
      return Parser.always(val.1)
    }
    
    let logicParser = zip(
      emptyCharsParser,
      logicOperatr,
      emptyCharsParser
    ).flatMap { val -> Parser<LogicOperatorType> in
      return Parser.always(val.1)
    }
    
    let expressionCondition = zip(
      .int,
      conditionParser,
      .int
    ).map { lhs, condition, rhs -> Bool in
      switch condition {
      case .equal:
        return lhs == rhs
      case .greaterOrEqual:
        return lhs >= rhs
      case .lessOrEqual:
        return lhs <= rhs
      case .greaterThan:
        return lhs > rhs
      case .lessThan:
        return lhs < rhs
      case .notEqual:
        return lhs != rhs
      }
    }
    
    let compositeExpression = zip(expressionCondition, logicParser)
      .map { res, con -> InteratorType in
        switch con {
        case .empty:
          return .endOfExpression(res)
        default:
          return .haveNext(res, con)
        }
      }
    
    let parser = compositeExpression
      .zeroOrMore()
      .map {
        $0.reduce("") { (current, value) in
          switch value {
          case let .endOfExpression(result):
            return current + "\(result)"
          case let .haveNext(result, logicOperator):
            return current + "\(result) \(logicOperator.operatorValue) "
          }
        }
      }
    
    let compositeLogic = zip(.bool, logicParser, .bool)
      .map { lhs, logic, rhs -> Bool in
        switch logic {
        case .and:
          return lhs && rhs
        case .or:
          return lhs || rhs
        case .empty, .dummy, .finish:
          return false
        }
      }

    print(parser.run("12 == -32 || 34 > 12 && 11 == 2"))
    print(compositeLogic.run("true || false && true"))
  }
}

//dump(
//  parser.run("12 == -32 || 34 > 12 && 11 == 2")
//)

//dump(
//  compositeLogic.run("true || false && true")
//)
