public struct Lexer {
  public let templateString: String

  public init(templateString: String) {
    self.templateString = templateString
  }

  func createToken(_ string: String) -> Token {
    func strip() -> String {
        return string[string.index(string.startIndex, offsetBy: 2)..<string.index(string.endIndex, offsetBy: -2)].trim(character: " ")
    }

    if string.hasPrefix("{{") {
      return Token.variable(value: strip())
    } else if string.hasPrefix("{%") {
      return Token.block(value: strip())
    } else if string.hasPrefix("{#") {
      return Token.comment(value: strip())
    }

    return Token.text(value: string)
  }

  /// Returns an array of tokens from a given template string.
  public func tokenize() -> [Token] {
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
          tokens.append(createToken(text.1))
        }

        let end = map[text.0]!
        let result = scanner.scan(until: end, returnUntil: true)
        tokens.append(createToken(result))
      } else {
        tokens.append(createToken(scanner.content))
        scanner.content = ""
      }
    }

    return tokens
  }
}


class Scanner {
  var content: String

  init(_ content: String) {
    self.content = content
  }

  var isEmpty: Bool {
    return content.isEmpty
  }

  func scan(until: String, returnUntil: Bool = false) -> String {
    if until.isEmpty {
      return ""
    }

    var index = content.startIndex
    while index != content.endIndex {
      let substring = content[index..<content.endIndex]
      if substring.hasPrefix(until) {
        let result = content[content.startIndex..<index]
        content = substring

        if returnUntil {
          content = content[until.endIndex..<content.endIndex]
          return result + until
        }

        return result
      }

      index = content.index(after: index)
    }

    return ""
  }

  func scan(until: [String]) -> (String, String)? {
    if until.isEmpty {
      return nil
    }

    var index = content.startIndex
    while index != content.endIndex {
      let substring = content[index..<content.endIndex]
      for string in until {
        if substring.hasPrefix(string) {
          let result = content[content.startIndex..<index]
          content = substring
          return (string, result)
        }
      }

      index = content.index(after: index)
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
    return self[first..<last]
  }
}
