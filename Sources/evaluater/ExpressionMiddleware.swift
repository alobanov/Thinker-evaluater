//
//  Preparator.swift
//  thinker
//
//  Created by Lobanov Aleksey on 29.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public class ExpressionMiddleware {
  public typealias KeyPathConfig = (prefix: String, json: [String: Any])
  
  public func replaceByKeyPath(string: String, config: KeyPathConfig) -> String {
    var expression = string
    
    // Keys
    let paths = expression.regex(pattern: "\(config.prefix)([a-zA-Z0-9_.\\-]+)", group: 1)
    
    print(paths)
    
    // replace key by values
    for path in paths {
      if let value = config.json.value(by: path) as? String {
        if value == "" { continue }
        expression = expression.replacingOccurrences(of: "\(config.prefix)\(path)", with: value)
      } else {
        expression = expression.replacingOccurrences(of: "\(config.prefix)\(path)", with: "<null>")
      }
    }
    
    return expression
  }
}
