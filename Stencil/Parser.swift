//
//  Parser.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public class TokenParser {
    private var tokens:[Token]

    public init(tokens:[Token]) {
        self.tokens = tokens
    }

    public func parse() -> [Node] {
        return parse(nil)
    }

    public func parse(parse_until:((parser:TokenParser, token:Token) -> (Bool))?) -> [Node] {
        var nodes = [Node]()

        while tokens.count > 0 {
            let token = nextToken()!

            switch token {
            case .Text(let text):
                nodes.append(TextNode(text: text))
            case .Variable(let variable):
                nodes.append(VariableNode(variable: variable))
            case .Block(let value):
                continue
            case .Comment(let value):
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
