public struct Environment {
  var namespace: Namespace

  public var loader: Loader?

  public init(loader: Loader? = nil, namespace: Namespace? = nil) {
    self.loader = loader
    self.namespace = namespace ?? Namespace()
  }

  public func loadTemplate(name: String) throws -> Template {
    if let loader = loader {
      return try loader.loadTemplate(name: name, environment: self)
    } else {
      throw TemplateDoesNotExist(templateNames: [name], loader: nil)
    }
  }

  public func loadTemplate(names: [String]) throws -> Template {
    if let loader = loader {
      return try loader.loadTemplate(names: names, environment: self)
    } else {
      throw TemplateDoesNotExist(templateNames: names, loader: nil)
    }
  }

  public func renderTemplate(name: String, context: [String: Any]? = nil) throws -> String {
    let template = try loadTemplate(name: name)
    return try template.render(context)
  }

  public func renderTemplate(string: String, context: [String: Any]? = nil) throws -> String {
    let template = Template(templateString: string, environment: self)
    return try template.render(context)
  }
}
