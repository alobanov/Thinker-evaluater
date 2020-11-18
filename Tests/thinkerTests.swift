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
//    let boolTes = ThinkerEvaluater.eval("false != true")
//    XCTAssertEqual(boolTes.result, true)
//    XCTAssertEqual(boolTes.rest, "")
    
    // Simple
    
    let intTest = ThinkerEvaluater.eval("2 == 2")
    XCTAssertEqual(intTest.result, true)
    XCTAssertEqual(intTest.rest, "")

    let doubleTest = ThinkerEvaluater.eval("-122.321 == -122.321")
    XCTAssertEqual(doubleTest.result, true)
    XCTAssertEqual(doubleTest.rest, "")

    let doubleTest1 = ThinkerEvaluater.eval("-122.321 <= 0.1")
    XCTAssertEqual(doubleTest1.result, true)
    XCTAssertEqual(doubleTest1.rest, "")

    let boolTest = ThinkerEvaluater.eval("false != true")
    XCTAssertEqual(boolTest.result, true)
    XCTAssertEqual(boolTest.rest, "")

    let boolTest1 = ThinkerEvaluater.eval("false != true")
    XCTAssertEqual(boolTest1.result, true)
    XCTAssertEqual(boolTest1.rest, "")

    let strTest = ThinkerEvaluater.eval("`milk` == `bacon`")
    XCTAssertEqual(strTest.result, false)
    XCTAssertEqual(strTest.rest, "")
    
    let strTest1 = ThinkerEvaluater.eval("`milk` == `2.123`")
    XCTAssertEqual(strTest1.result, false)
    XCTAssertEqual(strTest1.rest, "")
    
    // Sentences
    
    let compositeSentence = ThinkerEvaluater.eval("`milk is white` == `milk is white` && 2 >= 1 || false != true")
    XCTAssertEqual(compositeSentence.result, true)
    XCTAssertEqual(compositeSentence.rest, "")
      
    let compositeSentance1 = ThinkerEvaluater.eval("1.23 != 1.231 && `bacon` != `milk` && true != false && 2 > 1")
    XCTAssertEqual(compositeSentance1.result, true)
    XCTAssertEqual(compositeSentance1.rest, "")
  }
  
  func test_logicTest() {
    let thnkr = ThinkerEvaluater()
    
    if true || false {
      let test2 = thnkr.evaluateLogic("true || false")
      XCTAssertEqual(test2.result, true)
      XCTAssertEqual(test2.rest, "")
    } else {
      XCTFail()
    }
    
    if true || true {
      let test3 = thnkr.evaluateLogic("true || true")
      XCTAssertEqual(test3.result, true)
      XCTAssertEqual(test3.rest, "")
    } else {
      XCTFail()
    }
      
    
    if false || true || true {
      let test4 = thnkr.evaluateLogic("false || true || true")
      XCTAssertEqual(test4.result, true)
      XCTAssertEqual(test4.rest, "")
    } else {
      XCTFail()
    }
    
    let test5 = thnkr.evaluateLogic("false && false || false")
    XCTAssertEqual(test5.result, false)
    XCTAssertEqual(test5.rest, "")
    
    if !(true && false) {
      let test6 = thnkr.evaluateLogic("true && false")
      XCTAssertEqual(test6.result, false)
      XCTAssertEqual(test6.rest, "")
    } else {
      XCTFail()
    }
    
    if false || true {
      let r = thnkr.evaluateLogic("false || true")
      XCTAssertEqual(r.result, true)
      XCTAssertEqual(r.rest, "")
    } else {
      XCTFail()
    }
    
    if true && false || true {
      let test7 = thnkr.evaluateLogic("true && false || true")
      XCTAssertEqual(test7.result, true)
      XCTAssertEqual(test7.rest, "")
    } else {
      XCTFail()
    }
    
    if 2 > 1 && 3 != 3 || 2 == 2 {
      let test8 = thnkr.evaluate("2 > 1 && 3 != 3 || 2 == 2")
      XCTAssertEqual(test8.result, true)
      XCTAssertEqual(test8.rest, "")
    } else {
      XCTFail()
    }
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
    
    let result = ThinkerEvaluater.eval(string, keypathConfig: ("model.", json))
    
    if !result.rest.isEmpty {
      XCTFail(String(result.rest))
    }
    
    XCTAssertEqual(result.result ?? false, true)
  }
  
  func test_ExpressionMiddleware_with_braces() {
    // (true || false) && ((true) || (false || true))
    if (34 == 34 || false == true) && ((43 >= 23) || ("asd" == "not" || 11 == 11)) {
      let expression = "(34 == 34 || false == true) && ((43 >= 23) || (`asd` == `not` || 11 == 11))"
      let result = ThinkerEvaluater.eval(expression)
      
      if !result.rest.isEmpty {
        XCTFail(String(result.rest))
      }
      
      XCTAssertEqual(result.result, true)
    } else {
      XCTFail()
    }
    
    // (true) && (true)
    let expression1 = "(34 >= 41 || true != false) && ((32 != 23 || `asd` != `not`) || 11 == 11)"
    let result1 = ThinkerEvaluater.eval(expression1)
    
    if !result1.rest.isEmpty {
      XCTFail(String(result1.rest))
    }
    
    XCTAssertEqual(result1.result, true)
    
    let result3 = ThinkerEvaluater.eval(
      "(23 >= 2 && false != true) && (43.21 != 23 && (34.1231 > 332 && true == false)) || 4 > 3"
    )
    
    XCTAssertEqual(result3.result, true)
  }
}
