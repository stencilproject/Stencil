import Foundation

/// A structure used to represent a template variable, and to resolve it in a given context.
struct LookupParser {
  private var bits = [String]()
  private var current = ""
  private var partialBits = [String]()
  private var referenceLevel = 0

  let variable: String
  let context: Context

  // Split the lookup string and resolve references if possible
  init(_ variable: String, in context: Context) {
    self.variable = variable
    self.context = context
  }

  mutating func parse() throws -> [String] {
    defer {
      bits = []
      current = ""
      partialBits = []
      referenceLevel = 0
    }

    for c in variable {
      switch c {
      case "." where referenceLevel == 0:
        try foundSeparator()
      case "[":
        try openBracket()
      case "]":
        try closeBracket()
      default:
        current.append(c)
      }
    }
    try finish()

    return bits
  }

  private mutating func foundSeparator() throws {
    if !current.isEmpty {
      partialBits.append(current)
    }

    guard !partialBits.isEmpty else {
      throw TemplateSyntaxError("Attempting to dereference empty object in variable '\(variable)'")
    }

    bits += partialBits
    current = ""
    partialBits = []
  }

  // when opening the first bracket, we must have a partial bit
  private mutating func openBracket() throws {
    guard !partialBits.isEmpty || !current.isEmpty else {
      throw TemplateSyntaxError("Attempting to dereference an empty object in variable '\(variable)'")
    }

    if referenceLevel > 0 {
      current.append("[")
    } else if !current.isEmpty {
      partialBits.append(current)
      current = ""
    }

    referenceLevel += 1
  }

  // for a closing bracket at root level, try to resolve the reference
  private mutating func closeBracket() throws {
    guard referenceLevel > 0 else {
      throw TemplateSyntaxError("Unbalanced brackets in variable '\(variable)'")
    }

    if referenceLevel > 1 {
      current.append("]")
    } else if !current.isEmpty,
      let value = try Variable(current).resolve(context) {
      partialBits.append("\(value)")
      current = ""
    } else {
      throw TemplateSyntaxError("Unable to resolve reference '\(current)' in variable '\(variable)'")
    }

    referenceLevel -= 1
  }

  private mutating func finish() throws {
    // check if we have a last piece
    if !current.isEmpty {
      partialBits.append(current)
    }
    bits += partialBits

    guard referenceLevel == 0 else {
      throw TemplateSyntaxError("Unbalanced brackets in variable '\(variable)'")
    }
  }
}
