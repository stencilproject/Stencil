import Foundation

struct NodeError : StencilError {
    let token:Token
    let message:String

    init(token:Token, message:String) {
        self.token = token
        self.message = message
    }

    var description:String {
        return "\(token.components().first!): \(message)"
    }
}

public protocol Node {
    func render(context:Context) -> StencilResult
}

extension Array {
    func map<U>(block:((Element) -> (U?, StencilError?))) -> ([U]?, StencilError?) {
        var results = [U]()

        for item in self {
            let (result, error) = block(item)

            if let error = error {
                return (nil, error)
            } else if (result != nil) {
                // let result = result exposing a bug in the Swift compier :(
                results.append(result!)
            }
        }

        return (results, nil)
    }
}

public func renderNodes(nodes:[Node], context:Context) -> StencilResult {
    var result = ""

    for item in nodes {
        switch item.render(context) {
        case .Success(let string):
            result += string
        case .Error(let error):
            return .Error(error)
        }
    }

    return .Success(result)
}

public class SimpleNode : Node {
    let handler:(Context) -> (StencilResult)

    public init(handler:((Context) -> (StencilResult))) {
        self.handler = handler
    }

    public func render(context:Context) -> StencilResult {
        return handler(context)
    }
}

public class TextNode : Node {
    public let text:String

    public init(text:String) {
        self.text = text
    }

    public func render(context:Context) -> StencilResult {
        return .Success(self.text)
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

    public func render(context:Context) -> StencilResult {
        let result:AnyObject? = variable.resolve(context)

        if let result = result as? String {
            return .Success(result)
        } else if let result = result as? NSObject {
            return .Success(result.description)
        }

        return .Success("")
    }
}

public class NowNode : Node {
    public let format:Variable

    public class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
        var format:Variable?

        let components = token.components()
        if components.count == 2 {
            format = Variable(components[1])
        }

        return .Success(node:NowNode(format:format))
    }

    public init(format:Variable?) {
        if let format = format {
            self.format = format
        } else {
            self.format = Variable("\"yyyy-MM-dd 'at' HH:mm\"")
        }
    }

    public func render(context: Context) -> StencilResult {
        let date = NSDate()
        let format: AnyObject? = self.format.resolve(context)
        var formatter:NSDateFormatter?

        if let format = format as? NSDateFormatter {
            formatter = format
        } else if let format = format as? String {
            formatter = NSDateFormatter()
            formatter!.dateFormat = format
        } else {
            return .Success("")
        }

        return .Success(formatter!.stringFromDate(date))
    }
}

public class ForNode : Node {
    let variable:Variable
    let loopVariable:String
    let nodes:[Node]

    public class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
        let components = token.components()
        let count = countElements(components)

        if count == 4 && components[2] == "in" {
            let loopVariable = components[1]
            let variable = components[3]

            var forNodes:[Node]!
            var emptyNodes = [Node]()

            switch parser.parse(until(["endfor", "empty"])) {
                case .Success(let nodes):
                    forNodes = nodes
                case .Error(let error):
                    return .Error(error)
            }

            if let token = parser.nextToken() {
                if token.contents == "empty" {
                    switch parser.parse(until(["endfor"])) {
                    case .Success(let nodes):
                        emptyNodes = nodes
                    case .Error(let error):
                        return .Error(error)
                    }

                    parser.nextToken()
                }
            } else {
                return .Error(error: NodeError(token: token, message: "`endfor` was not found."))
            }

            return .Success(node:ForNode(variable: variable, loopVariable: loopVariable, nodes: forNodes, emptyNodes:emptyNodes))
        }

        return .Error(error: NodeError(token: token, message: "Invalid syntax. Expected `for x in y`."))
    }

    public init(variable:String, loopVariable:String, nodes:[Node], emptyNodes:[Node]) {
        self.variable = Variable(variable)
        self.loopVariable = loopVariable
        self.nodes = nodes
    }

    public func render(context: Context) -> StencilResult {
        let values = variable.resolve(context) as? [AnyObject]
        var output = ""

        if let values = values {
            for item in values {
                context.push()
                context[loopVariable] = item
                let result = renderNodes(nodes, context)
                context.pop()

                switch result {
                    case .Success(let string):
                        output += string
                    case .Error(let error):
                        return .Error(error)
                }
            }
        }

        return .Success(output)
    }
}

public class IfNode : Node {
    public let variable:Variable
    public let trueNodes:[Node]
    public let falseNodes:[Node]

    public class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
        let variable = token.components()[1]
        var trueNodes = [Node]()
        var falseNodes = [Node]()

        switch parser.parse(until(["endif", "else"])) {
            case .Success(let nodes):
                trueNodes = nodes
            case .Error(let error):
                return .Error(error)
        }

        if let token = parser.nextToken() {
            if token.contents == "else" {
                switch parser.parse(until(["endif"])) {
                    case .Success(let nodes):
                        falseNodes = nodes
                    case .Error(let error):
                        return .Error(error)
                }
                parser.nextToken()
            }
        } else {
            return .Error(error:NodeError(token: token, message: "`endif` was not found."))
        }

        return .Success(node:IfNode(variable: variable, trueNodes: trueNodes, falseNodes: falseNodes))
    }

    public class func parse_ifnot(parser:TokenParser, token:Token) -> TokenParser.Result {
        let variable = token.components()[1]
        var trueNodes = [Node]()
        var falseNodes = [Node]()

        switch parser.parse(until(["endif", "else"])) {
        case .Success(let nodes):
            falseNodes = nodes
        case .Error(let error):
            return .Error(error)
        }

        if let token = parser.nextToken() {
            if token.contents == "else" {
                switch parser.parse(until(["endif"])) {
                case .Success(let nodes):
                    trueNodes = nodes
                case .Error(let error):
                    return .Error(error)
                }
                parser.nextToken()
            }
        } else {
            return .Error(error:NodeError(token: token, message: "`endif` was not found."))
        }

        return .Success(node:IfNode(variable: variable, trueNodes: trueNodes, falseNodes: falseNodes))
    }

    public init(variable:String, trueNodes:[Node], falseNodes:[Node]) {
        self.variable = Variable(variable)
        self.trueNodes = trueNodes
        self.falseNodes = falseNodes
    }

    public func render(context: Context) -> StencilResult {
        let result: AnyObject? = variable.resolve(context)
        var truthy = false

        if let result = result as? [AnyObject] {
            if result.count > 0 {
                truthy = true
            }
        } else if let result: AnyObject = result {
            truthy = true
        }

        context.push()
        let output = renderNodes(truthy ? trueNodes : falseNodes, context)
        context.pop()

        return output
    }
}
