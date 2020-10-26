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
    instance.prepare()
    
    
    guard let result = instance.evalOper("12 == -32 || 34 > 12 && 11 == 2") else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(result, "false || true && false")
//    
//    let resultLogic = instance.logicEval(result)
//    XCTAssertEqual(resultLogic, "false")
  }
  
}
