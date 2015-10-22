import Foundation
import XCTest
import Stencil

class TokenParserTests: XCTestCase {
  func testParsingTextToken() {
    let parser = TokenParser(tokens: [
      Token.Text(value: "Hello World")
      ])

    assertSuccess(try parser.parse()) { nodes in
      let node = nodes.first as! TextNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.text, "Hello World")
    }
  }

  func testParsingVariableToken() {
    let parser = TokenParser(tokens: [
      Token.Variable(value: "'name'")
    ])

    assertSuccess(try parser.parse()) { nodes in
      let node = nodes.first as! VariableNode
      XCTAssertEqual(nodes.count, 1)
      let result = try? node.render(Context())
      XCTAssertEqual(result, "name")
    }
  }

  func testParsingCommentToken() {
    let parser = TokenParser(tokens: [
      Token.Comment(value: "Secret stuff!")
      ])

    assertSuccess(try parser.parse()) { nodes in
      XCTAssertEqual(nodes.count, 0)
    }
  }

  func testParsingTagToken() {
    let parser = TokenParser(tokens: [
      Token.Block(value: "now"),
      ])

    assertSuccess(try parser.parse()) { nodes in
      XCTAssertEqual(nodes.count, 1)
    }
  }
}
