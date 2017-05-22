import PathKit


class IncludeNode : NodeType, Indented {
  let templateName: Variable
  let includeContext: String?
  var indent: String = ""

  class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
    let bits = token.components()

    guard bits.count == 2 || (bits.count == 4 && bits[2] == "using") else {
      throw TemplateSyntaxError("'include' tag requires one argument, the template file to be included. Another optional argument can be used to specify the context that will be passed to the included file, using the format \"using myContext\"")
    }

    return IncludeNode(templateName: Variable(bits[1]), includeContext: bits.count == 4 ? bits[3] : nil)
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
      var content = try template.render(context)
      if !indent.isEmpty {
        content = content.replacingOccurrences(of: "\n", with: "\n\(indent)")
      }
      return content
    }
  }
}

