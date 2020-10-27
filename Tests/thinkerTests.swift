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
    
//    guard let result = instance
//            .evalOper("12 == -32 || 34 > 12 && 11 == 2 && 44 <= 32 || -1 == -1") else {
//      XCTFail()
//      return
//    }
//
//    let f1 = false
//    let f2 = false
//
//    XCTAssertFalse((f1 && f2))
//
//    XCTAssertTrue(Bool("true") ?? false)
//    XCTAssertFalse(Bool("false") ?? true)
//    XCTAssertEqual(result, true)
    
    /// Success
    
    XCTAssertEqual(instance.evaluate("2 == 2") ?? false, true)
    XCTAssertEqual(instance.evaluate("-122.321 == -122.321") ?? false, true)
    XCTAssertEqual(instance.evaluate("-122.321 <= 0.1") ?? false, true)
    XCTAssertEqual(instance.evaluate("false != true") ?? false, true)
    XCTAssertEqual(instance.evaluate("true == true") ?? false, true)
    XCTAssertEqual(instance.evaluate("true == true") ?? false, true)
    XCTAssertEqual(instance.evaluate("`asd` != `ads`") ?? false, true)
    XCTAssertEqual(instance.evaluate("`milk` == `bacon`") ?? false, false)
    XCTAssertEqual(instance.evaluate("`milk` == 2.123") ?? false, false)
    
    
    XCTAssertEqual(instance.evaluate("`milk` == `milk` && 2 >= 1 || true == true") ?? false, true)
    
//
//    let resultLogic = instance.logicEval(result)
//    XCTAssertEqual(resultLogic, "false")
  }
  
}
