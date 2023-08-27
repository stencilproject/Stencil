//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Foundation

#if os(Linux)
// swiftlint:disable:next prefixed_toplevel_constant
let NSFileNoSuchFileError = 4
#endif

/// A class representing a template
open class Template: ExpressibleByStringLiteral {
  let templateString: String
  var environment: Environment

  /// The list of parsed (lexed) tokens
  public let tokens: [Token]

  /// The name of the loaded Template if the Template was loaded from a Loader
  public let name: String?

  /// Create a template with a template string
  public required init(templateString: String, environment: Environment? = nil, name: String? = nil) {
    self.environment = environment ?? Environment()
    self.name = name
    self.templateString = templateString

    let lexer = Lexer(templateName: name, templateString: templateString)
    tokens = lexer.tokenize()
  }

  /// Create a template with the given name inside the given bundle
  @available(*, deprecated, message: "Use Environment/FileSystemLoader instead")
  public convenience init(named: String, inBundle bundle: Bundle? = nil) throws {
    let useBundle = bundle ?? Bundle.main
    guard let url = useBundle.url(forResource: named, withExtension: nil) else {
      throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
    }

    try self.init(templateString: String(contentsOf: url))
  }

  // MARK: ExpressibleByStringLiteral

  // Create a templaVte with a template string literal
  public required convenience init(stringLiteral value: String) {
    self.init(templateString: value)
  }

  // Create a template with a template string literal
  public required convenience init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(stringLiteral: value)
  }

  // Create a template with a template string literal
  public required convenience init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(stringLiteral: value)
  }

  /// Render the given template with a context
  public func render(_ context: Context) throws -> String {
    let context = context
    let parser = TokenParser(tokens: tokens, environment: context.environment)
    let nodes = try parser.parse()
    return try renderNodes(nodes, context)
  }

  // swiftlint:disable discouraged_optional_collection
  /// Render the given template
  open func render(_ dictionary: [String: Any]? = nil) throws -> String {
    try render(Context(dictionary: dictionary ?? [:], environment: environment))
  }
}
