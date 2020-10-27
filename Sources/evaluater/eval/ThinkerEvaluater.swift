//
//  Thinker.swift
//  thinker
//
//  Created by Lobanov Aleksey on 25.10.2020.
//  Copyright © 2020 thinker. All rights reserved.
//

import Foundation

public struct ThinkerEvaluater {
  // MARK: - Primitive parsers
  
  // Comparison operator parser (11 == 34)
  public let comparisonOperator = Parser.oneOf(
    Parser.prefix("==").map { ComparisonType.equal },
    Parser.prefix(">=").map { .greaterOrEqual },
    Parser.prefix("<=").map { .lessOrEqual },
    Parser.prefix(">").map { .greaterThan },
    Parser.prefix("<").map { .lessThan },
    Parser.prefix("!=").map { .notEqual }
  )

  // Logic operator parser (true && false || false)
  public let logicOperatr = Parser.oneOf(
    Parser.prefix("&&").map { LogicType.and },
    Parser.prefix("||").map { .or },
    Parser.prefix("").map { .empty }
  )
  
  public let whitespaceParser = Parser.oneOf(
    Parser.prefix(" ").map { EmptyCharType.whitespace },
    Parser.prefix("").map { .empty }
  )
}
