//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class NodeTests: XCTestCase {
  private let context = Context(dictionary: [
    "name": "Kyle",
    "age": 27,
    "items": [1, 2, 3]
  ])

  func testTextNode() {
    it("renders the given text") {
      let node = TextNode(text: "Hello World")
      try expect(try node.render(self.context)) == "Hello World"
    }
    it("Trims leading whitespace") {
      let text = "      \n Some text     "
      let trimBehaviour = TrimBehaviour(leading: .whitespace, trailing: .nothing)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "\n Some text     "
    }
    it("Trims leading whitespace and one newline") {
      let text = "\n\n Some text     "
      let trimBehaviour = TrimBehaviour(leading: .whitespaceAndOneNewLine, trailing: .nothing)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "\n Some text     "
    }
    it("Trims leading whitespace and one newline") {
      let text = "\n\n Some text     "
      let trimBehaviour = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .nothing)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "Some text     "
    }
    it("Trims trailing whitespace") {
      let text = "      Some text     \n"
      let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespace)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "      Some text\n"
    }
    it("Trims trailing whitespace and one newline") {
      let text = "      Some text     \n \n "
      let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespaceAndOneNewLine)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "      Some text     \n "
    }
    it("Trims trailing whitespace and newlines") {
      let text = "      Some text     \n \n "
      let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespaceAndNewLines)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "      Some text"
    }
    it("Trims all whitespace") {
      let text = "    \n  \nSome text \n    "
      let trimBehaviour = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .whitespaceAndNewLines)
      let node = TextNode(text: text, trimBehaviour: trimBehaviour)
      try expect(try node.render(self.context)) == "Some text"
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

  func testRenderingBooleans() {
    it("can render true & false") {
      try expect(Template(templateString: "{{ true }}").render()) == "true"
      try expect(Template(templateString: "{{ false }}").render()) == "false"
    }

    it("can resolve variable") {
      let template = Template(templateString: "{{ value == \"known\" }}")
      try expect(template.render(["value": "known"])) == "true"
      try expect(template.render(["value": "unknown"])) == "false"
    }

    it("can render a boolean expression") {
      try expect(Template(templateString: "{{ 1 > 0 }}").render()) == "true"
      try expect(Template(templateString: "{{ 1 == 2 }}").render()) == "false"
    }
  }
}
