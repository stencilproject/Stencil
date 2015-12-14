import PathKit


public class IncludeNode : NodeType {
  public let templateName: Variable

  public class func parse(parser: TokenParser, token: Token) throws -> NodeType {
    let bits = token.components()

    guard bits.count == 2 else {
      throw StencilError.TemplateSyntaxError("'include' tag takes one argument, the template file to be included")
    }

    return IncludeNode(templateName: Variable(bits[1]))
  }

  public init(templateName: Variable) {
    self.templateName = templateName
  }

  public func render(context: Context) throws -> String {
    guard let loader = context["loader"] as? TemplateLoader else {
      throw StencilError.TemplateSyntaxError("Template loader not in context")
    }

    guard let templateName = try self.templateName.resolve(context) as? String else {
      throw StencilError.TemplateSyntaxError("'\(self.templateName)' could not be resolved as a string")
    }

    guard let template = loader.loadTemplate(templateName) else {
      let paths = loader.paths.map { $0.description }.joinWithSeparator(", ")
      throw StencilError.TemplateSyntaxError("'\(templateName)' template not found in \(paths)")
    }

    return try template.render(context)
  }
}

