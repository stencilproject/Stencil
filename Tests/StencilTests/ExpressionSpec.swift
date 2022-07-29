//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class ExpressionsTests: XCTestCase {
  private let parser = TokenParser(tokens: [], environment: Environment())

  private func makeExpression(_ components: [String]) -> Expression {
    do {
      let parser = try IfExpressionParser.parser(
        components: components,
        environment: Environment(),
        token: .text(value: "", at: .unknown)
      )
      return try parser.parse()
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  func testTrueExpressions() {
    let expression = VariableExpression(variable: Variable("value"))

    it("evaluates to true when value is not nil") {
      let context = Context(dictionary: ["value": "known"])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }

    it("evaluates to true when array variable is not empty") {
      let items: [[String: Any]] = [["key": "key1", "value": 42], ["key": "key2", "value": 1_337]]
      let context = Context(dictionary: ["value": [items]])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }

    it("evaluates to false when dictionary value is empty") {
      let emptyItems = [String: Any]()
      let context = Context(dictionary: ["value": emptyItems])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to true when integer value is above 0") {
      let context = Context(dictionary: ["value": 1])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }

    it("evaluates to true with string") {
      let context = Context(dictionary: ["value": "test"])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }

    it("evaluates to true when float value is above 0") {
      let context = Context(dictionary: ["value": Float(0.5)])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }

    it("evaluates to true when double value is above 0") {
      let context = Context(dictionary: ["value": Double(0.5)])
      try expect(try expression.evaluate(context: context)).to.beTrue()
    }
  }

  func testFalseExpressions() {
    let expression = VariableExpression(variable: Variable("value"))

    it("evaluates to false when value is unset") {
      let context = Context()
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when array value is empty") {
      let emptyItems = [[String: Any]]()
      let context = Context(dictionary: ["value": emptyItems])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when dictionary value is empty") {
      let emptyItems = [String: Any]()
      let context = Context(dictionary: ["value": emptyItems])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when Array<Any> value is empty") {
      let context = Context(dictionary: ["value": ([] as [Any])])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when empty string") {
      let context = Context(dictionary: ["value": ""])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when integer value is below 0 or below") {
      let context = Context(dictionary: ["value": 0])
      try expect(try expression.evaluate(context: context)).to.beFalse()

      let negativeContext = Context(dictionary: ["value": -1])
      try expect(try expression.evaluate(context: negativeContext)).to.beFalse()
    }

    it("evaluates to false when float is 0 or below") {
      let context = Context(dictionary: ["value": Float(0)])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when double is 0 or below") {
      let context = Context(dictionary: ["value": Double(0)])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }

    it("evaluates to false when uint is 0") {
      let context = Context(dictionary: ["value": UInt(0)])
      try expect(try expression.evaluate(context: context)).to.beFalse()
    }
  }

  func testNotExpression() {
    it("returns truthy for positive expressions") {
      let expression = NotExpression(expression: VariableExpression(variable: Variable("true")))
      try expect(expression.evaluate(context: Context())).to.beFalse()
    }

    it("returns falsy for negative expressions") {
      let expression = NotExpression(expression: VariableExpression(variable: Variable("false")))
      try expect(expression.evaluate(context: Context())).to.beTrue()
    }
  }

  func testExpressionParsing() {
    it("can parse a variable expression") {
      let expression = self.makeExpression(["value"])
      try expect(expression.evaluate(context: Context())).to.beFalse()
      try expect(expression.evaluate(context: Context(dictionary: ["value": true]))).to.beTrue()
    }

    it("can parse a not expression") {
      let expression = self.makeExpression(["not", "value"])
      try expect(expression.evaluate(context: Context())).to.beTrue()
      try expect(expression.evaluate(context: Context(dictionary: ["value": true]))).to.beFalse()
    }
  }

  func testAndExpression() {
    let expression = makeExpression(["lhs", "and", "rhs"])

    it("evaluates to false with lhs false") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true]))).to.beFalse()
    }

    it("evaluates to false with rhs false") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false]))).to.beFalse()
    }

    it("evaluates to false with lhs and rhs false") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false]))).to.beFalse()
    }

    it("evaluates to true with lhs and rhs true") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true]))).to.beTrue()
    }
  }

  func testOrExpression() {
    let expression = makeExpression(["lhs", "or", "rhs"])

    it("evaluates to true with lhs true") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false]))).to.beTrue()
    }

    it("evaluates to true with rhs true") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true]))).to.beTrue()
    }

    it("evaluates to true with lhs and rhs true") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true]))).to.beTrue()
    }

    it("evaluates to false with lhs and rhs false") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false]))).to.beFalse()
    }
  }

  func testEqualityExpression() {
    let expression = makeExpression(["lhs", "==", "rhs"])

    it("evaluates to true with equal lhs/rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "a"]))).to.beTrue()
    }

    it("evaluates to false with non equal lhs/rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"]))).to.beFalse()
    }

    it("evaluates to true with nils") {
      try expect(expression.evaluate(context: Context(dictionary: [:]))).to.beTrue()
    }

    it("evaluates to true with numbers") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.0]))).to.beTrue()
    }

    it("evaluates to false with non equal numbers") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.1]))).to.beFalse()
    }

    it("evaluates to true with booleans") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true]))).to.beTrue()
    }

    it("evaluates to false with falsy booleans") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false]))).to.beFalse()
    }

    it("evaluates to false with different types") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": 1]))).to.beFalse()
    }
  }

  func testInequalityExpression() {
    let expression = makeExpression(["lhs", "!=", "rhs"])

    it("evaluates to true with inequal lhs/rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"]))).to.beTrue()
    }

    it("evaluates to false with equal lhs/rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": "b", "rhs": "b"]))).to.beFalse()
    }
  }

  func testMoreThanExpression() {
    let expression = makeExpression(["lhs", ">", "rhs"])

    it("evaluates to true with lhs > rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 4]))).to.beTrue()
    }

    it("evaluates to false with lhs == rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0]))).to.beFalse()
    }
  }

  func testMoreThanEqualExpression() {
    let expression = makeExpression(["lhs", ">=", "rhs"])

    it("evaluates to true with lhs == rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5]))).to.beTrue()
    }

    it("evaluates to false with lhs < rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.1]))).to.beFalse()
    }
  }

  func testLessThanExpression() {
    let expression = makeExpression(["lhs", "<", "rhs"])

    it("evaluates to true with lhs < rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 4, "rhs": 4.5]))).to.beTrue()
    }

    it("evaluates to false with lhs == rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0]))).to.beFalse()
    }
  }

  func testLessThanEqualExpression() {
    let expression = makeExpression(["lhs", "<=", "rhs"])

    it("evaluates to true with lhs == rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5]))).to.beTrue()
    }

    it("evaluates to false with lhs > rhs") {
      try expect(expression.evaluate(context: Context(dictionary: ["lhs": 5.1, "rhs": 5.0]))).to.beFalse()
    }
  }

  func testMultipleExpressions() {
    let expression = makeExpression(["one", "or", "two", "and", "not", "three"])

    it("evaluates to true with one") {
      try expect(expression.evaluate(context: Context(dictionary: ["one": true]))).to.beTrue()
    }

    it("evaluates to true with one and three") {
      try expect(expression.evaluate(context: Context(dictionary: ["one": true, "three": true]))).to.beTrue()
    }

    it("evaluates to true with two") {
      try expect(expression.evaluate(context: Context(dictionary: ["two": true]))).to.beTrue()
    }

    it("evaluates to false with two and three") {
      try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true]))).to.beFalse()
    }

    it("evaluates to false with two and three") {
      try expect(expression.evaluate(context: Context(dictionary: ["two": true, "three": true]))).to.beFalse()
    }

    it("evaluates to false with nothing") {
      try expect(expression.evaluate(context: Context())).to.beFalse()
    }
  }

  func testTrueInExpression() throws {
    let expression = makeExpression(["lhs", "in", "rhs"])

    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 1,
      "rhs": [1, 2, 3]
    ]))).to.beTrue()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": "a",
      "rhs": ["a", "b", "c"]
    ]))).to.beTrue()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": "a",
      "rhs": "abc"
    ]))).to.beTrue()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 1,
      "rhs": 1...3
    ]))).to.beTrue()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 1,
      "rhs": 1..<3
    ]))).to.beTrue()
  }

  func testFalseInExpression() throws {
    let expression = makeExpression(["lhs", "in", "rhs"])

    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 1,
      "rhs": [2, 3, 4]
    ]))).to.beFalse()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": "a",
      "rhs": ["b", "c", "d"]
    ]))).to.beFalse()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": "a",
      "rhs": "bcd"
    ]))).to.beFalse()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 4,
      "rhs": 1...3
    ]))).to.beFalse()
    try expect(expression.evaluate(context: Context(dictionary: [
      "lhs": 3,
      "rhs": 1..<3
    ]))).to.beFalse()
  }
}
