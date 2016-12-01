import Foundation
import PathKit

#if os(Linux)
let NSFileNoSuchFileError = 4
#endif

/// A class representing a template
public class Template: ExpressibleByStringLiteral {
  let environment: Environment
  let tokens: [Token]

  /// The name of the loaded Template if the Template was loaded from a Loader
  public let name: String?

  /// Create a template with a template string
  public init(templateString: String, environment: Environment? = nil, name: String? = nil) {
    self.environment = environment ?? Environment()
    self.name = name

    let lexer = Lexer(templateString: templateString)
    tokens = lexer.tokenize()
  }

  /// Create a template with the given name inside the given bundle
  public convenience init(named:String, inBundle bundle:Bundle? = nil) throws {
    let useBundle = bundle ??  Bundle.main
    guard let url = useBundle.url(forResource: named, withExtension: nil) else {
      throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
    }

    try self.init(URL:url)
  }

  /// Create a template with a file found at the given URL
  public convenience init(URL:Foundation.URL) throws {
    try self.init(path: Path(URL.path))
  }

  /// Create a template with a file found at the given path
  public convenience init(path: Path, environment: Environment? = nil, name: String? = nil) throws {
    self.init(templateString: try path.read(), environment: environment, name: name)
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
    let context = context ?? Context(environment: environment)
    let parser = TokenParser(tokens: tokens, namespace: context.namespace)
    let nodes = try parser.parse()
    return try renderNodes(nodes, context)
  }

  /// Render the given template
  public func render(_ dictionary: [String: Any]? = nil) throws -> String {
    return try render(Context(dictionary: dictionary, environment: environment))
  }
}
