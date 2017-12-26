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
  public var description: String { return reason }
  public internal(set) var token: Token?
  public internal(set) var template: Template?
  public internal(set) var parentError: Error?
  
  public init(reason: String, token: Token? = nil, template: Template? = nil, parentError: Error? = nil) {
    self.reason = reason
    self.parentError = parentError
    self.template = template
    self.token = token
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
                               token: (error as? TemplateSyntaxError)?.token,
                               template: (error as? TemplateSyntaxError)?.template ?? context.template,
                               parentError: (error as? TemplateSyntaxError)?.parentError
    )
  }
  
  open func renderError(_ error: Error) -> String {
    guard let templateError = error as? TemplateSyntaxError else { return error.localizedDescription }
    
    let description: String
    if let template = templateError.template, let token = templateError.token {
      let templateName = template.name.map({ "\($0):" }) ?? ""
      let range = template.templateString.range(of: token.contents, range: token.range) ?? token.range
      let line = template.templateString.rangeLine(range)
      let highlight = "\(String(Array(repeating: " ", count: line.offset)))^\(String(Array(repeating: "~", count: max(token.contents.characters.count - 1, 0))))"
      
      description = "\(templateName)\(line.number):\(line.offset): error: \(templateError.reason)\n"
        + "\(line.content)\n"
        + "\(highlight)\n"
    } else {
      description = templateError.reason
    }
    
    var descriptions = [description]
    
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
}
