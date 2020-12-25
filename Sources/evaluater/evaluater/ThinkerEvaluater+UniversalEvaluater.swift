//
//  ThinkerEvaluater+Parsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

// Universal evaluater

extension ThinkerEvaluater {
  
  /// Evaluate expression
  /// - Parameters:
  ///   - input: String - `(false != true) && ((34 > 2.1231123) && 4.2 == 4.2 || 3 != 3)`
  ///   - keypathConfig: KeyPathConfig = (prefix: String, json: [String: Any])
  /// - Returns: (result: Bool?, rest: Substring)
  public static func eval(_ input: String, keypathConfig: ExpressionMiddleware.KeyPathConfig? = nil) -> Result {
    let thnkr = ThinkerEvaluater()
    
    if let config = keypathConfig {
      // Проверяем keypath значения
      let updateInput = ExpressionMiddleware().replaceByKeyPath(string: input, config: config)
      return thnkr.evaluateInParenthesis(updateInput)
    } else {
      return thnkr.evaluateInParenthesis(input)
    }
  }
  
  private func evaluateInParenthesis(_ input: String) -> Result {
    var preInput = input
    
    // Поиск выражений сравнения для переменных: Bool, Int, Double, String
    let comparisonRegexp = "((?:[-\\d.]|true|false|`.+`)*)(?:\\s+)(==|>|>=|<=|<|!=)(?:\\s+)((?:[-\\d.]|true|false|`.+`)*)"
    for value in input.regexMatchResult(pattern: comparisonRegexp) {
      let evalResult = evaluate(value.match)
      
      if evalResult.rest.isEmpty {
        let resultStr = String(describing: evalResult.result ?? false)
        preInput = preInput.replacingOccurrences(of: value.match, with: resultStr)
      } else {
        return evalResult
      }
    }
        
    return evaluateParenthesisWithControlOrder(preInput)
  }
  
  public func evaluateParenthesisWithControlOrder(_ input: String) -> Result {
    var expression = input
    while true {
      let bracesResult = ExpressionMiddleware().bracesEvaluater(string: expression)
      if bracesResult.isEmpty {
        break
      }
      
      for subExpression in bracesResult {
        let logicResult = evaluateLogic(subExpression)
        guard let resultBool = logicResult.result else {
          return (nil, logicResult.rest)
        }
        
        expression = expression.replacingOccurrences(
          of: "(\(subExpression))", with: String(describing: resultBool)
        )
      }
    }
    
    return evaluateLogic(expression)
  }
  
  public func evaluateLogic(_ input: String) -> Result {
    let compositeExpression = Parser.bool.take(logicParser)
//      zip(.bool, logicParser)
      .map { result, logic -> ExpressionInteratorType in
        switch logic {
        case .empty, .finish:
          return .end(result: result)
          
        default:
          return .next(result: result, logicOp: logic)
        }
      }
    
    let parser = compositeExpression.zeroOrMore().map {
      $0.reduce(LogicValue(false, .start)) { current, value in
        switch value {
        case let .end(result):
          switch current.logicOp {
          case .and, .or:
            let logicResult = compareLogicBool(l: current.result, r: result, op: current.logicOp)
            return (logicResult, .finish)
              
          case .empty, .finish:
            return (current.result, current.logicOp)
            
          case .start:
            return (result, current.logicOp)
          }
          
        case let .next(result, logicOp):
          if current.logicOp == .start {
            return (result, logicOp)
            
          } else {
            switch current.logicOp {
            case .and, .or:
              let logicResult = compareLogicBool(l: current.result, r: result, op: current.logicOp)
              return (logicResult, logicOp)
              
            case .empty, .start, .finish:
              return (current.result, current.logicOp)
            }
          }
        }
      }
    }
    
    let res = parser.run(input[...].utf8)
    return (res.match?.0, Substring(res.rest))
  }
  
  public func evaluate(_ input: String) -> Result {
    // Parser for "<any value><whitespace><comparison><whitespace><any value>" = "3 >= 2"
    let expressionCondition = Parser.universalValue.take(comparisonSentenceParser).take(.universalValue)
//      zip(.universalValue, comparisonSentenceParser, .universalValue)
      .map { lhs, condition, rhs -> Bool in
        switch lhs {
        case let .bool(value):
          #if DEBUG
          print("Bool comparison:", value, condition, rhs.boolValue ?? false)
          #endif
          return compareBool(l: value, r: rhs.boolValue, op: condition)
          
        case let .double(value):
          #if DEBUG
          print("Double comparison:", value, condition, rhs.doubleValue ?? 0.0)
          #endif
          return compareDouble(l: value, r: rhs.doubleValue, op: condition)
          
        case let .str(value):
          #if DEBUG
          print("Str comparison:", value, condition, rhs.strValue ?? "")
          #endif
          return compareString(l: value, r: rhs.strValue, op: condition)
        }
      }
        
    // Parser exmaple = "3 >= 2 && "
    // It just detected more sentence or catch end of sentence
    let compositeExpression = expressionCondition.take(logicParser)
//      zip(expressionCondition, logicParser)
      .map { result, logicOperator -> ExpressionInteratorType in
        switch logicOperator {
        case .empty, .finish:
          #if DEBUG
          print("endOfExpression:", result)
          #endif
          return .end(result: result)
          
        default:
          #if DEBUG
          print("haveNext:", result, logicOperator)
          #endif
          return .next(result: result, logicOp: logicOperator)
        }
      }
    
    // We have:
    // 1. Current sentance: (<bool>,&&)
    // 2. Next value: <bool>
    let endOfExpressionComparison: (LogicValue, Bool) -> (LogicValue) = { current, result in
      switch current.logicOp {
      case .and, .or:
        let logicResult = compareLogicBool(l: current.result, r: result, op: current.logicOp)
        #if DEBUG
        print("Final composite logic:", current.result, current.logicOp, result, "->", logicResult)
        #endif
        return (logicResult, .finish)
                
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
          case let .end(result):
            return endOfExpressionComparison(current, result)
            
          case let .next(result, logicOperator):
            return haveNextComparison(current, result, logicOperator)
          }
        }
      }
    
    let res = parser.run(input[...].utf8)
    return (res.match?.0, Substring(res.rest))
  }
}
