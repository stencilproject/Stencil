public class TemplateDoesNotExist: Error, CustomStringConvertible {
  let templateNames: [String]
  let loader: Loader?

  public init(templateNames: [String], loader: Loader? = nil) {
    self.templateNames = templateNames
    self.loader = loader
  }

  public var description: String {
    let templates = templateNames.joined(separator: ", ")

    if let loader = loader {
      return "Template named `\(templates)` does not exist in loader \(loader)"
    }

    return "Template named `\(templates)` does not exist. No loaders found"
  }
}

public struct TemplateSyntaxError : Error, Equatable, CustomStringConvertible {
  public let description:String
  var lexeme: Lexeme?
  
  public init(_ description:String) {
    self.description = description
  }
  
  public static func ==(lhs:TemplateSyntaxError, rhs:TemplateSyntaxError) -> Bool {
    return lhs.description == rhs.description
  }
  
}

extension Range where Bound == String.Index {
  internal static var unknown: Range {
    return "".range
  }
}

extension String {
  var range: Range<String.Index> {
    return startIndex..<endIndex
  }
}
