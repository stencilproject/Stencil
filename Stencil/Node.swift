import Foundation

public enum RenderError : ErrorType {
  case TemplateNotFound(name: String, paths:[String])
  case TemplateLoaderNotInContext
}

public struct ParseError : ErrorType {
  public enum Cause : ErrorType {
    case InvalidArgumentCount
    case MissingEnd
    case InvalidForSyntax
    case ExtendsUsedMoreThanOnce
  }

  let cause: Cause
  let token: Token
  let message: String
  
  public init(cause: Cause, token: Token, message: String) {
    self.cause = cause
    self.token = token
    self.message = message
  }
  
  public var _code: Int {
    return cause._code
  }
  
  public var _domain: String {
    return cause._domain
  }
  
  var description:String {
    return "\(token.components().first!): \(message)"
  }
}

public protocol Node {
  /// Return the node rendered as a string, or returns a failure
  func render(context:Context) throws -> String
}

extension Node {
  func renderTemplate(context: Context, templateName: String, @noescape render: (Context, Template) throws -> String) throws -> String {
    guard let loader = context["loader"] as? TemplateLoader else {
      throw RenderError.TemplateLoaderNotInContext
    }
    guard let template = loader.loadTemplate(templateName) else {
      let paths = loader.paths.map({ String($0) })
      throw RenderError.TemplateNotFound(name: templateName, paths: paths)
    }
    
    return try render(context, template)
  }
}

public func renderNodes(nodes:[Node], context:Context) throws -> String {
  var result = ""
  for item in nodes {
    result += try item.render(context)
  }
  return result
}

public class SimpleNode : Node {
  let handler: (Context) throws -> String

  public init(handler: (Context) throws -> String) {
    self.handler = handler
  }

  public func render(context:Context) throws -> String {
    return try handler(context)
  }
}

public class TextNode : Node {
  public let text:String

  public init(text:String) {
    self.text = text
  }

  public func render(context:Context) throws -> String {
    return self.text
  }
}

public class VariableNode : Node {
  public let variable:Variable

  public init(variable:Variable) {
    self.variable = variable
  }

  public init(variable:String) {
    self.variable = Variable(variable)
  }

  public func render(context:Context) throws -> String {
    let result:AnyObject? = variable.resolve(context)

    if let result = result as? String {
      return result
    } else if let result = result as? NSObject {
      return result.description
    }
    
    return ""
  }
}

public class NowNode : Node {
  public let format:Variable

  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    var format:Variable?

    let components = token.components()
    if components.count == 2 {
      format = Variable(components[1])
    }

    return NowNode(format:format)
  }

  public init(format:Variable?) {
    if let format = format {
      self.format = format
    } else {
      self.format = Variable("\"yyyy-MM-dd 'at' HH:mm\"")
    }
  }

  public func render(context: Context) throws -> String {
    let date = NSDate()
    let format: AnyObject? = self.format.resolve(context)
    var formatter:NSDateFormatter?

    if let format = format as? NSDateFormatter {
      formatter = format
    } else if let format = format as? String {
      formatter = NSDateFormatter()
      formatter!.dateFormat = format
    } else {
      return ""
    }

    return formatter!.stringFromDate(date)
  }
}

public class ForNode : Node {
  let variable:Variable
  let loopVariable:String
  let nodes:[Node]

  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let components = token.components()

    guard components.count == 4 && components[2] == "in" else {
        throw ParseError(cause: .InvalidForSyntax, token: token, message: "Invalid syntax. Expected `for x in y`.")
    }
    
    let loopVariable = components[1]
    let variable = components[3]
    
    let forNodes = try parser.parse(until(["endfor", "empty"]))
    
    var emptyNodes: [Node] = [Node]()
    if let token = parser.nextToken() {
      if token.contents == "empty" {
        emptyNodes = try parser.parse(until(["endfor"]))
        parser.nextToken()
      }
    } else {
      throw ParseError(cause: .MissingEnd, token: token, message: "`endfor` was not found.")
    }

    return ForNode(variable: variable, loopVariable: loopVariable, nodes: forNodes, emptyNodes:emptyNodes)
  }

  public init(variable:String, loopVariable:String, nodes:[Node], emptyNodes:[Node]) {
    self.variable = Variable(variable)
    self.loopVariable = loopVariable
    self.nodes = nodes
  }

  public func render(context: Context) throws -> String {
    let values = variable.resolve(context) as? [AnyObject]
    var output = ""

    if let values = values {
      for item in values {
        context.push()
        context[loopVariable] = item
        output += try renderNodes(nodes, context: context)
        context.pop()
      }
    }

    return output
  }
}

public class IfNode : Node {
  public let variable:Variable
  public let trueNodes:[Node]
  public let falseNodes:[Node]

  public class func parse(parser:TokenParser, token:Token) throws -> (variable: String, ifNodes: [Node], elseNodes: [Node]) {
    let variable = token.components()[1]
    
    let ifNodes = try parser.parse(until(["endif", "else"]))
    var elseNodes = [Node]()
    
    if let token = parser.nextToken() {
      if token.contents == "else" {
        elseNodes = try parser.parse(until(["endif"]))
        parser.nextToken()
      }
    } else {
      throw ParseError(cause: .MissingEnd, token: token, message: "`endif` was not found.")
    }

    return (variable, ifNodes, elseNodes)
  }
  
  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let (variable, ifNodes, elseNodes) = try parse(parser, token: token)
    return IfNode(variable: variable, trueNodes: ifNodes, falseNodes: elseNodes)
  }
  
  public class func parseIfNot(parser:TokenParser, token:Token) throws -> Node {
    let (variable, ifNodes, elseNodes) = try parse(parser, token: token)
    return IfNode(variable: variable, trueNodes: elseNodes, falseNodes: ifNodes)
  }

  public init(variable:String, trueNodes:[Node], falseNodes:[Node]) {
    self.variable = Variable(variable)
    self.trueNodes = trueNodes
    self.falseNodes = falseNodes
  }

  public func render(context: Context) throws -> String {
    let result: AnyObject? = variable.resolve(context)
    var truthy = false

    if let result = result as? [AnyObject] where result.count > 0 {
      truthy = true
    } else if let _: AnyObject = result {
      truthy = true
    }

    context.push()
    let output = try renderNodes(truthy ? trueNodes : falseNodes, context: context)
    context.pop()

    return output
  }
}
