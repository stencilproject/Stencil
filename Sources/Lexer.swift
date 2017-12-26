import Foundation

struct Lexer {
  let templateString: String

  init(templateString: String) {
    self.templateString = templateString
  }

  func createToken(string: String, at range: Range<String.Index>) -> Token {
    func strip() -> String {
      guard string.characters.count > 4 else { return "" }
      let start = string.index(string.startIndex, offsetBy: 2)
      let end = string.index(string.endIndex, offsetBy: -2)
      return String(string[start..<end]).trim(character: " ")
    }

    if string.hasPrefix("{{") {
      return .variable(value: strip(), at: range)
    } else if string.hasPrefix("{%") {
      return .block(value: strip(), at: range)
    } else if string.hasPrefix("{#") {
      return .comment(value: strip(), at: range)
    }

    return .text(value: string, at: range)
  }

  /// Returns an array of tokens from a given template string.
  func tokenize() -> [Token] {
    var tokens: [Token] = []

    let scanner = Scanner(templateString)

    let map = [
      "{{": "}}",
      "{%": "%}",
      "{#": "#}",
    ]

    while !scanner.isEmpty {
      if let text = scanner.scan(until: ["{{", "{%", "{#"]) {
        if !text.1.isEmpty {
          tokens.append(createToken(string: text.1, at: scanner.range))
        }

        let end = map[text.0]!
        let result = scanner.scan(until: end, returnUntil: true)
        tokens.append(createToken(string: result, at: scanner.range))
      } else {
        tokens.append(createToken(string: scanner.content, at: scanner.range))
        scanner.content = ""
      }
    }

    return tokens
  }
  
  func tokenLine(_ token: Token) -> (content: String, number: Int, offset: String.IndexDistance) {
    var lineNumber: Int = 0
    var offset = 0
    var lineContent = ""

    for line in templateString.components(separatedBy: CharacterSet.newlines) {
      lineNumber += 1
      lineContent = line
      if let rangeOfLine = templateString.range(of: line), rangeOfLine.contains(token.range.lowerBound) {
        offset = templateString.distance(from: rangeOfLine.lowerBound, to:
          token.range.lowerBound)
        break
      }
    }

    return (lineContent, lineNumber, offset)
  }
  
}

class Scanner {
  let originalContent: String
  var content: String
  var range: Range<String.Index>
  
  init(_ content: String) {
    self.originalContent = content
    self.content = content
    range = content.startIndex..<content.startIndex
  }

  var isEmpty: Bool {
    return content.isEmpty
  }
  
  func scan(until: String, returnUntil: Bool = false) -> String {
    var index = content.startIndex

    if until.isEmpty {
      return ""
    }

    range = range.upperBound..<range.upperBound
    while index != content.endIndex {
      let substring = content.substring(from: index)
      
      if substring.hasPrefix(until) {
        let result = content.substring(to: index)

        if returnUntil {
          range = range.lowerBound..<originalContent.index(range.upperBound, offsetBy: until.characters.count)
          content = substring.substring(from: until.endIndex)
          return result + until
        }

        content = substring
        return result
      }

      index = content.index(after: index)
      range = range.lowerBound..<originalContent.index(after: range.upperBound)
    }

    content = ""
    range = "".range
    return ""
  }

  func scan(until: [String]) -> (String, String)? {
    if until.isEmpty {
      return nil
    }

    var index = content.startIndex
    range = range.upperBound..<range.upperBound
    while index != content.endIndex {
      let substring = content.substring(from: index)
      for string in until {
        if substring.hasPrefix(string) {
          let result = content.substring(to: index)
          content = substring
          return (string, result)
        }
      }

      index = content.index(after: index)
      range = range.lowerBound..<originalContent.index(after: range.upperBound)
    }

    return nil
  }
}


extension String {
  func findFirstNot(character: Character) -> String.Index? {
    var index = startIndex

    while index != endIndex {
      if character != self[index] {
        return index
      }
      index = self.index(after: index)
    }

    return nil
  }

  func findLastNot(character: Character) -> String.Index? {
    var index = self.index(before: endIndex)

    while index != startIndex {
      if character != self[index] {
        return self.index(after: index)
      }
      index = self.index(before: index)
    }

    return nil
  }

  func trim(character: Character) -> String {
    let first = findFirstNot(character: character) ?? startIndex
    let last = findLastNot(character: character) ?? endIndex
    return String(self[first..<last])
  }
  
  public func rangeLine(_ range: Range<String.Index>) -> (content: String, number: UInt, offset: String.IndexDistance) {
    var lineNumber: UInt = 0
    var offset: Int = 0
    var lineContent = ""
    
    for line in components(separatedBy: CharacterSet.newlines) {
      lineNumber += 1
      lineContent = line
      if let rangeOfLine = self.range(of: line), rangeOfLine.contains(range.lowerBound) {
        offset = distance(from: rangeOfLine.lowerBound, to:
          range.lowerBound)
        break
      }
    }
    
    return (lineContent, lineNumber, offset)
  }
}
