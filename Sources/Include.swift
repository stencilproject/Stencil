import PathKit


class IncludeNode : NodeType {
  let templateName: Variable
  let token: Token?

  class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
    let bits = token.components()

    guard bits.count == 2 else {
      throw TemplateSyntaxError("'include' tag takes one argument, the template file to be included")
    }

    return IncludeNode(templateName: Variable(bits[1]), token: token)
  }

  init(templateName: Variable, token: Token) {
    self.templateName = templateName
    self.token = token
  }

  func render(_ context: Context) throws -> String {
    guard let templateName = try self.templateName.resolve(context) as? String else {
      throw TemplateSyntaxError("'\(self.templateName)' could not be resolved as a string")
    }

    let template = try context.environment.loadTemplate(name: templateName)

    do {
      return try context.environment.pushTemplate(template, token: token) {
        try context.push {
          return try template.render(context)
        }
      }
    } catch {
      if let parentError = error as? TemplateSyntaxError {
        throw TemplateSyntaxError(reason: parentError.reason, parentError: parentError)
      } else {
        throw error
      }
    }
  }
}

