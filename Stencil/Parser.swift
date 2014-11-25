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

public class TokenParser {
    public typealias TagParser = (TokenParser, Token) -> Result
    public typealias NodeList = [Node]

    public enum Result {
        case Success(node: Node)
        case Error(error: StencilError)
    }

    public enum Results {
        case Success(nodes: NodeList)
        case Error(error: StencilError)
    }

    private var tokens:[Token]
    private var tags = Dictionary<String, TagParser>()

    public init(tokens:[Token]) {
        self.tokens = tokens
        registerTag("for", ForNode.parse)
        registerTag("if", IfNode.parse)
        registerTag("ifnot", IfNode.parse_ifnot)
        registerTag("now", NowNode.parse)
    }

    public func registerTag(name:String, parser:TagParser) {
        tags[name] = parser
    }

    public func registerSimpleTag(name:String, handler:((Context) -> (StencilResult))) {
        registerTag(name, parser: { (parser, token) -> TokenParser.Result in
            return .Success(node:SimpleNode(handler: handler))
        })
    }

    public func parse() -> Results {
        return parse(nil)
    }

    public func parse(parse_until:((parser:TokenParser, token:Token) -> (Bool))?) -> TokenParser.Results {
        var nodes = NodeList()

        while tokens.count > 0 {
            let token = nextToken()!

            switch token {
            case .Text(let text):
                nodes.append(TextNode(text: text))
            case .Variable(let variable):
                nodes.append(VariableNode(variable: variable))
            case .Block(let value):
                let tag = token.components().first

                if let parse_until = parse_until {
                    if parse_until(parser: self, token: token) {
                        prependToken(token)
                        return .Success(nodes:nodes)
                    }
                }

                if let tag = tag {
                    if let parser = self.tags[tag] {
                        switch parser(self, token) {
                            case .Success(let node):
                                nodes.append(node)
                            case .Error(let error):
                                return .Error(error:error)
                        }
                    }
                }
            case .Comment(let value):
                continue
            }
        }

        return .Success(nodes:nodes)
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
