//
//  ThinkerEvaluater+Ext.swift
//  thinker
//
//  Created by Lobanov Aleksey on 26.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

extension ThinkerEvaluater {
  public func compareLogicBool(l: Bool, r: Bool, op: LogicType) -> Bool {
    switch op {
    case .and:
      return l && r
    case .or:
      return l || r
    default:
      return false
    }
  }
  
  public func compareBool(l: Bool, r: Bool?, op: ComparisonType) -> Bool {
    guard let r = r else {
      return false
    }
    
    switch op {
    case .equal:
      return l == r
    case .notEqual:
      return l != r
    default:
      return false
    }
  }
  
  public func compareDouble(l: Double, r: Double?, op: ComparisonType) -> Bool {
    guard let r = r else {
      return false
    }
    
    switch op {
    case .equal:
      return l == r
    case .greaterOrEqual:
      return l >= r
    case .lessOrEqual:
      return l <= r
    case .greaterThan:
      return l > r
    case .lessThan:
      return l < r
    case .notEqual:
      return l != r
    }
  }
  
  public func compareString(l: String, r: String?, op: ComparisonType) -> Bool {
    guard let r = r else {
      return false
    }
    
    switch op {
    case .equal:
      return l == r
    case .notEqual:
      return l != r
    default:
      return false
    }
  }
}
