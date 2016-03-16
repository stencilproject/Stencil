import PathKit


public class IncludeNode : NodeType {
  public let templateName: Variable
  private let namespace: Namespace

  public class func parse(parser: TokenParser, token: Token) throws -> NodeType {
    let bits = token.components()

    guard bits.count == 2 else {
      throw TemplateSyntaxError("'include' tag takes one argument, the template file to be included")
    }

    return IncludeNode(templateName: Variable(bits[1]), namespace: parser.namespace)
  }

  public init(templateName: Variable, namespace: Namespace) {
    self.templateName = templateName
    self.namespace = namespace
  }

  public func render(context: Context) throws -> String {
    guard let loader = context["loader"] as? TemplateLoader else {
      throw TemplateSyntaxError("Template loader not in context")
    }

    guard let templateName = try self.templateName.resolve(context) as? String else {
      throw TemplateSyntaxError("'\(self.templateName)' could not be resolved as a string")
    }

    guard let template = loader.loadTemplate(templateName) else {
      let paths = loader.paths.map { $0.description }.joinWithSeparator(", ")
      throw TemplateSyntaxError("'\(templateName)' template not found in \(paths)")
    }

    return try template.render(context, namespace: self.namespace)
  }
}

