//
//  ThinkerEvaluater+Parsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

// Universal evaluater
//
// - Work with types:
//  1. Numeric constants, as floating point (12345.678)
//  2. String constants (single quotes: `foobar`)
//  3. Boolean constants: true false
// - Comparison operators: ==, >=, <=, !=, >, <
// - Logic operators: &&, ||
//
// Example usage:
//  XCTAssertEqual(instance.evaluate("2 == 2") ?? false, true) // Int
//  XCTAssertEqual(instance.evaluate("-122.321 == -122.321") ?? false, true) // Doube
//  XCTAssertEqual(instance.evaluate("false != true") ?? false, true) // Boolean
//  XCTAssertEqual(instance.evaluate("`asd` != `ads`") ?? false, true) // String
//  XCTAssertEqual(instance.evaluate("`milk` == `milk` && 2 >= 1 || true == true") ?? false, true) // Composite expression

extension ThinkerEvaluater {
  
  // example: (2 == 2 || (34 <= 5 && `edwdwe` == `dwedw`)) && ((32 == 32 && false) || 44 == 44)
  
  public func evaluate(_ inptu: String, keypathConfig: ExpressionMiddleware.KeyPathConfig) -> Result {
    let updatedExpression = ExpressionMiddleware().replaceByKeyPath(string: inptu, config: keypathConfig)
    
    
    print(updatedExpression)
    return evaluate(updatedExpression)
  }
  
  public func evaluate(_ input: String) -> Result {
    
    // Parser for "<whitespace><comparison><whitespace>" = " >= "
    let comparisonSentenceParser = zip(whitespaceParser, comparisonOperator, whitespaceParser)
      .flatMap { value -> Parser<ComparisonType> in
        return Parser.always(value.1)
      }
    
    // Parser for "<any value><whitespace><comparison><whitespace><any value>" = "3 >= 2"
    let expressionCondition = zip(.universalValue, comparisonSentenceParser, .universalValue)
      .map { lhs, condition, rhs -> Bool in
        switch lhs {
        case let .bool(value):
          return compareBool(l: value, r: rhs.boolValue, op: condition)
          
        case let .double(value):
          return compareDouble(l: value, r: rhs.doubleValue, op: condition)
          
        case let .str(value):
          return compareString(l: value, r: rhs.strValue, op: condition)
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
      .map { result, logicOperator -> InteratorType in
        switch logicOperator {
        case .empty:
          #if DEBUG
          print("endOfExpression:", result)
          #endif
          return .endOfExpression(result: result)
          
        default:
          #if DEBUG
          print("haveNext:", result, logicOperator)
          #endif
          return .haveNext(result: result, logicOp: logicOperator)
        }
      }
    
    // We have:
    // 1. Current sentance: (<bool>,&&)
    // 2. Next value: <bool>
    let endOfExpressionComparison: (LogicValue, Bool) -> (LogicValue) = { current, result in
      switch current.logicOp {
      case .and:
        let newResult = current.result && result
        #if DEBUG
        print("Final composite logic:", current.result, "AND", result, "->", newResult)
        #endif
        return (newResult, .finish)
        
      case .or:
        let newResult = current.0 || result
        #if DEBUG
        print("Final composite logic:", current.result, "OR", result, "->", newResult)
        #endif
        return (newResult, .finish)
        
      case .empty, .finish:
        return (current.result, current.logicOp)
        
      case .start:
        return (result, current.logicOp)
      }
    }
    
    // We have:
    // 1. Current sentance: (<bool>,&&)
    // 2. Next value: <bool>
    // 3. Next logic operator: &&
    let haveNextComparison: (LogicValue, Bool, LogicType) -> (LogicValue) = { currentValue, nextValue, nextLogicOperator in
      if currentValue.logicOp == .start {
        return (nextValue, nextLogicOperator)
      } else {
        switch currentValue.logicOp {
        case .and:
          let newResult = currentValue.result && nextValue
          #if DEBUG
          print("Composite logic:", currentValue.result, "AND", nextValue, "->", newResult)
          #endif
          return (newResult, nextLogicOperator)
          
        case .or:
          let newResult = currentValue.result || nextValue
          #if DEBUG
          print("Composite logic:", currentValue.result, "OR", nextValue, "->", newResult)
          #endif
          return (newResult, nextLogicOperator)
          
        case .empty, .start, .finish:
          return (currentValue.result, currentValue.logicOp)
        }
        
      }
    }
    
    // Parser full expression: "3 >= 2 && 2 == 2 || `test` == `test`"
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
    return (res.match?.0, res.rest)
  }
}
