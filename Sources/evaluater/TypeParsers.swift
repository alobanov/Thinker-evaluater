//
//  TypeParsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

// Parser<Int>.int
// .int
public extension Parser where Output == Int {
  static let int = Self { input in
    let original = input
    
    let sign: Int // +1, -1
    if input.first == "-" {
      sign = -1
      input.removeFirst()
    } else if input.first == "+" {
      sign = 1
      input.removeFirst()
    } else {
      sign = 1
    }
    
    let intPrefix = input.prefix(while: \.isNumber)
    guard let match = Int(intPrefix)
    else {
      input = original
      return nil
    }
    input.removeFirst(intPrefix.count)
    return match * sign
  }
}

public extension Parser where Output == Bool {
  static let bool = Self { input in
    let original = input
    
    var resultPrefix = 0
    var prefixValue = ""
    
    if input.hasPrefix("true") {
      input.removeFirst("true".count)
      return true
    } else if input.hasPrefix("false") {
      input.removeFirst("false".count)
      return false
    } else {
      return false
    }
  }
}

public extension Parser where Output == Double {
  static let double = Self { input in
    let original = input
    let sign: Double
    if input.first == "-" {
      sign = -1
      input.removeFirst()
    } else if input.first == "+" {
      sign = 1
      input.removeFirst()
    } else {
      sign = 1
    }
    
    var decimalCount = 0
    let prefix = input.prefix { char in
      if char == "." { decimalCount += 1 }
      return char.isNumber || (char == "." && decimalCount <= 1)
    }
    
    guard let match = Double(prefix)
    else {
      input = original
      return nil
    }
    
    input.removeFirst(prefix.count)
    
    return match * sign
  }
}

public extension Parser where Output == Character {
  static let char = Self { input in
    guard !input.isEmpty else {
      return nil
    }
    
    return input.removeFirst()
  }
}

public extension Parser where Output == Void {
  static func prefix(_ p: String) -> Self {
    Self { input in
      guard input.hasPrefix(p) else {
        return nil
      }
      
      input.removeFirst(p.count)
      return ()
    }
  }
}
