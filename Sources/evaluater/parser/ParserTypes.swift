//
//  ParserTypes.swift
//  thinker
//
//  Created by Lobanov Aleksey on 27.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public enum VariableType: Equatable {
  case bool(Bool), str(String), double(Double)
  
  var boolValue: Bool? {
    if case let .bool(val) = self {
      return val
    } else {
      return nil
    }
  }
  
  var strValue: String? {
    if case let .str(val) = self {
      return val
    } else {
      return nil
    }
  }
  
  var doubleValue: Double? {
    if case let .double(val) = self {
      return val
    } else {
      return nil
    }
  }
}

public enum ComparisonType {
  case equal, greaterOrEqual, lessOrEqual, greaterThan, lessThan, notEqual
}

public enum LogicType: String {
  case and, or, empty, start, finish
  
  var operatorValue: String {
    switch self {
    case .and:
      return "&&"
    case .or:
      return "||"
    case .empty:
      return ""
    case .start, .finish:
      return ""
    }
  }
}

public enum EmptyCharType {
  case whitespace
  case empty
}

public enum InteratorType {
  case endOfExpression(result: Bool)
  case haveNext(result: Bool, logicOp: LogicType)
}

typealias LogicValue = (result: Bool, logicOp: LogicType)
