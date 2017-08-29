import Foundation


extension String {
  /// Split a string by a separator leaving quoted phrases together
  func smartSplit(separator: Character = " ") -> [String] {
    var word = ""
    var components: [String] = []
    var separate: Character = separator
    var singleQuoteCount = 0
    var doubleQuoteCount = 0

    for character in self.characters {
      if character == "'" { singleQuoteCount += 1 }
      else if character == "\"" { doubleQuoteCount += 1 }

      if character == separate {

        if separate != separator {
          word.append(separate)
        } else if singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0 && !word.isEmpty {
          components.append(word)
          word = ""
        }

        separate = separator
      } else {
        if separate == separator && (character == "'" || character == "\"") {
          separate = character
        }
        word.append(character)
      }
    }

    if !word.isEmpty {
      components.append(word)
    }

    return components
  }
}


public enum Token : Equatable {
  /// A token representing a piece of text.
  case text(value: String, sourceMap: SourceMap)

  /// A token representing a variable.
  case variable(value: String, sourceMap: SourceMap)

  /// A token representing a comment.
  case comment(value: String, sourceMap: SourceMap)

  /// A token representing a template block.
  case block(value: String, sourceMap: SourceMap)

  /// Returns the underlying value as an array seperated by spaces
  public func components() -> [String] {
    switch self {
    case .block(let value, _):
      return value.smartSplit()
    case .variable(let value, _):
      return value.smartSplit()
    case .text(let value, _):
      return value.smartSplit()
    case .comment(let value, _):
      return value.smartSplit()
    }
  }

  public var contents: String {
    switch self {
    case .block(let value, _):
      return value
    case .variable(let value, _):
      return value
    case .text(let value, _):
      return value
    case .comment(let value, _):
      return value
    }
  }

  public var sourceMap: SourceMap {
    switch self {
    case .block(_, let sourceMap):
      return sourceMap
    case .variable(_, let sourceMap):
      return sourceMap
    case .text(_, let sourceMap):
      return sourceMap
    case .comment(_, let sourceMap):
      return sourceMap
    }
  }
}


public func == (lhs: Token, rhs: Token) -> Bool {
  switch (lhs, rhs) {
  case (.text(let lhsValue, let lhsSourceMap), .text(let rhsValue, let rhsSourceMap)):
    return lhsValue == rhsValue && lhsSourceMap == rhsSourceMap
  case (.variable(let lhsValue, let lhsSourceMap), .variable(let rhsValue, let rhsSourceMap)):
    return lhsValue == rhsValue && lhsSourceMap == rhsSourceMap
  case (.block(let lhsValue, let lhsSourceMap), .block(let rhsValue, let rhsSourceMap)):
    return lhsValue == rhsValue && lhsSourceMap == rhsSourceMap
  case (.comment(let lhsValue, let lhsSourceMap), .comment(let rhsValue, let rhsSourceMap)):
    return lhsValue == rhsValue && lhsSourceMap == rhsSourceMap
  default:
    return false
  }
}
