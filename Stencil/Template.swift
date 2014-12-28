import Foundation
import PathKit

/// A class representing a template
public class Template {
    public let parser:TokenParser

    /// Create a template with the given name inside the main bundle
    public convenience init?(named:String) {
        self.init(named:named, inBundle:nil)
    }

    /// Create a template with the given name inside the given bundle
    public convenience init?(named:String, inBundle bundle:NSBundle?) {
        var url:NSURL?

        if let bundle = bundle {
            url = bundle.URLForResource(named, withExtension: nil)
        } else {
            url = NSBundle.mainBundle().URLForResource(named, withExtension: nil)
        }

        self.init(URL:url!)
    }

    /// Create a template with a file found at the given URL
    public convenience init?(URL:NSURL) {
        var error:NSError?
        let maybeTemplateString = NSString(contentsOfURL: URL, encoding: NSUTF8StringEncoding, error: &error)
        if let templateString = maybeTemplateString {
            self.init(templateString:templateString)
        } else {
            self.init(templateString:"")
            return nil
        }
    }

    /// Create a template with a file found at the given path
    public convenience init?(path:Path) {
        var error:NSError?

        if let string:String = path.read() {
            self.init(templateString:string)
        } else {
            self.init(templateString:"")
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
    public func render(context:Context) -> Result {
        switch parser.parse() {
            case .Success(let nodes):
                return renderNodes(nodes, context)

            case .Error(let error):
                return .Error(error)
        }
    }

    /// Render the given template without a context
    public func render() -> Result {
        let context = Context()
        return render(context)
    }
}
