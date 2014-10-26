import Foundation

public class Template {
    let parser:TokenParser

    public convenience init?(named:String) {
        self.init(named:named, inBundle:nil)
    }

    public convenience init?(named:String, inBundle bundle:NSBundle?) {
        var url:NSURL?

        if let bundle = bundle {
            url = bundle.URLForResource(named, withExtension: nil)
        } else {
            url = NSBundle.mainBundle().URLForResource(named, withExtension: nil)
        }

        self.init(URL:url!)
    }

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

    public init(templateString:String) {
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()
        parser = TokenParser(tokens: tokens)
    }

    public func render(context:Context) -> Result {
        switch parser.parse() {
            case .Success(let nodes):
                let (result, error) = renderNodes(nodes, context)
                if let result = result {
                    return .Success(string:result)
                } else if let error = error {
                    return .Error(error:error)
                }
                return .Success(string:"")

            case .Error(let error):
                return .Error(error:error)
        }
    }
}
