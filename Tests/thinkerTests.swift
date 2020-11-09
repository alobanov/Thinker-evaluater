//
//  thinkerTests.swift
//  thinkerTests
//
//  Created by Lobanov Aleksey on 25 Oct 2020.
//  Copyright © 2020 thinker. All rights reserved.
//

@testable import thinker
import Foundation
import XCTest

class thinkerTests: XCTestCase {
  
  static var allTests = [
    ("testExample", testTrivialComparison),
  ]
  
  func testTrivialComparison() {
    let thnkr = ThinkerEvaluater()
    
//    let boolTes = ins.evaluate("false != true")
//    XCTAssertEqual(boolTes.result, true)
//    XCTAssertEqual(boolTes.rest, "")
    
    // Simple
    
    let intTest = thnkr.evaluate("2 == 2")
    XCTAssertEqual(intTest.result, true)
    XCTAssertEqual(intTest.rest, "")
    
    let doubleTest = thnkr.evaluate("-122.321 == -122.321")
    XCTAssertEqual(doubleTest.result, true)
    XCTAssertEqual(doubleTest.rest, "")
    
    let doubleTest1 = thnkr.evaluate("-122.321 <= 0.1")
    XCTAssertEqual(doubleTest1.result, true)
    XCTAssertEqual(doubleTest1.rest, "")
    
    let boolTest = thnkr.evaluate("false != true")
    XCTAssertEqual(boolTest.result, true)
    XCTAssertEqual(boolTest.rest, "")
    
    let boolTest1 = thnkr.evaluate("false != true")
    XCTAssertEqual(boolTest1.result, true)
    XCTAssertEqual(boolTest1.rest, "")
    
    let strTest = thnkr.evaluate("`milk` == `bacon`")
    XCTAssertEqual(strTest.result, false)
    XCTAssertEqual(strTest.rest, "")
    
    let strTest1 = thnkr.evaluate("`milk` == 2.123")
    XCTAssertEqual(strTest1.result, false)
    XCTAssertEqual(strTest1.rest, "")
    
    
    // Sentences
    
    let compositeSentence = thnkr.evaluate("`milk` == `milk` && 2 >= 1 || false != true")
    XCTAssertEqual(compositeSentence.result, true)
    XCTAssertEqual(compositeSentence.rest, "")
      
    let compositeSentance1 = thnkr.evaluate("1.23 != 1.231 && `bacon` != `milk` && true != false && 2 > 1")
    XCTAssertEqual(compositeSentance1.result, true)
    XCTAssertEqual(compositeSentance1.rest, "")
  }
  
  func test_logicTest() {
    let thnkr = ThinkerEvaluater()
    
//    let test2 = thnkr.evaluateLogic("true || false")
//    XCTAssertEqual(test2.result, true)
//    XCTAssertEqual(test2.rest, "")
//    
//    let test3 = thnkr.evaluateLogic("true || true")
//    XCTAssertEqual(test3.result, true)
//    XCTAssertEqual(test3.rest, "")
//    
//    let test4 = thnkr.evaluateLogic("false || true || true")
//    XCTAssertEqual(test4.result, true)
//    XCTAssertEqual(test4.rest, "")
//    
//    let test5 = thnkr.evaluateLogic("false && false || false")
//    XCTAssertEqual(test5.result, false)
//    XCTAssertEqual(test5.rest, "")
//    
//    let test6 = thnkr.evaluateLogic("true && false")
//    XCTAssertEqual(test6.result, false)
//    XCTAssertEqual(test6.rest, "")
//    
//    if false || true {
//      let r = thnkr.evaluateLogic("false || true")
//      XCTAssertEqual(r.result, true)
//      XCTAssertEqual(r.rest, "")
//    } else {
//      print("FAILED")
//    }
    
    let test7 = thnkr.evaluateLogic("true && false || true")
    XCTAssertEqual(test7.result, true)
    XCTAssertEqual(test7.rest, "")
  }
  
  func test_ExpressionMiddleware() {
    let thnkr = ExpressionMiddleware()
    
    let string =
      """
      model.int == 21,
      model.nested.value == false,
      model.doubleValue == 3233.23123124
      `model.string` == `stringValue`
      model.null == <null>
      """

    let json: [String: Any] = [
      "int": 21,
      "nested": ["value": false],
      "string": "stringValue",
      "doubleValue": 3233.23123124
    ]
    
    let result = thnkr.replaceByKeyPath(
      string: string,
      config: ("model.", json)
    )
    
    
    let testString =
      """
      21 == 21,
      false == false,
      3233.23123124 == 3233.23123124
      `stringValue` == `stringValue`
      <null> == <null>
      """
    
    XCTAssertEqual(result, testString)
  }
  
  func test_ExpressionMiddleware_with_Evaluater() {
    let string = "model.int == 21 && model.nested.value != true || model.doubleValue == 3233.23123124 && `model.string` == `stringValue`"
    
    let json: [String: Any] = [
      "int": 21,
      "nested": ["value": false],
      "string": "stringValue",
      "doubleValue": 3233.23123124
    ]
    
    let result = ThinkerEvaluater().evaluate(string, keypathConfig: ("model.", json))
    
    if !result.rest.isEmpty {
      XCTFail(String(result.rest))
    }
    
    XCTAssertEqual(result.result ?? false, true)
  }
  
  func test_ExpressionMiddleware_with_braces() {
    //
    let expression = "(34 == 34 || false == true) && ((43 >= 23) || (`asd` == `not` || 11 == 11))"
    let result = ThinkerEvaluater().evaluateWithBraces(expression)
    
    if !result.rest.isEmpty {
      XCTFail(String(result.rest))
    }
    
    XCTAssertEqual(result.result, true)
    
    // (true) && (true)
    let expression1 = "(34 >= 41 || true != false) && ((32 != 23 || `asd` != `not`) || (11 == 11))"
    let result1 = ThinkerEvaluater().evaluateWithBraces(expression1)
    
    if !result1.rest.isEmpty {
      XCTFail(String(result1.rest))
    }
    
    XCTAssertEqual(result1.result, true)
  }
  
  func test_par() {
    let thnkr = ThinkerEvaluater()
    let result = thnkr.evaluateParenthesis(
      "(23 >= 2 && false != true) && (43.21 != 23 && 34.1231 > 332 && true == false) || 4 > 3"
    )
    
    XCTAssertEqual(result.result, true)
  }
}
