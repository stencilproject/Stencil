import Spectre
@testable import Stencil


class ErrorNode : NodeType {
  func render(_ context: Context) throws -> String {
    throw TemplateSyntaxError("Custom Error")
  }
}


func testNode() {
  describe("Node") {
    let context = Context(dictionary: [
      "title": escaped(html: "'Hello World'"),
      "name": "Kyle",
      "age": 27,
      "items": [1, 2, 3],
    ])

    $0.describe("TextNode") {
      $0.it("renders the given text") {
        let node = TextNode(text: "Hello World")
        try expect(try node.render(context)) == "Hello World"
      }
    }

    $0.describe("VariableNode") {
      $0.it("resolves and renders the variable") {
        let node = VariableNode(variable: Variable("name"))
        try expect(try node.render(context)) == "Kyle"
      }

      $0.it("resolves and renders a non string variable") {
        let node = VariableNode(variable: Variable("age"))
        try expect(try node.render(context)) == "27"
      }

      $0.describe("escaping") {
        $0.it("automatically escapes unescaped html") {
          let node = VariableNode(variable: Variable("\"'Hello World'\""))
          try expect(try node.render(context)) == "&39;Hello World&39;"
        }

        $0.it("doesn't double escape already escaped HTML") {
          let node = VariableNode(variable: Variable("title"))
          try expect(try node.render(context)) == "'Hello World'"
        }
      }
    }

    $0.describe("rendering nodes") {
      $0.it("renders the nodes") {
        let nodes: [NodeType] = [
          TextNode(text:"Hello "),
          VariableNode(variable: "name"),
        ]

        try expect(try renderNodes(nodes, context)) == "Hello Kyle"
      }

      $0.it("correctly throws a nodes failure") {
        let nodes: [NodeType] = [
          TextNode(text:"Hello "),
          VariableNode(variable: "name"),
          ErrorNode(),
        ]

        try expect(try renderNodes(nodes, context)).toThrow(TemplateSyntaxError("Custom Error"))
      }
    }
  }
}
