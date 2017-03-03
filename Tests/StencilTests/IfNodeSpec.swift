import Spectre
@testable import Stencil


func testIfNode() {
  describe("IfNode") {
    $0.describe("parsing") {
      $0.it("can parse an if block") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        try expect(conditions?.count) == 1
        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"
      }

      $0.it("can parse an if with else block") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "else"),
          .text(value: "false"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        try expect(conditions?.count) == 2

        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"

        try expect(conditions?[1].nodes.count) == 1
        let falseNode = conditions?[1].nodes.first as? TextNode
        try expect(falseNode?.text) == "false"
      }

      $0.it("can parse an if with elif block") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "elif something"),
          .text(value: "some"),
          .block(value: "else"),
          .text(value: "false"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        try expect(conditions?.count) == 3

        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"

        try expect(conditions?[1].nodes.count) == 1
        let elifNode = conditions?[1].nodes.first as? TextNode
        try expect(elifNode?.text) == "some"

        try expect(conditions?[2].nodes.count) == 1
        let falseNode = conditions?[2].nodes.first as? TextNode
        try expect(falseNode?.text) == "false"
      }

      $0.it("can parse an if with elif block without else") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "elif something"),
          .text(value: "some"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        try expect(conditions?.count) == 2

        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"

        try expect(conditions?[1].nodes.count) == 1
        let elifNode = conditions?[1].nodes.first as? TextNode
        try expect(elifNode?.text) == "some"
      }

      $0.it("can parse an if with multiple elif block") {
        let tokens: [Token] = [
          .block(value: "if value"),
          .text(value: "true"),
          .block(value: "elif something1"),
          .text(value: "some1"),
          .block(value: "elif something2"),
          .text(value: "some2"),
          .block(value: "else"),
          .text(value: "false"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        try expect(conditions?.count) == 4

        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"

        try expect(conditions?[1].nodes.count) == 1
        let elifNode = conditions?[1].nodes.first as? TextNode
        try expect(elifNode?.text) == "some1"

        try expect(conditions?[2].nodes.count) == 1
        let elif2Node = conditions?[2].nodes.first as? TextNode
        try expect(elif2Node?.text) == "some2"

        try expect(conditions?[3].nodes.count) == 1
        let falseNode = conditions?[3].nodes.first as? TextNode
        try expect(falseNode?.text) == "false"
      }


      $0.it("can parse an if with complex expression") {
        let tokens: [Token] = [
          .block(value: "if value == \"test\" and not name"),
          .text(value: "true"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        try expect(nodes.first is IfNode).beTrue()
      }

      $0.it("can parse an ifnot block") {
        let tokens: [Token] = [
          .block(value: "ifnot value"),
          .text(value: "false"),
          .block(value: "else"),
          .text(value: "true"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode
        let conditions = node?.conditions
        try expect(conditions?.count) == 2

        try expect(conditions?[0].nodes.count) == 1
        let trueNode = conditions?[0].nodes.first as? TextNode
        try expect(trueNode?.text) == "true"

        try expect(conditions?[1].nodes.count) == 1
        let falseNode = conditions?[1].nodes.first as? TextNode
        try expect(falseNode?.text) == "false"
      }

      $0.it("throws an error when parsing an if block without an endif") {
        let tokens: [Token] = [
          .block(value: "if value"),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let error = TemplateSyntaxError("`endif` was not found.")
        try expect(try parser.parse()).toThrow(error)
      }

      $0.it("throws an error when parsing an ifnot without an endif") {
        let tokens: [Token] = [
            .block(value: "ifnot value"),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let error = TemplateSyntaxError("`endif` was not found.")
        try expect(try parser.parse()).toThrow(error)
      }
    }

    $0.describe("rendering") {
      $0.it("renders a true expression") {
        let node = IfNode(conditions: [
          IfCondition(expression: StaticExpression(value: true), nodes: [TextNode(text: "1")]),
          IfCondition(expression: StaticExpression(value: true), nodes: [TextNode(text: "2")]),
          IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
        ])

        try expect(try node.render(Context())) == "1"
      }

      $0.it("renders the first true expression") {
        let node = IfNode(conditions: [
          IfCondition(expression: StaticExpression(value: false), nodes: [TextNode(text: "1")]),
          IfCondition(expression: StaticExpression(value: true), nodes: [TextNode(text: "2")]),
          IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
        ])

        try expect(try node.render(Context())) == "2"
      }

      $0.it("renders the empty expression when other conditions are falsy") {
        let node = IfNode(conditions: [
          IfCondition(expression: StaticExpression(value: false), nodes: [TextNode(text: "1")]),
          IfCondition(expression: StaticExpression(value: false), nodes: [TextNode(text: "2")]),
          IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
        ])

        try expect(try node.render(Context())) == "3"
      }

      $0.it("renders empty when no truthy conditions") {
        let node = IfNode(conditions: [
          IfCondition(expression: StaticExpression(value: false), nodes: [TextNode(text: "1")]),
          IfCondition(expression: StaticExpression(value: false), nodes: [TextNode(text: "2")]),
        ])

        try expect(try node.render(Context())) == ""
      }
    }

    $0.it("supports variable filters in the if expression") {
        let tokens: [Token] = [
          .block(value: "if value|uppercase == \"TEST\""),
          .text(value: "true"),
          .block(value: "endif")
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()

        let result = try renderNodes(nodes, Context(dictionary: ["value": "test"]))
        try expect(result) == "true"
    }
  }
}
