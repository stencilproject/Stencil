import Spectre
@testable import Stencil


func testIfNode() {
  describe("IfNode") {
    $0.describe("parsing") {
      $0.it("can parse an if block") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "else"),
          .text(value: "false"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, namespace: Namespace())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode
        let trueNode = node?.trueNodes.first as? TextNode
        let falseNode = node?.falseNodes.first as? TextNode

        try expect(nodes.count) == 1
        try expect(node?.trueNodes.count) == 1
        try expect(trueNode?.text) == "true"
        try expect(node?.falseNodes.count) == 1
        try expect(falseNode?.text) == "false"
      }

      $0.it("can parse an ifnot block") {
        let tokens: [Token] = [
          .block(value: "ifnot value"),
          .text(value: "false"),
          .block(value: "else"),
          .text(value: "true"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, namespace: Namespace())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode
        let trueNode = node?.trueNodes.first as? TextNode
        let falseNode = node?.falseNodes.first as? TextNode

        try expect(nodes.count) == 1
        try expect(node?.trueNodes.count) == 1
        try expect(trueNode?.text) == "true"
        try expect(node?.falseNodes.count) == 1
        try expect(falseNode?.text) == "false"
      }

      $0.it("throws an error when parsing an if block without an endif") {
        let tokens: [Token] = [
          .block(value: "if value"),
        ]

        let parser = TokenParser(tokens: tokens, namespace: Namespace())
        let error = TemplateSyntaxError("`endif` was not found.")
        try expect(try parser.parse()).toThrow(error)
      }

      $0.it("throws an error when parsing an ifnot without an endif") {
        let tokens: [Token] = [
            .block(value: "ifnot value"),
        ]

        let parser = TokenParser(tokens: tokens, namespace: Namespace())
        let error = TemplateSyntaxError("`endif` was not found.")
        try expect(try parser.parse()).toThrow(error)
      }
    }

    $0.describe("rendering") {
      $0.it("renders the truth when expression evaluates to true") {
        let node = IfNode(expression: StaticExpression(value: true), trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        try expect(try node.render(Context())) == "true"
      }

      $0.it("renders the false when expression evaluates to false") {
        let node = IfNode(expression: StaticExpression(value: false), trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
        try expect(try node.render(Context())) == "false"
      }
    }
  }
}
