import Foundation
import PathKit

extension String : Error {
    public var description:String {
        return self
    }
}

public class IncludeNode : Node {
    public let templateName:String

    public class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
        let bits = token.contents.componentsSeparatedByString("\"")

        if bits.count != 3 {
            return .Error(error:NodeError(token: token, message: "Tag takes one argument, the template file to be included"))
        }

        return .Success(node:IncludeNode(templateName: bits[1]))
    }

    public init(templateName:String) {
        self.templateName = templateName
    }

    public func render(context: Context) -> Result {
        if let loader =  context["loader"] as? TemplateLoader {
            if let template = loader.loadTemplate(templateName) {
                return template.render(context)
            }

            let paths:String = join(", ", loader.paths.map { path in
                return path.description
            })
            let error = "Template '\(templateName)' not found in \(paths)"
            return .Error(error)
        }

        let error = "Template loader not in context"
        return .Error(error)
    }
}

