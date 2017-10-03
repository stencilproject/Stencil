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

extension Range where Bound == String.Index {
  internal static var unknown: Range {
    return "".range
  }
}

extension String {
  var range: Range<String.Index> {
    return startIndex..<endIndex
  }
}

public enum Token : Equatable {
  /// A token representing a piece of text.
  case text(value: String, at: Range<String.Index>)

  /// A token representing a variable.
  case variable(value: String, at: Range<String.Index>)

  /// A token representing a comment.
  case comment(value: String, at: Range<String.Index>)

  /// A token representing a template block.
  case block(value: String, at: Range<String.Index>)

  /// Returns the underlying value as an array seperated by spaces
  public func components() -> [String] {
    switch self {
    case .block(let value, _),
         .variable(let value, _),
         .text(let value, _),
         .comment(let value, _):
      return value.smartSplit()
    }
  }

  public var contents: String {
    switch self {
    case .block(let value, _),
         .variable(let value, _),
         .text(let value, _),
         .comment(let value, _):
      return value
    }
  }
  
  public var range: Range<String.Index> {
    switch self {
    case .block(_, let range),
         .variable(_, let range),
         .text(_, let range),
         .comment(_, let range):
      return range
    }
  }
  
}


public func == (lhs: Token, rhs: Token) -> Bool {
  switch (lhs, rhs) {
  case (.text(let lhsValue), .text(let rhsValue)):
    return lhsValue == rhsValue
  case (.variable(let lhsValue), .variable(let rhsValue)):
    return lhsValue == rhsValue
  case (.block(let lhsValue), .block(let rhsValue)):
    return lhsValue == rhsValue
  case (.comment(let lhsValue), .comment(let rhsValue)):
    return lhsValue == rhsValue
  default:
    return false
  }
}
