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
    ("testExample", testExample),
  ]
  
  func testExample() {
    let ins = ThinkerEvaluater()
    
    let test1 = ins.evaluate("2 == 2")
    XCTAssertEqual(test1.result, true)
    XCTAssertEqual(test1.rest, "")

    XCTAssertEqual(ins.evaluate("-122.321 == -122.321").result, true)
    XCTAssertEqual(ins.evaluate("-122.321 <= 0.1").result, true)
    XCTAssertEqual(ins.evaluate("false != true").result, true)
    XCTAssertEqual(ins.evaluate("true == true").result, true)
    XCTAssertEqual(ins.evaluate("true == true").result, true)
    XCTAssertEqual(ins.evaluate("`asd` != `ads`").result, true)
    XCTAssertEqual(ins.evaluate("`milk` == `bacon`").result, false)
    XCTAssertEqual(ins.evaluate("`milk` == 2.123").result, false)
    XCTAssertEqual(ins.evaluate("`milk` == `milk` && 2 >= 1 || false != true").result, true)
    XCTAssertEqual(ins.evaluate("21 == 21 && false != true").result, true)
  }
  
  func test_logicTest() {
    let ins = ThinkerEvaluater()
    
    let test2 = ins.evaluateLogic("true || false")
    XCTAssertEqual(test2.result, true)
    XCTAssertEqual(test2.rest, "")
    
    let test3 = ins.evaluateLogic("true || true")
    XCTAssertEqual(test3.result, true)
    XCTAssertEqual(test3.rest, "")
    
    let test4 = ins.evaluateLogic("false || true")
    XCTAssertEqual(test4.result, true)
    XCTAssertEqual(test4.rest, "")
    
    let test5 = ins.evaluateLogic("false && false")
    XCTAssertEqual(test5.result, false)
    XCTAssertEqual(test5.rest, "")
    
    let test6 = ins.evaluateLogic("true && true")
    XCTAssertEqual(test6.result, true)
    XCTAssertEqual(test6.rest, "")
  }
  
  func test_ExpressionMiddleware() {
    let instance = ExpressionMiddleware()
    
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
    
    let result = instance.replaceByKeyPath(
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
    
    print(result)
    
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
}
