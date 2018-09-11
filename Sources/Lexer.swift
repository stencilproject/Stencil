import Foundation

typealias Line = (content: String, number: UInt, range: Range<String.Index>)

struct Lexer {
  let templateName: String?
  let templateString: String
  let lines: [Line]

  init(templateName: String? = nil, templateString: String) {
    self.templateName = templateName
    self.templateString = templateString

    self.lines = templateString.components(separatedBy: .newlines).enumerated().compactMap {
      guard !$0.element.isEmpty else { return nil }
      return (content: $0.element, number: UInt($0.offset + 1), templateString.range(of: $0.element)!)
    }
  }

  func createToken(string: String, at range: Range<String.Index>) -> Token {
    func strip() -> String {
      guard string.count > 4 else { return "" }
      let start = string.index(string.startIndex, offsetBy: 2)
      let end = string.index(string.endIndex, offsetBy: -2)
      let trimmed = String(string[start..<end])
        .components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
        .map({ $0.trim(character: " ") })
        .joined(separator: " ")
      return trimmed
    }

    if string.hasPrefix("{{") || string.hasPrefix("{%") || string.hasPrefix("{#") {
      let value = strip()
      let range = templateString.range(of: value, range: range) ?? range
      let location = rangeLocation(range)
      let sourceMap = SourceMap(filename: templateName, location: location)

      if string.hasPrefix("{{") {
        return .variable(value: value, at: sourceMap)
      } else if string.hasPrefix("{%") {
        return .block(value: value, at: sourceMap)
      } else if string.hasPrefix("{#") {
        return .comment(value: value, at: sourceMap)
      }
    }

    let location = rangeLocation(range)
    let sourceMap = SourceMap(filename: templateName, location: location)
    return .text(value: string, at: sourceMap)
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

  func rangeLocation(_ range: Range<String.Index>) -> ContentLocation {
    guard let line = self.lines.first(where: { $0.range.contains(range.lowerBound) }) else {
      return ("", 0, 0)
    }
    let offset = templateString.distance(from: line.range.lowerBound, to: range.lowerBound)
    return (line.content, line.number, offset)
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
      let substring = String(content[index...])

      if substring.hasPrefix(until) {
        let result = String(content[..<index])

        if returnUntil {
          range = range.lowerBound..<originalContent.index(range.upperBound, offsetBy: until.count)
          content = String(substring[until.endIndex...])
          return result + until
        }

        content = substring
        return result
      }

      index = content.index(after: index)
      range = range.lowerBound..<originalContent.index(after: range.upperBound)
    }

    content = ""
    return ""
  }

  func scan(until: [String]) -> (String, String)? {
    if until.isEmpty {
      return nil
    }

    var index = content.startIndex
    range = range.upperBound..<range.upperBound
    while index != content.endIndex {
      let substring = String(content[index...])
      for string in until {
        if substring.hasPrefix(string) {
          let result = String(content[..<index])
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
}

public typealias ContentLocation = (content: String, lineNumber: UInt, lineOffset: Int)
