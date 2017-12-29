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

    return smartJoin(components)
  }
}

// joins back components around characters used in variables lists and filters
private func smartJoin(_ components: [String]) -> [String] {
  var joinedComponents = components
  // convert ["a", "|", "b"] and ["a|", "b"] to ["a|b"]
  // do not allow ["a", "|b"]
  for char in [",", "|", ":"] {
    while let index = joinedComponents.index(of: char) {
      if index > 0 {
        joinedComponents[index-1] += char

        if joinedComponents.count > index + 1 {
          joinedComponents[index-1] += joinedComponents[index+1]
          joinedComponents.remove(at: index+1)
        }
      }
      joinedComponents.remove(at: index)
    }
    while let index = joinedComponents.index(where: { $0.hasSuffix(char) }) {
      if joinedComponents.count > index {
        joinedComponents[index] += joinedComponents[index+1]
        joinedComponents.remove(at: index+1)
      }
    }
  }
  return joinedComponents
}


public enum Token : Equatable {
  /// A token representing a piece of text.
  case text(value: String)

  /// A token representing a variable.
  case variable(value: String)

  /// A token representing a comment.
  case comment(value: String)

  /// A token representing a template block.
  case block(value: String)

  /// Returns the underlying value as an array seperated by spaces
  public func components() -> [String] {
    switch self {
    case .block(let value):
      return value.smartSplit()
    case .variable(let value):
      return value.smartSplit()
    case .text(let value):
      return value.smartSplit()
    case .comment(let value):
      return value.smartSplit()
    }
  }

  public var contents: String {
    switch self {
    case .block(let value):
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
  case (.block(let lhsValue), .block(let rhsValue)):
    return lhsValue == rhsValue
  case (.comment(let lhsValue), .comment(let rhsValue)):
    return lhsValue == rhsValue
  default:
    return false
  }
}
