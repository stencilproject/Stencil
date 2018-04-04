struct Lexer {
  let templateString: String

  init(templateString: String) {
    self.templateString = templateString
  }

  func createToken(string: String) -> Token {
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

    if string.hasPrefix("{{") {
      return .variable(value: strip())
    } else if string.hasPrefix("{%") {
      return .block(value: strip())
    } else if string.hasPrefix("{#") {
      return .comment(value: strip())
    }

    return .text(value: string)
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
      if let text = scanner.scanForTokenStart() {
        if !text.1.isEmpty {
          tokens.append(createToken(string: text.1))
        }

        let end = map[text.0]!
        let result = scanner.scan(until: end, returnUntil: true)
        tokens.append(createToken(string: result))
      } else {
        tokens.append(createToken(string: scanner.content))
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
    guard let first = until.unicodeScalars.first else {
      return ""
    }

    var index = 0;
    for char in content.unicodeScalars {
      if char == first {
        //Check the rest
        let startIndex = content.startIndex.advanced(by: index)
        if String(content[startIndex..<content.startIndex.advanced(by: index + until.count)]) == until {
          let result = String(content[..<startIndex])
          content = String(content[startIndex...])
          if returnUntil {
            content = String(content[content.startIndex.advanced(by: until.count)...])
            return result + until
          }
          return result
        }
      }
      index += 1
    }

    content = ""
    return ""
  }
  func scanForTokenStart() -> (String, String)? {
    var foundBrace = false
    var index = 0;
    for char in content.unicodeScalars {
      if foundBrace {
        let string:String
        switch char {
          case "{":
            string = "{{"
          case "%":
            string = "{%"
          case "#":
            string = "{#"
          default:
            foundBrace = false
            index += 2
            continue;
        }
        let startIndex = content.startIndex.advanced(by: index)
        let result = String(content[..<startIndex])
        content = String(content[startIndex...])
        return (string, result)
      } else {
        if char == "{" {
          //Check next char
          foundBrace = true
        } else {
          index += 1
        }
      }
    }    
    return nil;
  }

  func scan(until: [String]) -> (String, String)? {
    if until.isEmpty {
      return nil
    }

    var index = content.startIndex
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
