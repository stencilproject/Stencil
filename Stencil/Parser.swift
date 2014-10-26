//
//  Parser.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

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
    private var tokens:[Token]
    private var tags = Dictionary<String, ((TokenParser, Token) -> ((node:Node?, error:Error?)))>()

    public init(tokens:[Token]) {
        self.tokens = tokens
        tags["for"] = ForNode.parse
        tags["now"] = NowNode.parse
        tags["if"] = IfNode.parse
        tags["ifnot"] = IfNode.parse_ifnot
    }

    public func parse() -> (nodes:[Node]?, error:Error?) {
        return parse(nil)
    }

    public func parse(parse_until:((parser:TokenParser, token:Token) -> (Bool))?) -> (nodes:[Node]?, error:Error?) {
        var nodes = [Node]()

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
                        return (nodes, nil)
                    }
                }

                if let tag = tag {
                    if let parser = self.tags[tag] {
                        let (node, error) = parser(self, token)

                        if let error = error {
                            return (nil, error)
                        }

                        if let node = node {
                            nodes.append(node)
                        }
                    }
                }
            case .Comment(let value):
                continue
            }
        }

        return (nodes, nil)
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
