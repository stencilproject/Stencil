import Foundation

public struct TrimBehaviour: Equatable {
  var leading: Trim
  var trailing: Trim

  public enum Trim {
    /// nothing
    case nothing

    /// tabs and spaces
    case whitespace

    /// tabs and spaces and a single new line
    case whitespaceAndOneNewLine

    /// all tabs spaces and newlines
    case whitespaceAndNewLines
  }

  public init(leading: Trim, trailing: Trim) {
    self.leading = leading
    self.trailing = trailing
  }

  /// doesn't touch newlines
  public static let nothing = TrimBehaviour(leading: .nothing, trailing: .nothing)

  /// removes whitespace before a block and whitespace and a single newline after a block
  public static let smart = TrimBehaviour(leading: .whitespace, trailing: .whitespaceAndOneNewLine)

  /// removes all whitespace and newlines before and after a block
  public static let all = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .whitespaceAndNewLines)

  static func leadingRegex(trim: Trim) -> NSRegularExpression {
    switch trim {
    case .nothing:
      fatalError("No RegularExpression for none")
    case .whitespace:
      return Self.leadingWhitespace
    case .whitespaceAndOneNewLine:
      return Self.leadingWhitespaceAndOneNewLine
    case .whitespaceAndNewLines:
      return Self.leadingWhitespaceAndNewlines
    }
  }

  static func trailingRegex(trim: Trim) -> NSRegularExpression {
    switch trim {
    case .nothing:
      fatalError("No RegularExpression for none")
    case .whitespace:
      return Self.trailingWhitespace
    case .whitespaceAndOneNewLine:
      return Self.trailingWhitespaceAndOneNewLine
    case .whitespaceAndNewLines:
      return Self.trailingWhitespaceAndNewLines
    }
  }

  // swiftlint:disable force_try
  private static let leadingWhitespaceAndNewlines = try! NSRegularExpression(pattern: "^\\s+")
  private static let trailingWhitespaceAndNewLines = try! NSRegularExpression(pattern: "\\s+$")

  private static let leadingWhitespaceAndOneNewLine = try! NSRegularExpression(pattern: "^[ \t]*\n")
  private static let trailingWhitespaceAndOneNewLine = try! NSRegularExpression(pattern: "\n[ \t]*$")

  private static let leadingWhitespace = try! NSRegularExpression(pattern: "^[ \t]*")
  private static let trailingWhitespace = try! NSRegularExpression(pattern: "[ \t]*$")
}
