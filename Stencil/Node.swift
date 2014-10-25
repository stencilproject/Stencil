//
//  Node.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public protocol Error : Printable {

}

public protocol Node {
    func render(context:Context) -> (String?, Error?)
}

extension Array {
    func map<U>(block:((Element) -> (U?, Error?))) -> ([U]?, Error?) {
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

public func renderNodes(nodes:[Node], context:Context) -> (String?, Error?) {
    let result:(results:[String]?, error:Error?) = nodes.map {
        return $0.render(context)
    }

    if let result = result.0 {
        return ("".join(result), nil)
    }

    return (nil, result.1)
}

public class TextNode : Node {
    public let text:String

    public init(text:String) {
        self.text = text
    }

    public func render(context:Context) -> (String?, Error?) {
        return (self.text, nil)
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

    public func render(context:Context) -> (String?, Error?) {
        let result:AnyObject? = variable.resolve(context)

        if let result = result as? String {
            return (result, nil)
        } else if let result = result as? NSObject {
            return (result.description, nil)
        }

        return (nil, nil)
    }
}

public class NowNode : Node {
    public class func parse(parser:TokenParser, token:Token) -> Node {
        return NowNode()
    }

    public func render(context: Context) -> (String?, Error?) {
        let date = NSDate()
        return ("\(date)", nil)
    }
}

public class ForNode : Node {
    let variable:Variable
    let loopVariable:String
    let nodes:[Node]

    public class func parse(parser:TokenParser, token:Token) -> Node {
        let components = token.components()
        let count = countElements(components)

        if count == 4 && components[2] == "in" {
            let loopVariable = components[1]
            let variable = components[3]
            let nodes = parser.parse(until(["endfor", "empty"]))
            var emptyNodes = [Node]()

            if let token = parser.nextToken() {
                if token.contents == "empty" {
                    emptyNodes = parser.parse(until(["endfor"]))
                    parser.nextToken()
                }
            }

            return ForNode(variable: variable, loopVariable: loopVariable, nodes: nodes, emptyNodes:emptyNodes)
        } else {
            // TODO error
        }

        return TextNode(text: "TODO return some error")
    }

    public init(variable:String, loopVariable:String, nodes:[Node], emptyNodes:[Node]) {
        self.variable = Variable(variable)
        self.loopVariable = loopVariable
        self.nodes = nodes
    }

    public func render(context: Context) -> (String?, Error?) {
        let values = variable.resolve(context) as? [AnyObject]
        var result = ""

        if let values = values {
            for item in values {
                context.push()
                context[loopVariable] = item
                let (string, error) = renderNodes(nodes, context)
                context.pop()

                if let error = error {
                    return (nil, error)
                }

                if let string = string {
                    result += string
                }
            }
        }

        return (result, nil)
    }
}
