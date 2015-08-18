import Foundation
import PathKit

/// A class representing a template
public class Template {
  public enum Error : ErrorType {
    case TemplateDoesNotExist(name: String, inBundle: NSBundle?)
  }
  
  public let parser:TokenParser

  /// Create a template with the given name inside the given bundle
  public convenience init?(named name:String, inBundle bundle:NSBundle? = nil) throws {
    var url:NSURL?

    if let bundle = bundle {
      url = bundle.URLForResource(name, withExtension: nil)
    } else {
      url = NSBundle.mainBundle().URLForResource(name, withExtension: nil)
    }

    if let url = url {
      try self.init(URL:url)
    } else {
      throw Error.TemplateDoesNotExist(name: name, inBundle: bundle)
    }
  }

  /// Create a template with a file found at the given URL
  public convenience init(URL:NSURL) throws {
    let templateString = try NSString(contentsOfURL: URL, encoding: NSUTF8StringEncoding)
    self.init(templateString:templateString as String)
  }

  /// Create a template with a file found at the given path
  public convenience init?(path:Path) {
    if let string:String = path.read() {
      self.init(templateString:string)
    } else {
      return nil
    }
  }

  /// Create a template with a template string
  public init(templateString:String) {
    let lexer = Lexer(templateString: templateString)
    let tokens = lexer.tokenize()
    parser = TokenParser(tokens: tokens)
  }

  /// Render the given template in a context
  public func render(context:Context = Context()) throws -> String {
    let nodes = try parser.parse()
    return try renderNodes(nodes, context: context)
  }
}
