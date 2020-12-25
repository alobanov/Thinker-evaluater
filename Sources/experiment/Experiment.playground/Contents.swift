import Foundation
import thinker

Parser
  .key("IPHONE_SIMULATOR_ROOT", .prefix(through: ".app"))
  .run(ProcessInfo.processInfo.environment)

Parser.prefix(through: ".app").run(
  ProcessInfo.processInfo.environment["IPHONE_SIMULATOR_ROOT"]![...]
)

var str = "true && false"[...].unicodeScalars as Substring.UnicodeScalarView
dump(
  "true"[...].unicodeScalars.dropFirst()
)

var result = str.index(.init(utf16Offset: 0, in: String(str)), offsetBy: 4)
dump(str.starts(with: "true"[...].unicodeScalars))
//dump(result)


var prefix1 = "dwdew `dwedwed` wedwed"[...].unicodeScalars
//let result2 = prefix1.replacingOccurrences(of: "`", with: "", options: String.CompareOptions.literal, range: nil)

prefix1.removeAll { e -> Bool in
  e == "`"
}

dump(String(prefix1))

