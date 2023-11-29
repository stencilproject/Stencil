//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

/// Container for environment data, such as registered extensions
public struct Environment {
  /// The class for loading new templates
  public let templateClass: Template.Type
  /// List of registered extensions
  public var extensions: [Extension]
  /// How to handle whitespace
  public var trimBehaviour: TrimBehaviour
  /// Mechanism for loading new files
  public var loader: Loader?
  /// Already loaded templates
  public var loadedTemplates = [String: Template]()
  /// Basic initializer
  ///
  /// - Parameters:
  ///  - loader: Mechanism for loading new files
  ///  - extensions: List of extension containers
  ///  - templateClass: Class for newly loaded templates
  ///  - trimBehaviour: How to handle whitespace
  public init(
    loader: Loader? = nil,
    extensions: [Extension] = [],
    templateClass: Template.Type = Template.self,
    trimBehaviour: TrimBehaviour = .nothing
  ) {
    self.templateClass = templateClass
    self.loader = loader
    self.extensions = extensions + [DefaultExtension()]
    self.trimBehaviour = trimBehaviour
  }

  /// Load a template with the given name
  ///
  /// - Parameters:
  ///  - name: Name of the template
  /// - returns: Loaded template instance
  public mutating func loadTemplate(name: String) throws -> Template {
    if let template = loadedTemplates[name] {
        return template
    }
    else if let loader = loader {
      let result = try loader.loadTemplate(name: name, environment: self)
      loadedTemplates[name] = result
      return result
    } else {
      throw TemplateDoesNotExist(templateNames: [name], loader: nil)
    }
  }

  /// Load a template with the given names
  ///
  /// - Parameters:
  ///  - names: Names of the template
  /// - returns: Loaded template instance
  public func loadTemplate(names: [String]) throws -> Template {
    if let loader = loader {
      return try loader.loadTemplate(names: names, environment: self)
    } else {
      throw TemplateDoesNotExist(templateNames: names, loader: nil)
    }
  }

  /// Render a template with the given name, providing some data
  ///
  /// - Parameters:
  ///  - name: Name of the template
  ///  - context: Data for rendering
  /// - returns: Rendered output
  public mutating func renderTemplate(name: String, context: [String: Any] = [:]) throws -> String {
    let template = try loadTemplate(name: name)
    return try render(template: template, context: context)
  }

  /// Render the given template string, providing some data
  ///
  /// - Parameters:
  ///  - string: Template string
  ///  - context: Data for rendering
  /// - returns: Rendered output
  public func renderTemplate(string: String, context: [String: Any] = [:]) throws -> String {
    let template = templateClass.init(templateString: string, environment: self)
    return try render(template: template, context: context)
  }

  func render(template: Template, context: [String: Any]) throws -> String {
    // update template environment as it can be created from string literal with default environment
    template.environment = self
    return try template.render(context)
  }
}
