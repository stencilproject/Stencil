import Spectre
@testable import Stencil
import XCTest

class ErrorNode: NodeType {
  let token: Token?
  init(token: Token? = nil) {
    self.token = token
  }

  func render(_ context: Context) throws -> String {
    throw TemplateSyntaxError("Custom Error")
  }
}

final class NodeTests: XCTestCase {
  let context = Context(dictionary: [
    "name": "Kyle",
    "age": 27,
    "items": [1, 2, 3]
  ])

  func testTextNode() {
    it("renders the given text") {
      let node = TextNode(text: "Hello World")
      try expect(try node.render(self.context)) == "Hello World"
    }
  }

  func testVariableNode() {
    it("resolves and renders the variable") {
      let node = VariableNode(variable: Variable("name"))
      try expect(try node.render(self.context)) == "Kyle"
    }

    it("resolves and renders a non string variable") {
      let node = VariableNode(variable: Variable("age"))
      try expect(try node.render(self.context)) == "27"
    }
  }

  func testRendering() {
    it("renders the nodes") {
      let nodes: [NodeType] = [
        TextNode(text: "Hello "),
        VariableNode(variable: "name")
      ]

      try expect(try renderNodes(nodes, self.context)) == "Hello Kyle"
    }

    it("correctly throws a nodes failure") {
      let nodes: [NodeType] = [
        TextNode(text: "Hello "),
        VariableNode(variable: "name"),
        ErrorNode()
      ]

      try expect(try renderNodes(nodes, self.context)).toThrow(TemplateSyntaxError("Custom Error"))
    }
  }
}
