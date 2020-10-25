//
//  Thinker.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public enum ConditionOperatorType {
  case equal, greaterOrEqual, lessOrEqual, greaterThan, lessThan
}

public enum LogicOperatorType {
  case and, or, empty
}

public enum NextType {
  case next, empty
}

public enum InteratorType {
  case endOfExpression(Bool), haveNext(Bool, LogicOperatorType)
}

public struct ThinkerEvaluater {
  // MARK: - Primitive parsers
  
  // Condition operator parser (11 == 34)
  public let conditionOperator = Parser.oneOf(
    Parser.prefix("==").map { ConditionOperatorType.equal },
    Parser.prefix(">=").map { .greaterOrEqual },
    Parser.prefix("<=").map { .lessOrEqual },
    Parser.prefix(">").map { .greaterThan },
    Parser.prefix("<").map { .lessThan }
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
            return current + "\(result) \(logicOperator) "
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
        case .empty:
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
