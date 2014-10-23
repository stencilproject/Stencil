//
//  NodeTests.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Cocoa
import XCTest
import Stencil

class NodeTests: XCTestCase {
    var context:Context!

    override func setUp() {
        context = Context(dictionary: [
            "name": "Kyle",
            "age": 27,
        ])
    }
}

class TextNodeTests: NodeTests {
    func testTextNodeResolvesText() {
        let node = TextNode(text:"Hello World")
        let result = node.render(context)

        XCTAssertEqual(result.0!, "Hello World")
    }
}

class VariableNodeTests: NodeTests {
    func testVariableNodeResolvesVariable() {
        let node = VariableNode(variable:Variable("name"))
        let result = node.render(context)

        XCTAssertEqual(result.0!, "Kyle")
    }

    func testVariableNodeResolvesNonStringVariable() {
        let node = VariableNode(variable:Variable("age"))
        let result = node.render(context)

        XCTAssertEqual(result.0!, "27")
    }
}
