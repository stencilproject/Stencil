import Foundation
import XCTest
import Stencil

class ErrorNodeError : StencilError {
    var description: String {
        return "Node Error"
    }
}

class ErrorNode : Node {
    func render(context: Context) -> StencilResult {

        return .Error(ErrorNodeError())
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

        switch node.render(context) {
            case .Success(let string):
                XCTAssertEqual(string, "Hello World")
            case .Error(let error):
                XCTAssert(false, "Unexpected error")
        }
    }
}

class VariableNodeTests: NodeTests {
    func testVariableNodeResolvesVariable() {
        let node = VariableNode(variable:Variable("name"))
        let result = node.render(context)

        switch node.render(context) {
            case .Success(let string):
                XCTAssertEqual(string, "Kyle")
            case .Error(let error):
                XCTAssert(false, "Unexpected error")
        }
    }

    func testVariableNodeResolvesNonStringVariable() {
        let node = VariableNode(variable:Variable("age"))
        let result = node.render(context)

        switch node.render(context) {
        case .Success(let string):
            XCTAssertEqual(string, "27")
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
    }
}

class RenderNodeTests: NodeTests {
    func testRenderingNodes() {
        let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name")] as [Node]
        switch renderNodes(nodes, context) {
        case .Success(let result):
            XCTAssertEqual(result, "Hello Kyle")
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
    }

    func testRenderingNodesWithFailure() {
        let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name"), ErrorNode()] as [Node]

        switch renderNodes(nodes, context) {
        case .Success(let result):
            XCTAssert(false, "Unexpected success")
        case .Error(let error):
            XCTAssertEqual("\(error)", "Node Error")
        }
    }
}

class ForNodeTests: NodeTests {
    func testForNodeRender() {
        let node = ForNode(variable: "items", loopVariable: "item", nodes: [VariableNode(variable: "item")], emptyNodes:[])
        let result = node.render(context)

        switch node.render(context) {
        case .Success(let string):
            XCTAssertEqual(string, "123")
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
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
        assertSuccess(parser.parse()) { nodes in
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
        assertSuccess(parser.parse()) { nodes in
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
    }

    func testParseIfWithoutEndIfError() {
        let tokens = [
            Token.Block(value: "if value"),
        ]

        let parser = TokenParser(tokens: tokens)
        assertFailure(parser.parse(), "if: `endif` was not found.")
    }

    func testParseIfNotWithoutEndIfError() {
        let tokens = [
            Token.Block(value: "ifnot value"),
        ]

        let parser = TokenParser(tokens: tokens)
        assertFailure(parser.parse(), "ifnot: `endif` was not found.")
    }

    // MARK: Rendering

    func testIfNodeRenderTruth() {
        let node = IfNode(variable: "items", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        let result = node.render(context)

        switch node.render(context) {
        case .Success(let string):
            XCTAssertEqual(string, "true")
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
    }

    func testIfNodeRenderFalse() {
        let node = IfNode(variable: "unknown", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        let result = node.render(context)

        switch node.render(context) {
        case .Success(let string):
            XCTAssertEqual(string, "false")
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
    }

}

class NowNodeTests: NodeTests {

    // MARK: Parsing

    func testParseDefaultNow() {
        let tokens = [ Token.Block(value: "now") ]
        let parser = TokenParser(tokens: tokens)

        assertSuccess(parser.parse()) { nodes in
            let node = nodes.first! as NowNode
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(node.format.variable, "\"yyyy-MM-dd 'at' HH:mm\"")
        }
    }

    func testParseNowWithFormat() {
        let tokens = [ Token.Block(value: "now \"HH:mm\"") ]
        let parser = TokenParser(tokens: tokens)

        assertSuccess(parser.parse()) { nodes in
            let node = nodes.first! as NowNode
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(node.format.variable, "\"HH:mm\"")
        }
    }

    // MARK: Rendering

    func testRenderNowNode() {
        let node = NowNode(format: Variable("\"yyyy-MM-dd\""))
        let result = node.render(context)

        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.stringFromDate(NSDate())

        switch node.render(context) {
        case .Success(let string):
            XCTAssertEqual(string, date)
        case .Error(let error):
            XCTAssert(false, "Unexpected error")
        }
    }

}

