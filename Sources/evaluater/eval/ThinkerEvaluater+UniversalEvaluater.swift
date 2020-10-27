//
//  ThinkerEvaluater+Parsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

extension ThinkerEvaluater {
  public func evaluate(_ input: String) -> Bool? {
    
    // Parser for "<whitespace><comparison><whitespace>" = " >= "
    let comparisonSentenceParser = zip(whitespaceParser, comparisonOperator, whitespaceParser)
      .flatMap { value -> Parser<ComparisonType> in
        return Parser.always(value.1)
      }
    
    // Parser for "<any value><whitespace><comparison><whitespace><any value>" = "3 >= 2"
    let expressionCondition = zip(.universal, comparisonSentenceParser, .universal)
      .map { lhs, condition, rhs -> Bool in
        switch lhs {
        case let .bool(lhsValue):
          return compareBool(l: lhsValue, r: rhs.boolValue, op: condition)
          
        case let .double(lhsValue):
          return compareDouble(l: lhsValue, r: rhs.doubleValue, op: condition)
          
        case let .str(lhsValue):
          return compareString(l: lhsValue, r: rhs.strValue, op: condition)
        }
      }
    
    // Parser for "<whitespace><logic><whitespace>" = " && "
    let logicParser = zip(whitespaceParser, logicOperatr, whitespaceParser)
      .flatMap { val -> Parser<LogicType> in
        return Parser.always(val.1)
      }
    
    // Parser exmaple = "3 >= 2 && "
    // It just detected more sentence or catch end of sentence
    let compositeExpression = zip(expressionCondition, logicParser)
      .map { res, con -> InteratorType in
        switch con {
        case .empty:
          return .endOfExpression(res)
        default:
          return .haveNext(res, con)
        }
      }
    
    // We have:
    // 1. Current sentance: (<bool>,&&)
    // 2. Next value: <bool>
    let endOfExpressionComparison: (LogicValue, Bool) -> (LogicValue) = { current, result in
      switch current.1 {
      case .and:
        let newResult = current.0 && result
        #if DEBUG
        print("Final composite logic:", current.0, "AND", result, "->", newResult)
        #endif
        return (newResult, .finish)
      case .or:
        let newResult = current.0 || result
        #if DEBUG
        print("Final composite logic:", current.0, "OR", result, "->", newResult)
        #endif
        return (newResult, .finish)
      case .empty, .finish:
        return (current.0, current.1)
        
      case .start:
        return (result, current.1)
      }
    }
    
    // We have:
    // 1. Current sentance: (<bool>,&&)
    // 2. Next value: <bool>
    // 3. Next logic operator: &&
    let haveNextComparison: (LogicValue, Bool, LogicType) -> (LogicValue) = { currentValue, nextValue, nextLogicOperator in
      if currentValue.1 == .start {
        return (nextValue, nextLogicOperator)
      } else {
        switch currentValue.1 {
        case .and:
          let newResult = currentValue.0 && nextValue
          #if DEBUG
          print("Composite logic:", currentValue.0, "AND", nextValue, "->", newResult)
          #endif
          return (newResult, nextLogicOperator)
        case .or:
          let newResult = currentValue.0 || nextValue
          #if DEBUG
          print("Composite logic:", currentValue.0, "OR", nextValue, "->", newResult)
          #endif
          return (newResult, nextLogicOperator)
          
        case .empty, .start, .finish:
          return (currentValue.0, currentValue.1)
        }
        
      }
    }
    
    let parser = compositeExpression
      .zeroOrMore()
      .map {
        $0.reduce(LogicValue(false, .start)) { current, value in
          switch value {
          case let .endOfExpression(result):
            return endOfExpressionComparison(current, result)
            
          case let .haveNext(result, logicOperator):
            return haveNextComparison(current, result, logicOperator)
          }
        }
      }
    
    let res = parser.run(input)
    print("\n\n RESULT:", res, "\n\n")
    
    return res.match?.0
  }
}
