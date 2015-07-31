import Foundation
import PathKit

public class IncludeNode : Node {
  public let templateName:String

  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let bits = token.contents.componentsSeparatedByString("\"")

    guard bits.count == 3 else {
      throw ParseError(cause: .InvalidArgumentCount, token: token, message: "Tag takes one argument, the template file to be included")
    }

    return IncludeNode(templateName: bits[1])
  }

  public init(templateName:String) {
    self.templateName = templateName
  }

  public func render(context: Context) throws -> String {
    return try renderTemplate(context, templateName: templateName) { (context, template) in
      return try template.render(context)
    }
  }
}

