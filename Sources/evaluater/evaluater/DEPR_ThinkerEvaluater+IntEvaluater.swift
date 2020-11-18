//
//  ThinkerEvaluater+IntEvaluater.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

extension ThinkerEvaluater {
  private func test_evaluateInt(_ input: String) -> String? {
    let conditionParser = zip(
      Self.whitespaceParser,
      Self.comparisonOperator,
      Self.whitespaceParser
    ).flatMap { val -> Parser<ComparisonType> in
      return Parser.always(val.1)
    }
    
    let logicParser = zip(
      Self.whitespaceParser,
      Self.logicOperatr,
      Self.whitespaceParser
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
      .map { result, logicOperator -> ExpressionInteratorType in
        switch logicOperator {
        case .empty:
          return .end(result: result)
        default:
          return .next(result: result, logicOp: logicOperator)
        }
      }
    
    let parser = compositeExpression
      .zeroOrMore()
      .map {
        $0.reduce("") { (current, next) in
          switch next {
          case let .end(result):
            return current + "\(result)"
          case let .next(result, logicOperator):
            return current + "\(result) \(logicOperator.operatorValue) "
          }
        }
      }
    
//    let _ = zip(.bool, logicParser, .bool)
//      .map { lhs, logic, rhs -> Bool in
//        switch logic {
//        case .and:
//          return lhs && rhs
//        case .or:
//          return lhs || rhs
//        case .empty, .start, .finish:
//          return false
//        }
//      }
    
    return parser.run(input).match
  }
}
