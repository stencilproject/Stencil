import PathKit


class IncludeNode : NodeType {
  let templateName: Variable
  let includeContext: String?

  class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
    let bits = token.components()

    guard bits.count == 2 || bits.count == 3 else {
      throw TemplateSyntaxError("'include' tag requires one argument, the template file to be included. A second optional argument can be used to specify the context that will be passed to the included file")
    }

    return IncludeNode(templateName: Variable(bits[1]), includeContext: bits.count == 3 ? bits[2] : nil)
  }

  init(templateName: Variable, includeContext: String? = nil) {
    self.templateName = templateName
    self.includeContext = includeContext
  }

  func render(_ context: Context) throws -> String {
    guard let templateName = try self.templateName.resolve(context) as? String else {
      throw TemplateSyntaxError("'\(self.templateName)' could not be resolved as a string")
    }

    let template = try context.environment.loadTemplate(name: templateName)

    let subContext = includeContext.flatMap{ context[$0] as? [String: Any] }
    return try context.push(dictionary: subContext) {
      return try template.render(context)
    }
  }
}

