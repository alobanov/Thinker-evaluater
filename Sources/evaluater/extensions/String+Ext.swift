import Foundation

extension String {
  public func cleareNewline() -> String {
    return replacingOccurrences(of: "\\n", with: " ", options: .regularExpression)
  }
  
  public func regex(pattern: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
      let nsstr = self as NSString
      let all = NSRange(location: 0, length: nsstr.length)
      var matches: [String] = [String]()
      regex
        .enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) { (result: NSTextCheckingResult?, _, _) in
          if let r = result {
            let result = nsstr.substring(with: r.range) as String
            matches.append(result)
          }
        }
      return matches
    } catch let e {
      print(e)
      return [String]()
    }
  }
  
  public func regex(pattern: String, group: Int) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
      let nsstr = self as NSString
      let all = NSRange(location: 0, length: nsstr.length)
      var result: [String] = [String]()
      
      let matches = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all)
      
      for match in matches as [NSTextCheckingResult] {
        if match.numberOfRanges - 1 > group {
          return [String]()
        }
        
        let substring = nsstr.substring(with: match.range(at: group))
        result.append(substring)
      }
      
      return result
    } catch {
      return [String]()
    }
  }
  
  private func findStringBy(searchString: String, results: [NSTextCheckingResult]) -> String {
    if !results.isEmpty {
      let firstMatch = results[0]
      
      if firstMatch.numberOfRanges >= 1 {
        let range = firstMatch.range(at: 1)
        let newRange = searchString.index(searchString.startIndex, offsetBy: range.location) ..< searchString.index(searchString.startIndex, offsetBy: range.location + range.length)
        let string = String(searchString[newRange])
        return string
      }
      
      return ""
    }
    return ""
  }
}
