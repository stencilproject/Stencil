import Foundation


public protocol Loader {
  func loadTemplate(name: String, environment: Environment) throws -> Template
  func loadTemplate(names: [String], environment: Environment) throws -> Template
}


extension Loader {
  public func loadTemplate(names: [String], environment: Environment) throws -> Template {
    for name in names {
      do {
        return try loadTemplate(name: name, environment: environment)
      } catch is TemplateDoesNotExist {
        continue
      } catch {
        throw error
      }
    }

    throw TemplateDoesNotExist(templateNames: names, loader: self)
  }
}


public class DictionaryLoader: Loader {
  public let templates: [String: String]

  public init(templates: [String: String]) {
    self.templates = templates
  }

  public func loadTemplate(name: String, environment: Environment) throws -> Template {
    if let content = templates[name] {
      return environment.templateClass.init(templateString: content, environment: environment, name: name)
    }

    throw TemplateDoesNotExist(templateNames: [name], loader: self)
  }

  public func loadTemplate(names: [String], environment: Environment) throws -> Template {
    for name in names {
      if let content = templates[name] {
        return environment.templateClass.init(templateString: content, environment: environment, name: name)
      }
    }

    throw TemplateDoesNotExist(templateNames: names, loader: self)
  }
}
