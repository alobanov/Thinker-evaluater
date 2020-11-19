//
//  TypeParsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public extension Parser where Output == VariableType {
  static let universalValue = Self { input in
    let original = input
    
    if input.first == "`" {
      var count = 0
      let prefix = input.prefix(while: { char in
        if count == 2 {
          return false
        }
        if char == "`" { count+=1 }
        return true
      })
      
      let result = prefix.replacingOccurrences(of: "`", with: "", options: String.CompareOptions.literal, range: nil)
      input.removeFirst(prefix.count)
      return .str(result)
    }
    
    if input.prefix(4).contains("true") {
      input.removeFirst("true".count)
      return .bool(true)
    }
    
    if input.prefix(5).contains("false") {
      input.removeFirst("false".count)
      return .bool(false)
    }
    
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
    return .double(match * sign)
  }
}

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
    if input.isEmpty {
      return nil
    }
    
    let original = input
    
    if input.prefix(4).contains("true") {
      input.removeFirst("true".count)
      return true
    }
    
    if input.prefix(5).contains("false") {
      input.removeFirst("false".count)
      return false
    }
    
    input = original
    return false
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
