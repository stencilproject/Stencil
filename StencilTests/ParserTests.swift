import Foundation
import XCTest
import Stencil
import CatchingFire

class TokenParserTests: XCTestCase {
  func testParsingTextToken() {
    let parser = TokenParser(tokens: [
      Token.Text(value: "Hello World")
      ])

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! TextNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.text, "Hello World")
    }
  }

  func testParsingVariableToken() {
    let parser = TokenParser(tokens: [
      Token.Variable(value: "name")
      ])

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! VariableNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.variable, Variable("name"))
    }
  }

  func testParsingCommentToken() {
    let parser = TokenParser(tokens: [
      Token.Comment(value: "Secret stuff!")
      ])

    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 0)
    }
  }

  func testParsingTagToken() {
    let parser = TokenParser(tokens: [
      Token.Block(value: "now"),
      ])

    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
    }
  }
}
