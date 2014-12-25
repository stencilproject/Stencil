import Foundation
import XCTest
import Stencil

class TokenParserTests: XCTestCase {
    func testParsingTextToken() {
        let parser = TokenParser(tokens: [
            Token.Text(value: "Hello World")
        ])

        assertSuccess(parser.parse()) { nodes in
            let node = nodes.first as TextNode!
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(node.text, "Hello World")
        }
    }

    func testParsingVariableToken() {
        let parser = TokenParser(tokens: [
            Token.Variable(value: "name")
        ])

        assertSuccess(parser.parse()) { nodes in
            let node = nodes.first as VariableNode!
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(node.variable, Variable("name"))
        }
    }

    func testParsingCommentToken() {
        let parser = TokenParser(tokens: [
            Token.Comment(value: "Secret stuff!")
        ])

        assertSuccess(parser.parse()) { nodes in
            XCTAssertEqual(nodes.count, 0)
        }
    }

    func testParsingTagToken() {
        let parser = TokenParser(tokens: [
            Token.Block(value: "now"),
        ])

        assertSuccess(parser.parse()) { nodes in
            XCTAssertEqual(nodes.count, 1)
        }
    }
}
