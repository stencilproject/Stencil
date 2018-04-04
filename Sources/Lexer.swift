import Foundation

typealias Line = (content: String, number: UInt, range: Range<String.Index>)

struct Lexer {
  let templateName: String?
  let templateString: String
  let lines: [Line]

  private static let tokenChars: [Unicode.Scalar] = ["{", "%", "#"]
  private static let tokenCharMap: [Unicode.Scalar: Unicode.Scalar] = [
    "{": "}",
    "%": "%",
    "#": "#"
  ]

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
      let trimmed = String(string.dropFirst(2).dropLast(2))
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
    while !scanner.isEmpty {
      if let (char, text) = scanner.scanForTokenStart(Lexer.tokenChars) {
        if !text.isEmpty {
          tokens.append(createToken(string: text, at: scanner.range))
        }

        guard let end = Lexer.tokenCharMap[char] else { continue }
        let result = scanner.scanForTokenEnd(end)
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

  private static let tokenStartDelimiter: Unicode.Scalar = "{"
  private static let tokenEndDelimiter: Unicode.Scalar = "}"

  init(_ content: String) {
    self.originalContent = content
    self.content = content
    range = content.startIndex..<content.startIndex
  }

  var isEmpty: Bool {
    return content.isEmpty
  }

  func scanForTokenEnd(_ tokenChar: Unicode.Scalar) -> String {
    var foundChar = false

    for (index, char) in content.unicodeScalars.enumerated() {
      if foundChar && char == Scanner.tokenEndDelimiter {
        let result = String(content.prefix(index))
        content = String(content.dropFirst(index + 1))
        range = range.upperBound..<originalContent.index(range.upperBound, offsetBy: index + 1)
        return result
      } else {
        foundChar = (char == tokenChar)
      }
    }

    content = ""
    return ""
  }

  func scanForTokenStart(_ tokenChars: [Unicode.Scalar]) -> (Unicode.Scalar, String)? {
    var foundBrace = false

    range = range.upperBound..<range.upperBound
    for (index, char) in content.unicodeScalars.enumerated() {
      if foundBrace && tokenChars.contains(char) {
        let result = String(content.prefix(index - 1))
        content = String(content.dropFirst(index - 1))
        range = range.upperBound..<originalContent.index(range.upperBound, offsetBy: index - 1)
        return (char, result)
      } else {
        foundBrace = (char == Scanner.tokenStartDelimiter)
      }
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
