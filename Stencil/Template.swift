//
//  Template.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public struct Template {
    let nodes:[Node]

    public init(templateString:String) {
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()
        let parser = TokenParser(tokens: tokens)
        nodes = parser.parse()
    }

    public func render(context:Context) -> (string:String?, error:Error?) {
        return renderNodes(nodes, context)
    }
}
