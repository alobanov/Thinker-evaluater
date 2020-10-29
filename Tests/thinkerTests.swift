//
//  thinkerTests.swift
//  thinkerTests
//
//  Created by Lobanov Aleksey on 25 Oct 2020.
//  Copyright © 2020 thinker. All rights reserved.
//

@testable import thinker
import XCTest

class thinkerTests: XCTestCase {
  
  static var allTests = [
    ("testExample", testExample),
  ]
  
  func testExample() {
    let instance = ThinkerEvaluater()
    
    XCTAssertEqual(instance.evaluate("2 == 2").result ?? false, true)
    XCTAssertEqual(instance.evaluate("-122.321 == -122.321").result ?? false, true)
    XCTAssertEqual(instance.evaluate("-122.321 <= 0.1").result ?? false, true)
    XCTAssertEqual(instance.evaluate("false != true").result ?? false, true)
    XCTAssertEqual(instance.evaluate("true == true").result ?? false, true)
    XCTAssertEqual(instance.evaluate("true == true").result ?? false, true)
    XCTAssertEqual(instance.evaluate("`asd` != `ads`").result ?? false, true)
    XCTAssertEqual(instance.evaluate("`milk` == `bacon`").result ?? false, false)
    XCTAssertEqual(instance.evaluate("`milk` == 2.123").result ?? false, false)
    XCTAssertEqual(instance.evaluate("`milk` == `milk` && 2 >= 1 || false != true").result ?? false, true)
    XCTAssertEqual(instance.evaluate("21 == 21 && false != true").result ?? false, true)
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
}
