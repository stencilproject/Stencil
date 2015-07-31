import Foundation

public func until(tags:[String])(parser:TokenParser, token:Token) -> Bool {
  if let name = token.components().first {
    for tag in tags {
      if name == tag {
        return true
      }
    }
  }

  return false
}

/// A class for parsing an array of tokens and converts them into a collection of Node's
public class TokenParser {
  public typealias TagParser = (TokenParser, Token) throws -> Node
  public typealias NodeList = [Node]

  private var tokens:[Token]
  private var tags = Dictionary<String, TagParser>()

  public init(tokens:[Token]) {
    self.tokens = tokens
    registerTag("for", parser: ForNode.parse)
    registerTag("if", parser: IfNode.parse)
    registerTag("ifnot", parser: IfNode.parseIfNot)
    registerTag("now", parser: NowNode.parse)
    registerTag("include", parser: IncludeNode.parse)
    registerTag("extends", parser: ExtendsNode.parse)
    registerTag("block", parser: BlockNode.parse)
  }

  /// Registers a new template tag
  public func registerTag(name:String, parser:TagParser) {
    tags[name] = parser
  }

  /// Registers a simple template tag with a name and a handler
  public func registerSimpleTag(name:String, handler: (Context) throws -> String) {
    registerTag(name, parser: { (parser, token) throws -> Node in
      return SimpleNode(handler: handler)
    })
  }

  /// Parse the given tokens into nodes until a matching node
  public func parse(until:((parser:TokenParser, token:Token) -> (Bool))? = nil) throws -> [Node] {
    var nodes = NodeList()

    while let token = nextToken() {
      switch token {
      case .Text(let text):
        nodes.append(TextNode(text: text))
      case .Variable(let variable):
        nodes.append(VariableNode(variable: variable))
      case .Block(_):
        let tag = token.components().first

        if let until = until {
          if until(parser: self, token: token) {
            prependToken(token)
            return nodes
          }
        }

        if let tag = tag {
          if let parser = self.tags[tag] {
            nodes.append(try parser(self, token))
          }
        }
      case .Comment(_):
        continue
      }
    }

    return nodes
  }

  public func nextToken() -> Token? {
    if tokens.count > 0 {
      return tokens.removeAtIndex(0)
    }

    return nil
  }

  public func prependToken(token:Token) {
    tokens.insert(token, atIndex: 0)
  }
}
