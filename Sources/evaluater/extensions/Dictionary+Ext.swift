//
//  Dictionary+Ext.swift
//  thinker
//
//  Created by Lobanov Aleksey on 29.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

extension Dictionary {
  public func value(by path: String) -> Any? {
    let keys = path.components(separatedBy: ".")
    
    let count = keys.count
    var deep = 1
    
    guard var currentNode = self as? [String: Any] else {
      return nil
    }
    
    for key in keys {
      if deep == count {
        if (currentNode[key] as? NSNull) != nil {
          return nil
        }
        
        if let array = currentNode[key] as? [[String: Any]] {
          return array
        }
        
        if let dict = currentNode[key] as? [String: Any] {
          return dict
        }
        
        if let result = currentNode[key] {
          let result = String(describing: result)
          return result
        } else {
          return nil
        }
      } else {
        if let nextNode = currentNode[key] as? [String: Any] {
          currentNode = nextNode
        }
      }
      deep += 1
    }
    
    return nil
  }
}
