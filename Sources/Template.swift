import Foundation

#if os(Linux)
let NSFileNoSuchFileError = 4
#endif

/// A class representing a template
open class Template: ExpressibleByStringLiteral {
  let templateString: String
  internal(set) var environment: Environment
  let tokens: [Token]

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

  // MARK: ExpressibleByStringLiteral

  // Create a templaVte with a template string literal
  public convenience required init(stringLiteral value: String) {
    self.init(templateString: value)
  }

  // Create a template with a template string literal
  public convenience required init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(stringLiteral: value)
  }

  // Create a template with a template string literal
  public convenience required init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(stringLiteral: value)
  }

  /// Render the given template with a context
  func render(_ context: Context) throws -> String {
    let context = context
    let parser = TokenParser(tokens: tokens, environment: context.environment)
    let nodes = try parser.parse()
    return try renderNodes(nodes, context)
  }

  /// Render the given template
  open func render(_ dictionary: [String: Any]? = nil) throws -> String {
    return try render(Context(dictionary: dictionary, environment: environment))
  }
}
