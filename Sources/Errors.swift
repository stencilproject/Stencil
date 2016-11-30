public class TemplateDoesNotExist: Error, CustomStringConvertible {
  let templateNames: [String]
  let loader: Loader

  public init(templateNames: [String], loader: Loader) {
    self.templateNames = templateNames
    self.loader = loader
  }

  public var description: String {
    let templates = templateNames.joined(separator: ", ")
    return "Template named `\(templates)` does not exist in loader \(loader)"
  }
}
