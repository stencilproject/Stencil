//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class IfNodeTests: XCTestCase {
  func testParseIf() {
    it("can parse an if block") {
      let tokens: [Token] = [
        .block(value: "if value", at: .unknown),
        .text(value: "true", at: .unknown),
        .block(value: "endif", at: .unknown)
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

    it("can parse an if with complex expression") {
      let tokens: [Token] = [
        .block(value: """
          if value == \"test\" and (not name or not (name and surname) or( some )and other )
          """, at: .unknown),
        .text(value: "true", at: .unknown),
        .block(value: "endif", at: .unknown)
      ]

      let parser = TokenParser(tokens: tokens, environment: Environment())
      let nodes = try parser.parse()
      try expect(nodes.first is IfNode).beTrue()
    }
  }

  func testParseIfWithElse() throws {
    let tokens: [Token] = [
      .block(value: "if value", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "else", at: .unknown),
      .text(value: "false", at: .unknown),
      .block(value: "endif", at: .unknown)
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

  func testParseIfWithElif() throws {
    let tokens: [Token] = [
      .block(value: "if value", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "elif something", at: .unknown),
      .text(value: "some", at: .unknown),
      .block(value: "else", at: .unknown),
      .text(value: "false", at: .unknown),
      .block(value: "endif", at: .unknown)
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

  func testParseIfWithElifWithoutElse() throws {
    let tokens: [Token] = [
      .block(value: "if value", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "elif something", at: .unknown),
      .text(value: "some", at: .unknown),
      .block(value: "endif", at: .unknown)
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

  func testParseMultipleElif() throws {
    let tokens: [Token] = [
      .block(value: "if value", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "elif something1", at: .unknown),
      .text(value: "some1", at: .unknown),
      .block(value: "elif something2", at: .unknown),
      .text(value: "some2", at: .unknown),
      .block(value: "else", at: .unknown),
      .text(value: "false", at: .unknown),
      .block(value: "endif", at: .unknown)
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

  func testParseIfnot() throws {
    let tokens: [Token] = [
      .block(value: "ifnot value", at: .unknown),
      .text(value: "false", at: .unknown),
      .block(value: "else", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "endif", at: .unknown)
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

  func testParsingErrors() {
    it("throws an error when parsing an if block without an endif") {
      let tokens: [Token] = [.block(value: "if value", at: .unknown)]

      let parser = TokenParser(tokens: tokens, environment: Environment())
      let error = TemplateSyntaxError(reason: "`endif` was not found.", token: tokens.first)
      try expect(try parser.parse()).toThrow(error)
    }

    it("throws an error when parsing an ifnot without an endif") {
      let tokens: [Token] = [.block(value: "ifnot value", at: .unknown)]

      let parser = TokenParser(tokens: tokens, environment: Environment())
      let error = TemplateSyntaxError(reason: "`endif` was not found.", token: tokens.first)
      try expect(try parser.parse()).toThrow(error)
    }
  }

  func testRendering() {
    it("renders a true expression") {
      let node = IfNode(conditions: [
        IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "1")]),
        IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "2")]),
        IfCondition(expression: nil, nodes: [TextNode(text: "3")])
      ])

      try expect(try node.render(Context())) == "1"
    }

    it("renders the first true expression") {
      let node = IfNode(conditions: [
        IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
        IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "2")]),
        IfCondition(expression: nil, nodes: [TextNode(text: "3")])
      ])

      try expect(try node.render(Context())) == "2"
    }

    it("renders the empty expression when other conditions are falsy") {
      let node = IfNode(conditions: [
        IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
        IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "2")]),
        IfCondition(expression: nil, nodes: [TextNode(text: "3")])
      ])

      try expect(try node.render(Context())) == "3"
    }

    it("renders empty when no truthy conditions") {
      let node = IfNode(conditions: [
        IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
        IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "2")])
      ])

      try expect(try node.render(Context())) == ""
    }
  }

  func testSupportVariableFilters() throws {
    let tokens: [Token] = [
      .block(value: "if value|uppercase == \"TEST\"", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "endif", at: .unknown)
    ]

    let parser = TokenParser(tokens: tokens, environment: Environment())
    let nodes = try parser.parse()

    let result = try renderNodes(nodes, Context(dictionary: ["value": "test"]))
    try expect(result) == "true"
  }

  func testEvaluatesNilAsFalse() throws {
    let tokens: [Token] = [
      .block(value: "if instance.value", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "endif", at: .unknown)
    ]

    let parser = TokenParser(tokens: tokens, environment: Environment())
    let nodes = try parser.parse()

    let result = try renderNodes(nodes, Context(dictionary: ["instance": SomeType()]))
    try expect(result) == ""
  }

  func testSupportsRangeVariables() throws {
    let tokens: [Token] = [
      .block(value: "if value in 1...3", at: .unknown),
      .text(value: "true", at: .unknown),
      .block(value: "else", at: .unknown),
      .text(value: "false", at: .unknown),
      .block(value: "endif", at: .unknown)
    ]

    let parser = TokenParser(tokens: tokens, environment: Environment())
    let nodes = try parser.parse()

    try expect(renderNodes(nodes, Context(dictionary: ["value": 3]))) == "true"
    try expect(renderNodes(nodes, Context(dictionary: ["value": 4]))) == "false"
  }
}

// MARK: - Helpers

private struct SomeType {
  let value: String? = nil
}
