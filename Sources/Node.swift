import Foundation


public struct TemplateSyntaxError : Error, Equatable, CustomStringConvertible {
  public let description:String

  public init(_ description:String) {
    self.description = description
  }
}


public func ==(lhs:TemplateSyntaxError, rhs:TemplateSyntaxError) -> Bool {
  return lhs.description == rhs.description
}


public protocol NodeType {
  /// Render the node in the given context
  func render(_ context:Context) throws -> String
}


/// Render the collection of nodes in the given context
public func renderNodes(_ nodes:[NodeType], _ context:Context) throws -> String {
  return try nodes.map { try $0.render(context) }.joined(separator: "")
}

public class SimpleNode : NodeType {
  public let handler:(Context) throws -> String

  public init(handler: @escaping (Context) throws -> String) {
    self.handler = handler
  }

  public func render(_ context: Context) throws -> String {
    return try handler(context)
  }
}

#if os(Linux)
  #if swift(>=3.1)
  #else
    typealias NSRegularExpression = RegularExpression
  #endif
#endif


public class TextNode : NodeType {
  private static let leadingWhiteSpace = try! NSRegularExpression(pattern: "^\\s+", options: [])
  private static let trailingWhiteSpace = try! NSRegularExpression(pattern: "\\s+$", options: [])
  public struct TrimBehavior {
    let trimLeft: Bool
    let trimRight: Bool
  }
  public let text:String
  public let trimBehavior:TrimBehavior

  public init(text:String, tBehavior:TrimBehavior = TrimBehavior(trimLeft: false, trimRight: false)) {
    self.text = text
    self.trimBehavior = tBehavior
  }

  public func render(_ context:Context) throws -> String {
    var string = self.text
    if trimBehavior.trimLeft {
      let range = NSMakeRange(0, string.characters.count)
      string = TextNode.leadingWhiteSpace.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
    }
    if trimBehavior.trimRight {
      let range = NSMakeRange(0, string.characters.count)
      string = TextNode.trailingWhiteSpace.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
    }
    return string
  }
}

extension TextNode.TrimBehavior: Equatable {}
public func == (lhs: TextNode.TrimBehavior, rhs: TextNode.TrimBehavior) -> Bool {
  return (lhs.trimLeft == rhs.trimLeft) && (lhs.trimRight == rhs.trimRight)
}


public protocol Resolvable {
  func resolve(_ context: Context) throws -> Any?
}


public class VariableNode : NodeType {
  public let variable: Resolvable

  public init(variable: Resolvable) {
    self.variable = variable
  }

  public init(variable: String) {
    self.variable = Variable(variable)
  }

  public func render(_ context: Context) throws -> String {
    let result = try variable.resolve(context)
    return stringify(result)
  }
}


func stringify(_ result: Any?) -> String {
  if let result = result as? String {
    return result
  } else if let result = result as? CustomStringConvertible {
    return result.description
  } else if let result = result as? NSObject {
    return result.description
  }

  return ""
}
