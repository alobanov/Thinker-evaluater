//
//  TypeParsers.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public extension Parser where Input == Substring.UTF8View, Output == VariableType {
  static let universalValue = Self { input in
    let original = input
    
    if input.first == UTF8.CodeUnit(ascii: "`") {
      var count = 0
      let prefix = input.prefix(while: { char in
        if count == 2 {
          return false
        }
        if char == UTF8.CodeUnit(ascii: "`") { count+=1 }
        return true
      })
      
      var prefixE = Substring(prefix)[...].unicodeScalars
      prefixE.removeAll { $0 == "`" }
      input.removeFirst(prefix.count)
      
      return .str(String(prefixE))
    }
    
    if input.starts(with: "true"[...].utf8) {
      input.removeFirst("true".count)
      return .bool(true)
    }
    
    if input.starts(with: "false"[...].utf8) {
      input.removeFirst("false".count)
      return .bool(false)
    }
    
    let sign: Double
    if input.first == UTF8.CodeUnit(ascii: "-") {
      sign = -1
      input.removeFirst()
    } else if input.first == UTF8.CodeUnit(ascii: "+") {
      sign = 1
      input.removeFirst()
    } else {
      sign = 1
    }
    
    var decimalCount = 0
    let prefix = input.prefix { char in
      if char == UTF8.CodeUnit(ascii: ".") { decimalCount += 1 }
      return (UTF8.CodeUnit(ascii: "0")...UTF8.CodeUnit(ascii: "9")).contains(char) || (char == UTF8.CodeUnit(ascii: ".") && decimalCount <= 1)
    }
    
    guard let match = Double(String(Substring(prefix)))
    else {
      input = original
      return nil
    }
    
    input.removeFirst(prefix.count)
    return .double(match * sign)
  }
}

public extension Parser where Input == Substring, Output == VariableType {
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

public extension Parser where Input == Substring.UnicodeScalarView, Output == VariableType {
  static let universalValue = Self { input in
    let original = input

    if input.first == "`" {
      var count = 0
      var prefix = input.prefix(while: { char in
        if count == 2 {
          return false
        }
        if char == "`" { count+=1 }
        return true
      })

      prefix.removeAll { e -> Bool in e == "`" }
      input.removeFirst(prefix.count)
      return .str(String(prefix))
    }

    if input.starts(with: "true"[...].unicodeScalars) {
      input.removeFirst("true".count)
      return .bool(true)
    }

    if input.starts(with: "false"[...].unicodeScalars) {
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
      return ("0"..."9").contains(char) || (char == "." && decimalCount <= 1)
    }

    guard let match = Double(String(prefix))
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
public extension Parser where Input == Substring, Output == Int {
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

public extension Parser where Input == Substring, Output == Bool {
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

public extension Parser where Input == Substring.UnicodeScalarView, Output == Bool {
  static let bool = Self { input in
    if input.isEmpty {
      return nil
    }
    
    let original = input
    
    if input.starts(with: "true"[...].unicodeScalars) {
      input.removeFirst("true".count)
      return true
    }
    
    if input.starts(with: "false"[...].unicodeScalars) {
      input.removeFirst("false".count)
      return false
    }
    
    input = original
    return false
  }
}

public extension Parser where Input == Substring.UTF8View, Output == Bool {
  static let bool = Self { input in
    if input.isEmpty {
      return nil
    }
    
    let original = input
    
    if input.starts(with: "true"[...].utf8) {
      input.removeFirst("true".count)
      return true
    }
    
    if input.starts(with: "false"[...].utf8) {
      input.removeFirst("false".count)
      return false
    }
    
    input = original
    return false
  }
}

public extension Parser where Input == Substring, Output == Double {
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

public extension Parser where Input == Substring, Output == Character {
  static let char = Self { input in
    guard !input.isEmpty else {
      return nil
    }
    
    return input.removeFirst()
  }
}
