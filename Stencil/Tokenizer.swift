import Foundation

public enum Token : Equatable {
  /// A token representing a piece of text.
  case Text(value: String)

  /// A token representing a variable.
  case Variable(value: String)

  /// A token representing a comment.
  case Comment(value: String)

  /// A token representing a template block.
  case Block(value: String)

  /// Returns the underlying value as an array seperated by spaces
  public func components() -> [String] {
    switch self {
    case .Block(let value):
      return value.splitAndTrimWhitespace(" ", respectQuotes: true)
    case .Variable(let value):
        return value.splitAndTrimWhitespace(" ", respectQuotes: true)
    case .Text(let value):
        return value.splitAndTrimWhitespace(" ", respectQuotes: true)
    case .Comment(let value):
        return value.splitAndTrimWhitespace(" ", respectQuotes: true)
    }
  }

  public var contents: String {
    switch self {
    case .Block(let value):
      return value
    case .Variable(let value):
      return value
    case .Text(let value):
      return value
    case .Comment(let value):
      return value
    }
  }
}


public func == (lhs: Token, rhs: Token) -> Bool {
  switch (lhs, rhs) {
  case (.Text(let lhsValue), .Text(let rhsValue)):
    return lhsValue == rhsValue
  case (.Variable(let lhsValue), .Variable(let rhsValue)):
    return lhsValue == rhsValue
  case (.Block(let lhsValue), .Block(let rhsValue)):
    return lhsValue == rhsValue
  case (.Comment(let lhsValue), .Comment(let rhsValue)):
    return lhsValue == rhsValue
  default:
    return false
  }
}
