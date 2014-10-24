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

public func render(nodes:[Node], context:Context) -> (String?, Error?) {
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
