import Spectre
@testable import Stencil


func testIfNode() {
  describe("Expression") {
    $0.describe("VariableExpression") {
      let expression = VariableExpression(variable: Variable("value"))

      $0.it("evaluates to true when value is not nil") {
        let context = Context(dictionary: ["value": "known"])
        try expect(try expression.evaluate(context: context)).to.beTrue()
      }

      $0.it("evaluates to false when value is unset") {
        let context = Context()
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }

      $0.it("evaluates to true when array variable is not empty") {
        let items: [[String: Any]] = [["key":"key1","value":42],["key":"key2","value":1337]]
        let context = Context(dictionary: ["value": [items]])
        try expect(try expression.evaluate(context: context)).to.beTrue()
      }

      $0.it("evaluates to false when array value is empty") {
        let emptyItems = [[String: Any]]()
        let context = Context(dictionary: ["value": emptyItems])
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }

      $0.it("evaluates to false when dictionary value is empty") {
        let emptyItems = [String:Any]()
        let context = Context(dictionary: ["value": emptyItems])
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }

      $0.it("evaluates to false when Array<Any> value is empty") {
        let context = Context(dictionary: ["value": ([] as [Any])])
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }

      $0.it("evaluates to true when integer value is above 0") {
        let context = Context(dictionary: ["value": 1])
        try expect(try expression.evaluate(context: context)).to.beTrue()
      }

      $0.it("evaluates to false when integer value is below 0 or below") {
        let context = Context(dictionary: ["value": 0])
        try expect(try expression.evaluate(context: context)).to.beFalse()

        let negativeContext = Context(dictionary: ["value": 0])
        try expect(try expression.evaluate(context: negativeContext)).to.beFalse()
      }

      $0.it("evaluates to true when float value is above 0") {
        let context = Context(dictionary: ["value": Float(0.5)])
        try expect(try expression.evaluate(context: context)).to.beTrue()
      }

      $0.it("evaluates to false when float is 0 or below") {
        let context = Context(dictionary: ["value": Float(0)])
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }

      $0.it("evaluates to true when double value is above 0") {
        let context = Context(dictionary: ["value": Double(0.5)])
        try expect(try expression.evaluate(context: context)).to.beTrue()
      }

      $0.it("evaluates to false when double is 0 or below") {
        let context = Context(dictionary: ["value": Double(0)])
        try expect(try expression.evaluate(context: context)).to.beFalse()
      }
    }

    $0.describe("NotExpression") {
      $0.it("returns truthy for positive expressions") {
        let expression = NotExpression(expression: StaticExpression(value: true))
        try expect(expression.evaluate(context: Context())).to.beFalse()
      }

      $0.it("returns falsy for negative expressions") {
        let expression = NotExpression(expression: StaticExpression(value: false))
        try expect(expression.evaluate(context: Context())).to.beTrue()
      }
    }

    $0.describe("expression parsing") {
      $0.it("can parse a variable expression") {
        let expression = try parseExpression(components: ["value"])
        try expect(expression.evaluate(context: Context())).to.beFalse()
        try expect(expression.evaluate(context: Context(dictionary: ["value": true]))).to.beTrue()
      }

      $0.it("can parse a not expression") {
        let expression = try parseExpression(components: ["not", "value"])
        try expect(expression.evaluate(context: Context())).to.beTrue()
        try expect(expression.evaluate(context: Context(dictionary: ["value": true]))).to.beFalse()
      }

      $0.describe("and expression") {
        let expression = try! parseExpression(components: ["lhs", "and", "rhs"])

        $0.it("evaluates to false with lhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true]))).to.beFalse()
        }

        $0.it("evaluates to false with rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false]))).to.beFalse()
        }

        $0.it("evaluates to false with lhs and rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false]))).to.beFalse()
        }

        $0.it("evaluates to true with lhs and rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true]))).to.beTrue()
        }
      }

      $0.describe("or expression") {
        let expression = try! parseExpression(components: ["lhs", "or", "rhs"])

        $0.it("evaluates to true with lhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false]))).to.beTrue()
        }

        $0.it("evaluates to true with rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true]))).to.beTrue()
        }

        $0.it("evaluates to true with lhs and rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true]))).to.beTrue()
        }

        $0.it("evaluates to false with lhs and rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false]))).to.beFalse()
        }
      }

      $0.describe("multiple expression") {
        let expression = try! parseExpression(components: ["one", "or", "two", "and", "not", "three"])

        $0.it("evaluates to true with one") {
          try expect(expression.evaluate(context: Context(dictionary: ["one": true]))).to.beTrue()
        }

        $0.it("evaluates to true with one and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["one": true, "three": true]))).to.beTrue()
        }

        $0.it("evaluates to true with two") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true]))).to.beTrue()
        }

        $0.it("evaluates to false with two and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true]))).to.beFalse()
        }

        $0.it("evaluates to false with two and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true]))).to.beFalse()
        }

        $0.it("evaluates to false with nothing") {
          try expect(expression.evaluate(context: Context())).to.beFalse()
        }
      }
    }
  }

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
