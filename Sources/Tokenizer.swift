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

public struct WhitespaceBehavior: Equatable {
  public enum Behavior {
    case unspecified
    case trim
    case keep
  }
  let leading: Behavior
  let trailing: Behavior
  static func defaultBehavior() -> WhitespaceBehavior {
    return WhitespaceBehavior(leading: .unspecified, trailing: .unspecified)
  }
}

public func == (lhs: WhitespaceBehavior, rhs: WhitespaceBehavior) -> Bool {
    return (lhs.leading == rhs.leading) && (lhs.trailing == rhs.trailing)
}


public enum Token : Equatable {
  /// A token representing a piece of text.
  case text(value: String)

  /// A token representing a variable.
  case variable(value: String)

  /// A token representing a comment.
  case comment(value: String)

  /// A token representing a template block.
  case block(value: String, newline: WhitespaceBehavior)

  /// Returns the underlying value as an array seperated by spaces
  public func components() -> [String] {
    return contents.smartSplit()
  }

  public static func mkBlock(_ value: String) -> Token {
    return .block(value: value, newline: WhitespaceBehavior.defaultBehavior())
  }

  public var contents: String {
    switch self {
    case .block(let value, _):
      return value
    case .variable(let value):
      return value
    case .text(let value):
      return value
    case .comment(let value):
      return value
    }
  }
  public var whitespace: WhitespaceBehavior? {
    switch self {
    case .variable, .comment, .text: return nil
    case .block(_, let ws): return ws
    }
  }
}


public func == (lhs: Token, rhs: Token) -> Bool {
  switch (lhs, rhs) {
  case (.text(let lhsValue), .text(let rhsValue)):
    return lhsValue == rhsValue
  case (.variable(let lhsValue), .variable(let rhsValue)):
    return lhsValue == rhsValue
  case (.block(let lhsValue, let lhsBehavior), .block(let rhsValue, let rhsBehavior)):
    return (lhsValue == rhsValue) && (lhsBehavior == rhsBehavior)
  case (.comment(let lhsValue), .comment(let rhsValue)):
    return lhsValue == rhsValue
  default:
    return false
  }
}
