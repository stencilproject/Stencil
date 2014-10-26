//
//  ParserTests.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Cocoa
import XCTest
import Stencil

class TokenParserTests: XCTestCase {
    func testParsingTextToken() {
        let parser = TokenParser(tokens: [
            Token.Text(value: "Hello World")
        ])

        let (nodes, error) = parser.parse()
        let node = nodes!.first as TextNode!

        XCTAssertTrue(error == nil)
        XCTAssertEqual(nodes!.count, 1)
        XCTAssertEqual(node.text, "Hello World")
    }

    func testParsingVariableToken() {
        let parser = TokenParser(tokens: [
            Token.Variable(value: "name")
        ])

        let (nodes, error) = parser.parse()
        let node = nodes!.first as VariableNode!
        let variable = node.variable

        XCTAssertTrue(error == nil)
        XCTAssertEqual(nodes!.count, 1)
        XCTAssertEqual(variable, Variable("name"))
    }

    func testParsingCommentToken() {
        let parser = TokenParser(tokens: [
            Token.Comment(value: "Secret stuff!")
        ])

        let (nodes, error) = parser.parse()

        XCTAssertEqual(nodes!.count, 0)
    }

    func testParsingTagToken() {
        let parser = TokenParser(tokens: [
            Token.Block(value: "now"),
        ])

        let (nodes, error) = parser.parse()
        let node = nodes!.first as NowNode!
        XCTAssertTrue(error == nil)
        XCTAssertEqual(nodes!.count, 1)
    }
}
