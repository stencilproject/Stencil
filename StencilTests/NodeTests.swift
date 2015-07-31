import Foundation
import XCTest
import Stencil
import CatchingFire

enum ErrorNodeError : ErrorType {
  case ExpectedError
}

class ErrorNode : Node {
  func render(context: Context) throws -> String {
    throw ErrorNodeError.ExpectedError
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
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Hello World")
    }
  }
}

class VariableNodeTests: NodeTests {
  func testVariableNodeResolvesVariable() {
    let node = VariableNode(variable:Variable("name"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Kyle")
    }
  }

  func testVariableNodeResolvesNonStringVariable() {
    let node = VariableNode(variable:Variable("age"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "27")
    }
  }
}

class RenderNodeTests: NodeTests {
  func testRenderingNodes() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name")] as [Node]
    AssertNoThrow {
      let result = try renderNodes(nodes, context: context)
      XCTAssertEqual(result, "Hello Kyle")
    }
  }

  func testRenderingNodesWithFailure() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name"), ErrorNode()] as [Node]
    AssertThrows(ErrorNodeError.ExpectedError) {
      try renderNodes(nodes, context: context)
    }
  }
}

class ForNodeTests: NodeTests {
  func testForNodeRender() {
    let node = ForNode(variable: "items", loopVariable: "item", nodes: [VariableNode(variable: "item")], emptyNodes:[])
    AssertNoThrow {
      let result = try node.render(context)
      XCTAssertEqual(result, "123")
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
    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! IfNode
      let trueNode = node.trueNodes.first as! TextNode
      let falseNode = node.falseNodes.first as! TextNode

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
    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! IfNode
      let trueNode = node.trueNodes.first as! TextNode
      let falseNode = node.falseNodes.first as! TextNode

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
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endif` was not found.")) {
      try parser.parse()
    }
  }

  func testParseIfNotWithoutEndIfError() {
    let tokens = [
      Token.Block(value: "ifnot value"),
    ]

    let parser = TokenParser(tokens: tokens)
    AssertThrows(ParseError(cause: .MissingEnd, token: tokens[0], message: "`endif` was not found.")) {
      // ifnot: `endif` was not found."
      try parser.parse()
    }
  }

  // MARK: Rendering

  func testIfNodeRenderTruth() {
    let node = IfNode(variable: "items", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
    
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "true")
    }
  }

  func testIfNodeRenderFalse() {
    let node = IfNode(variable: "unknown", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])

    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "false")
    }
  }

}

class NowNodeTests: NodeTests {

  // MARK: Parsing

  func testParseDefaultNow() {
    let tokens = [ Token.Block(value: "now") ]
    let parser = TokenParser(tokens: tokens)

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! NowNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.format.variable, "\"yyyy-MM-dd 'at' HH:mm\"")
    }
  }

  func testParseNowWithFormat() {
    let tokens = [ Token.Block(value: "now \"HH:mm\"") ]
    let parser = TokenParser(tokens: tokens)

    AssertNoThrow {
      let nodes = try parser.parse()
      let node = nodes.first as! NowNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.format.variable, "\"HH:mm\"")
    }
  }

  // MARK: Rendering

  func testRenderNowNode() {
    let node = NowNode(format: Variable("\"yyyy-MM-dd\""))

    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.stringFromDate(NSDate())

    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, date)
    }
  }

}

