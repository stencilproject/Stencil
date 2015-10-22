import Spectre
import Stencil

describe("IfNode") {
  $0.describe("parsing") {
    $0.it("can parse an if block") {
      let tokens = [
        Token.Block(value: "if value"),
        Token.Text(value: "true"),
        Token.Block(value: "else"),
        Token.Text(value: "false"),
        Token.Block(value: "endif")
      ]

      let parser = TokenParser(tokens: tokens)
      let nodes = try parser.parse()
      let node = nodes.first as? IfNode
      let trueNode = node?.trueNodes.first as? TextNode
      let falseNode = node?.falseNodes.first as? TextNode

      try expect(nodes.count) == 1
      try expect(node?.variable.variable) == "value"
      try expect(node?.trueNodes.count) == 1
      try expect(trueNode?.text) == "true"
      try expect(node?.falseNodes.count) == 1
      try expect(falseNode?.text) == "false"
    }

    $0.it("can parse an ifnot block") {
      let tokens = [
        Token.Block(value: "ifnot value"),
        Token.Text(value: "false"),
        Token.Block(value: "else"),
        Token.Text(value: "true"),
        Token.Block(value: "endif")
      ]

      let parser = TokenParser(tokens: tokens)
      let nodes = try parser.parse()
      let node = nodes.first as? IfNode
      let trueNode = node?.trueNodes.first as? TextNode
      let falseNode = node?.falseNodes.first as? TextNode

      try expect(nodes.count) == 1
      try expect(node?.variable.variable) == "value"
      try expect(node?.trueNodes.count) == 1
      try expect(trueNode?.text) == "true"
      try expect(node?.falseNodes.count) == 1
      try expect(falseNode?.text) == "false"
    }

    $0.it("throws an error when parsing an if block without an endif") {
      let tokens = [
        Token.Block(value: "if value"),
      ]

      let parser = TokenParser(tokens: tokens)
      let error = TemplateSyntaxError("`endif` was not found.")
      try expect(try parser.parse()).toThrow(error)
    }

    $0.it("throws an error when parsing an ifnot without an endif") {
      let tokens = [
        Token.Block(value: "ifnot value"),
      ]

      let parser = TokenParser(tokens: tokens)
      let error = TemplateSyntaxError("`endif` was not found.")
      try expect(try parser.parse()).toThrow(error)
    }
  }

  $0.describe("rendering") {
    let context = Context(dictionary: ["items": true])

    $0.it("renders the truth when expression evaluates to true") {
      let node = IfNode(variable: "items", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
      try expect(try node.render(context)) == "true"
    }

    $0.it("renders the false when expression evaluates to false") {
      let node = IfNode(variable: "unknown", trueNodes: [TextNode(text: "true")], falseNodes: [TextNode(text: "false")])
      try expect(try node.render(context)) == "false"
    }
  }
}
