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
  public let reason: String
  public private(set) var description: String

  public internal(set) var template: Template?
  public internal(set) var parentError: Error?

  var lexeme: Lexeme? {
    didSet {
      description = TemplateSyntaxError.description(reason: reason, lexeme: lexeme, template: template)
    }
  }
  
  static func description(reason: String, lexeme: Lexeme?, template: Template?) -> String {
    if let template = template, let range = lexeme?.range {
      let templateName = template.name.map({ "\($0):" }) ?? ""
      let tokenContent = template.templateString.substring(with: range)
      let line = template.templateString.rangeLine(range)
      let highlight = "\(String(Array(repeating: " ", count: line.offset)))^\(String(Array(repeating: "~", count: max(tokenContent.length - 1, 0))))"
      
      return "\(templateName)\(line.number):\(line.offset): error: \(reason)\n"
        + "\(line.content)\n"
        + "\(highlight)\n"
    } else {
      return reason
    }
  }

  init(reason: String, lexeme: Lexeme? = nil, template: Template? = nil, parentError: Error? = nil) {
    self.reason = reason
    self.parentError = parentError
    self.template = template
    self.lexeme = lexeme
    self.description = TemplateSyntaxError.description(reason: reason, lexeme: lexeme, template: template)
  }
  
  public init(_ description: String) {
    self.init(reason: description)
  }
  
  public static func ==(lhs:TemplateSyntaxError, rhs:TemplateSyntaxError) -> Bool {
    guard lhs.description == rhs.description else { return false }

    switch (lhs.parentError, rhs.parentError) {
    case let (lhsParent? as TemplateSyntaxError?, rhsParent? as TemplateSyntaxError?):
      return lhsParent == rhsParent
    case let (lhsParent?, rhsParent?):
      return String(describing: lhsParent) == String(describing: rhsParent)
    default:
      return lhs.parentError == nil && rhs.parentError == nil
    }
  }
  
}

public class ErrorReporterContext {
  public let template: Template
  
  public typealias ParentContext = (context: ErrorReporterContext, token: Token?)
  public let parent: ParentContext?
  
  public init(template: Template, parent: ParentContext? = nil) {
    self.template = template
    self.parent = parent
  }
}

public protocol ErrorReporter: class {
  var context: ErrorReporterContext! { get set }
  func reportError(_ error: Error) -> Error
  func renderError(_ error: Error) -> String
}

open class SimpleErrorReporter: ErrorReporter {
  public var context: ErrorReporterContext!
  
  open func reportError(_ error: Error) -> Error {
    guard let context = context else { return error }

    return TemplateSyntaxError(reason: (error as? TemplateSyntaxError)?.reason ?? "\(error)",
                               lexeme: (error as? TemplateSyntaxError)?.lexeme,
                               template: context.template,
                               parentError: (error as? TemplateSyntaxError)?.parentError
    )
  }
  
  open func renderError(_ error: Error) -> String {
    guard let templateError = error as? TemplateSyntaxError else { return error.localizedDescription }
    
    var descriptions = [templateError.description]
    
    var currentError: TemplateSyntaxError? = templateError
    while let parentError = currentError?.parentError {
      descriptions.append(renderError(parentError))
      currentError = parentError as? TemplateSyntaxError
    }
    
    return descriptions.reversed().joined(separator: "\n")
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
