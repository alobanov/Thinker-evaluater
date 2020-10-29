//
//  ThinkerEvaluater+IntEvaluater.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

extension ThinkerEvaluater {
  public func test_evaluateInt(_ input: String) -> String? {
    let conditionParser = zip(
      whitespaceParser,
      comparisonOperator,
      whitespaceParser
    ).flatMap { val -> Parser<ComparisonType> in
      return Parser.always(val.1)
    }
    
    let logicParser = zip(
      whitespaceParser,
      logicOperatr,
      whitespaceParser
    ).flatMap { val -> Parser<LogicType> in
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
      .map { result, logicOperator -> InteratorType in
        switch logicOperator {
        case .empty:
          return .endOfExpression(result: result)
        default:
          return .haveNext(result: result, logicOp: logicOperator)
        }
      }
    
    let parser = compositeExpression
      .zeroOrMore()
      .map {
        $0.reduce("") { (current, next) in
          switch next {
          case let .endOfExpression(result):
            return current + "\(result)"
          case let .haveNext(result, logicOperator):
            return current + "\(result) \(logicOperator.operatorValue) "
          }
        }
      }
    
    let _ = zip(.bool, logicParser, .bool)
      .map { lhs, logic, rhs -> Bool in
        switch logic {
        case .and:
          return lhs && rhs
        case .or:
          return lhs || rhs
        case .empty, .start, .finish:
          return false
        }
      }
    
    return parser.run(input).match
  }
}
