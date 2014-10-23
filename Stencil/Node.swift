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
