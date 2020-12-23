import Foundation
import thinker

Parser
  .key("IPHONE_SIMULATOR_ROOT", .prefix(through: ".app"))
  .run(ProcessInfo.processInfo.environment)

Parser.prefix(through: ".app").run(
  ProcessInfo.processInfo.environment["IPHONE_SIMULATOR_ROOT"]![...]
)
