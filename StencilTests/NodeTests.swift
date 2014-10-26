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

class ErrorNodeError : Error {
    var description: String {
        return "Node Error"
    }
}

class ErrorNode : Node {
    func render(context: Context) -> (String?, Error?) {

        return (nil, ErrorNodeError())
    }
}

class NodeTests: XCTestCase {
    var context:Context!

    override func setUp() {
        context = Context(dictionary: [
            "name": "Kyle",
            "age": 27,
            "items": [1,2,3],
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

class RenderNodeTests: NodeTests {
    func testRenderingNodes() {
        let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name")] as [Node]
        let (result:String?, error:Error?) = renderNodes(nodes, context)

        XCTAssertEqual(result!, "Hello Kyle")
        XCTAssertTrue(error == nil)
    }

    func testRenderingNodesWithFailure() {
        let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name"), ErrorNode()] as [Node]
        let (result:String?, error:Error?) = renderNodes(nodes, context)

        XCTAssertEqual(error!.description, "Node Error")
        XCTAssertTrue(result == nil)
    }
}

class ForNodeTests: NodeTests {
    func testForNodeRender() {
        let node = ForNode(variable: "items", loopVariable: "item", nodes: [VariableNode(variable: "item")], emptyNodes:[])
        let result = node.render(context)

        XCTAssertEqual(result.0!, "123")
    }
}

class IfNodeTests: NodeTests {

    // MARK: Parsing

    func testParseIf() {
        let tokens = [
            Token.Block(value: "if value"),
                Token.Text(value: "true"),
            Token.Block(value: "else"),
                Token.Text(value: "false"),
            Token.Block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens)
        let nodes = parser.parse()
        let node = nodes.first! as IfNode
        let trueNode = node.trueNodes.first! as TextNode
        let falseNode = node.falseNodes.first! as TextNode

        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(node.variable.variable, "value")
        XCTAssertEqual(node.trueNodes.count, 1)
        XCTAssertEqual(trueNode.text, "true")
        XCTAssertEqual(node.falseNodes.count, 1)
        XCTAssertEqual(falseNode.text, "false")
    }

    func testParseIfNot() {
        let tokens = [
            Token.Block(value: "ifnot value"),
                Token.Text(value: "false"),
            Token.Block(value: "else"),
                Token.Text(value: "true"),
            Token.Block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens)
        let nodes = parser.parse()
        let node = nodes.first! as IfNode
        let trueNode = node.trueNodes.first! as TextNode
        let falseNode = node.falseNodes.first! as TextNode

        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(node.variable.variable, "value")
        XCTAssertEqual(node.trueNodes.count, 1)
        XCTAssertEqual(trueNode.text, "true")
        XCTAssertEqual(node.falseNodes.count, 1)
        XCTAssertEqual(falseNode.text, "false")
    }

    // MARK: Rendering

    func testIfNodeRenderTruth() {
        let node = IfNode(variable: "items", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        let result = node.render(context)

        XCTAssertEqual(result.0!, "true")
    }

    func testIfNodeRenderFalse() {
        let node = IfNode(variable: "unknown", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        let result = node.render(context)

        XCTAssertEqual(result.0!, "false")
    }

}
