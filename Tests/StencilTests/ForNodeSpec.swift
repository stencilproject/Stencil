import Spectre
@testable import Stencil
import Foundation


func testForNode() {
  describe("ForNode") {
    let context = Context(dictionary: [
      "items": [1, 2, 3],
      "emptyItems": [Int](),
      "dict": [
        "one": "I",
        "two": "II",
      ]
    ])

    $0.it("renders the given nodes for each item") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(context)) == "123"
    }

    $0.it("renders the given empty nodes when no items found item") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let node = ForNode(resolvable: Variable("emptyItems"), loopVariables: ["item"], nodes: nodes, emptyNodes: emptyNodes)
      try expect(try node.render(context)) == "empty"
    }

    $0.it("renders a context variable of type Array<Any>") {
      let any_context = Context(dictionary: [
        "items": ([1, 2, 3] as [Any])
      ])

      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(any_context)) == "123"
    }

    $0.it("renders a context variable of type CountableClosedRange<Int>") {
      let context = Context(dictionary: ["range": 1...3])
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

      try expect(try node.render(context)) == "123"
    }

    $0.it("renders a context variable of type CountableRange<Int>") {
      let context = Context(dictionary: ["range": 1..<4])
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

      try expect(try node.render(context)) == "123"
    }

#if os(OSX)
    $0.it("renders a context variable of type NSArray") {
      let nsarray_context = Context(dictionary: [
        "items": NSArray(array: [1, 2, 3])
      ])

      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(nsarray_context)) == "123"
    }
#endif

    $0.it("renders the given nodes while providing if the item is first in the context") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.first")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(context)) == "1true2false3false"
    }

    $0.it("renders the given nodes while providing if the item is last in the context") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.last")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(context)) == "1false2false3true"
    }

    $0.it("renders the given nodes while providing item counter") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(context)) == "112233"
    }

    $0.it("renders the given nodes while filtering items using where expression") {
        let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
        let `where` = try parseExpression(components: ["item", ">", "1"], tokenParser: TokenParser(tokens: [], environment: Environment()))
        let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [], where: `where`)
        try expect(try node.render(context)) == "2132"
    }

    $0.it("renders the given empty nodes when all items filtered out with where expression") {
        let nodes: [NodeType] = [VariableNode(variable: "item")]
        let emptyNodes: [NodeType] = [TextNode(text: "empty")]
        let `where` = try parseExpression(components: ["item", "==", "0"], tokenParser: TokenParser(tokens: [], environment: Environment()))
        let node = ForNode(resolvable: Variable("emptyItems"), loopVariables: ["item"], nodes: nodes, emptyNodes: emptyNodes, where: `where`)
        try expect(try node.render(context)) == "empty"
    }

    $0.it("can render a filter") {
      let templateString = "{% for article in ars|default:articles %}" +
        "- {{ article.title }} by {{ article.author }}.\n" +
        "{% endfor %}\n"

      let context = Context(dictionary: [
        "articles": [
          Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
          Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
        ]
      ])

      let template = Template(templateString: templateString)
      let result = try template.render(context)

      let fixture = "" +
        "- Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
        "- Memory Management with ARC by Kyle Fuller.\n" +
        "\n"

      try expect(result) == fixture
    }

    $0.it("renders supports iterating over dictionary") {
      let nodes: [NodeType] = [VariableNode(variable: "key")]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let node = ForNode(resolvable: Variable("dict"), loopVariables: ["key"], nodes: nodes, emptyNodes: emptyNodes, where: nil)
      try expect(try node.render(context)) == "onetwo"
    }

    $0.it("renders supports iterating over dictionary") {
      let nodes: [NodeType] = [VariableNode(variable: "key"), VariableNode(variable: "value")]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let node = ForNode(resolvable: Variable("dict"), loopVariables: ["key", "value"], nodes: nodes, emptyNodes: emptyNodes, where: nil)
      try expect(try node.render(context)) == "oneItwoII"
    }
  }
}


fileprivate struct Article {
  let title: String
  let author: String
}
