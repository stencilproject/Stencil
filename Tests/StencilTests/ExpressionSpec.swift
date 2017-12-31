import Spectre
@testable import Stencil


func testExpressions() {
  describe("Expression") {
    let parser = TokenParser(tokens: [], environment: Environment())

    $0.describe("VariableExpression") {
      let expression = VariableExpression(variable: Variable("value"))

      $0.it("evaluates to true when value is not nil") {
        let context = Context(dictionary: ["value": "known"])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to false when value is unset") {
        let context = Context()
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to true when array variable is not empty") {
        let items: [[String: Any]] = [["key":"key1","value":42],["key":"key2","value":1337]]
        let context = Context(dictionary: ["value": [items]])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to false when array value is empty") {
        let emptyItems = [[String: Any]]()
        let context = Context(dictionary: ["value": emptyItems])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to false when dictionary value is empty") {
        let emptyItems = [String:Any]()
        let context = Context(dictionary: ["value": emptyItems])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to false when Array<Any> value is empty") {
        let context = Context(dictionary: ["value": ([] as [Any])])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to true when integer value is above 0") {
        let context = Context(dictionary: ["value": 1])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to true with string") {
        let context = Context(dictionary: ["value": "test"])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to false when empty string") {
        let context = Context(dictionary: ["value": ""])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to false when integer value is below 0 or below") {
        let context = Context(dictionary: ["value": 0])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()

        let negativeContext = Context(dictionary: ["value": 0])
        try expect(try expression.evaluate(context: negativeContext) as? Bool).to.beFalse()
      }

      $0.it("evaluates to true when float value is above 0") {
        let context = Context(dictionary: ["value": Float(0.5)])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to false when float is 0 or below") {
        let context = Context(dictionary: ["value": Float(0)])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to true when double value is above 0") {
        let context = Context(dictionary: ["value": Double(0.5)])
        try expect(try expression.evaluate(context: context) as? Bool).to.beTrue()
      }

      $0.it("evaluates to false when double is 0 or below") {
        let context = Context(dictionary: ["value": Double(0)])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }

      $0.it("evaluates to false when uint is 0") {
        let context = Context(dictionary: ["value": UInt(0)])
        try expect(try expression.evaluate(context: context) as? Bool).to.beFalse()
      }
    }

    $0.describe("NotExpression") {
      $0.it("returns truthy for positive expressions") {
        let expression = NotExpression(expression: StaticExpression(value: true))
        try expect(expression.evaluate(context: Context()) as? Bool).to.beFalse()
      }

      $0.it("returns falsy for negative expressions") {
        let expression = NotExpression(expression: StaticExpression(value: false))
        try expect(expression.evaluate(context: Context()) as? Bool).to.beTrue()
      }
    }

    $0.describe("expression parsing") {
      $0.it("can parse a variable expression") {
        let expression = try parseExpression(components: ["value"], tokenParser: parser)
        try expect(expression.evaluate(context: Context()) as? Bool).to.beFalse()
        try expect(expression.evaluate(context: Context(dictionary: ["value": true])) as? Bool).to.beTrue()
      }

      $0.it("can parse a not expression") {
        let expression = try parseExpression(components: ["not", "value"], tokenParser: parser)
        try expect(expression.evaluate(context: Context()) as? Bool).to.beTrue()
        try expect(expression.evaluate(context: Context(dictionary: ["value": true])) as? Bool).to.beFalse()
      }

      $0.describe("and expression") {
        let expression = try! parseExpression(components: ["lhs", "and", "rhs"], tokenParser: parser)

        $0.it("evaluates to false with lhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to false with rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to false with lhs and rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to true with lhs and rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])) as? Bool).to.beTrue()
        }
      }

      $0.describe("or expression") {
        let expression = try! parseExpression(components: ["lhs", "or", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with lhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to true with rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to true with lhs and rhs true") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with lhs and rhs false") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])) as? Bool).to.beFalse()
        }
      }

      $0.describe("equality expression") {
        let expression = try! parseExpression(components: ["lhs", "==", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with equal lhs/rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "a"])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with non equal lhs/rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to true with nils") {
          try expect(expression.evaluate(context: Context(dictionary: [:])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to true with numbers") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.0])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with non equal numbers") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.1])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to true with booleans") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with falsy booleans") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to false with different types") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": 1])) as? Bool).to.beFalse()
        }
      }

      $0.describe("inequality expression") {
        let expression = try! parseExpression(components: ["lhs", "!=", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with inequal lhs/rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with equal lhs/rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "b", "rhs": "b"])) as? Bool).to.beFalse()
        }
      }

      $0.describe("more than expression") {
        let expression = try! parseExpression(components: ["lhs", ">", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with lhs > rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 4])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with lhs == rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])) as? Bool).to.beFalse()
        }
      }

      $0.describe("more than equal expression") {
        let expression = try! parseExpression(components: ["lhs", ">=", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with lhs == rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with lhs < rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.1])) as? Bool).to.beFalse()
        }
      }

      $0.describe("less than expression") {
        let expression = try! parseExpression(components: ["lhs", "<", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with lhs < rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 4, "rhs": 4.5])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with lhs == rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])) as? Bool).to.beFalse()
        }
      }

      $0.describe("less than equal expression") {
        let expression = try! parseExpression(components: ["lhs", "<=", "rhs"], tokenParser: parser)

        $0.it("evaluates to true with lhs == rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with lhs > rhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.1, "rhs": 5.0])) as? Bool).to.beFalse()
        }
      }

      $0.describe("multiple expression") {
        let expression = try! parseExpression(components: ["one", "or", "two", "and", "not", "three"], tokenParser: parser)

        $0.it("evaluates to true with one") {
          try expect(expression.evaluate(context: Context(dictionary: ["one": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to true with one and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["one": true, "three": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to true with two") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true])) as? Bool).to.beTrue()
        }

        $0.it("evaluates to false with two and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to false with two and three") {
          try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true])) as? Bool).to.beFalse()
        }

        $0.it("evaluates to false with nothing") {
          try expect(expression.evaluate(context: Context()) as? Bool).to.beFalse()
        }
      }
      
      $0.describe("in expression") {
        let expression = try! parseExpression(components: ["lhs", "in", "rhs"], tokenParser: parser)
        
        $0.it("evaluates to true when rhs contains lhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": [1, 2, 3]])) as? Bool).to.beTrue()
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": ["a", "b", "c"]])) as? Bool).to.beTrue()
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "abc"])) as? Bool).to.beTrue()
        }
        
        $0.it("evaluates to false when rhs does not contain lhs") {
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": [2, 3, 4]])) as? Bool).to.beFalse()
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": ["b", "c", "d"]])) as? Bool).to.beFalse()
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "bcd"])) as? Bool).to.beFalse()
        }
      }

      $0.describe("arithmetic expression") {
        $0.it("+ when both variables are numbers") {
          let expression = try! parseExpression(components: ["lhs", "+", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 2])) as? Number) == 3
        }
        $0.it("- when both variables are numbers") {
          let expression = try! parseExpression(components: ["lhs", "-", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 2])) as? Number) == -1
        }
        $0.it("* when both variables are numbers") {
          let expression = try! parseExpression(components: ["lhs", "*", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 2, "rhs": 2])) as? Number) == 4
        }
        $0.it("/ when both variables are numbers") {
          let expression = try! parseExpression(components: ["lhs", "/", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 4, "rhs": 2])) as? Number) == 2
        }
        $0.it("* and / have presedence over + and -") {
          let expression = try! parseExpression(components: ["2", "*", "3", "/", "2", "+", "5", "-", "1"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: [:])) as? Number) == 7
        }

        $0.it("throws when left side is nil") {
          let expression = try! parseExpression(components: ["lhs", "+", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["rhs": 2])) as? Number).toThrow()
        }

        $0.it("throws when left side is not a number") {
          let expression = try! parseExpression(components: ["lhs", "+", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": "1", "rhs": 2])) as? Number).toThrow()
        }

        $0.it("throws when right side is nil") {
          let expression = try! parseExpression(components: ["lhs", "+", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["lhs": 2])) as? Number).toThrow()
        }

        $0.it("throws when right side is not a number") {
          let expression = try! parseExpression(components: ["lhs", "+", "rhs"], tokenParser: parser)
          try expect(expression.evaluate(context: Context(dictionary: ["rhs": "1", "lhs": 2])) as? Number).toThrow()
        }
      }
    }
  }
}
