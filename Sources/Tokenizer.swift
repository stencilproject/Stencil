import Foundation


extension String {
  /// Split a string by a separator leaving quoted phrases together
  func smartSplit(separator: Character = " ") -> [String] {
    var word = ""
    var components: [String] = []
    var separate: Character = separator

    for character in self.characters {
      if character == separate {
        if separate != separator {
          word.append(separate)
        }

        if !word.isEmpty {
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
  enum Behavior {
    case unspecified
    case trim
    case keep
  }
  let left: Behavior
  let right: Behavior
  static func defaultBehavior() -> WhitespaceBehavior {
    return WhitespaceBehavior(left: .unspecified, right: .unspecified)
  }
}

public func == (lhs: WhitespaceBehavior, rhs: WhitespaceBehavior) -> Bool {
    return (lhs.left == rhs.left) && (lhs.right == rhs.right)
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
