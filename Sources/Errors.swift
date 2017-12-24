public class TemplateDoesNotExist: Error, CustomStringConvertible {
  let templateNames: [String]
  let loader: Loader?

  public init(templateNames: [String], loader: Loader? = nil) {
    self.templateNames = templateNames
    self.loader = loader
  }

  public var description: String {
    let templates = templateNames.joined(separator: ", ")

    if let loader = loader {
      return "Template named `\(templates)` does not exist in loader \(loader)"
    }

    return "Template named `\(templates)` does not exist. No loaders found"
  }
}

public struct TemplateSyntaxError : Error, Equatable, CustomStringConvertible {
  public let description:String
  var lexeme: Lexeme?
  
  public init(_ description:String) {
    self.description = description
  }
  
  public static func ==(lhs:TemplateSyntaxError, rhs:TemplateSyntaxError) -> Bool {
    return lhs.description == rhs.description
  }
  
}

public class ErrorReporterContext {
  public let template: Template
  
  public typealias ParentContext = (context: ErrorReporterContext, token: Token)
  public let parent: ParentContext?
  
  public init(template: Template, parent: ParentContext? = nil) {
    self.template = template
    self.parent = parent
  }
}

public protocol ErrorReporter: class {
  var context: ErrorReporterContext! { get set }
  func reportError(_ error: Error) -> Error
  func contextAwareError(_ error: TemplateSyntaxError, context: ErrorReporterContext) -> Error?
}

open class SimpleErrorReporter: ErrorReporter {
  public var context: ErrorReporterContext!
  
  open func reportError(_ error: Error) -> Error {
    guard let syntaxError = error as? TemplateSyntaxError else { return error }
    guard let context = context else { return error }
    return contextAwareError(syntaxError, context: context) ?? error
  }
  
  // TODO: add stack trace using parent context
  open func contextAwareError(_ error: TemplateSyntaxError, context: ErrorReporterContext) -> Error? {
    guard let lexeme = error.lexeme, lexeme.range != .unknown else { return nil }
    let templateName = context.template.name.map({ "\($0):" }) ?? ""
    let tokenContent = context.template.templateString.substring(with: lexeme.range)
    let lexer = Lexer(templateString: context.template.templateString)
    let line = lexer.lexemeLine(lexeme)
    let highlight = "\(String(Array(repeating: " ", count: line.offset)))^\(String(Array(repeating: "~", count: max(tokenContent.length - 1, 0))))"
    let description = "\(templateName)\(line.number):\(line.offset): error: \(error.description)\n\(line.content)\n\(highlight)"
    let error = TemplateSyntaxError(description)
    return error
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
  
  var length: Int {
    #if swift(>=3.2)
      return count
    #else
      return characters.count
    #endif
  }
  
}
