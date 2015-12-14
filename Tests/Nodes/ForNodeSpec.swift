import Spectre
import Stencil
import Foundation


describe("ForNode") {
  let context = Context(dictionary: [
    "items": [1, 2, 3],
    "emptyItems": [Int](),
  ])

  $0.it("renders the given nodes for each item") {
    let nodes: [NodeType] = [VariableNode(variable: "item")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(context)) == "123"
  }

  $0.it("renders the given empty nodes when no items found item") {
    let nodes: [NodeType] = [VariableNode(variable: "item")]
    let emptyNodes: [NodeType] = [TextNode(text: "empty")]
    let node = ForNode(variable: "emptyItems", loopVariable: "item", nodes: nodes, emptyNodes: emptyNodes)
    try expect(try node.render(context)) == "empty"
  }

  $0.it("renders a context variable of type Array<Any>") {
    let any_context = Context(dictionary: [
        "items": ([1, 2, 3] as [Any])
      ])

    let nodes: [NodeType] = [VariableNode(variable: "item")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(any_context)) == "123" 
  }

  $0.it("renders a context variable of type NSArray") {
    let nsarray_context = Context(dictionary: [
        "items": NSArray(array: [1, 2, 3])
      ])

    let nodes: [NodeType] = [VariableNode(variable: "item")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(nsarray_context)) == "123" 
  }

  $0.it("renders the given nodes while providing if the item is first in the context") {
    let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.first")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(context)) == "1true2false3false"
  }

  $0.it("renders the given nodes while providing if the item is last in the context") {
    let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.last")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(context)) == "1false2false3true"
  }

  $0.it("renders the given nodes while providing item counter") {
    let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
    let node = ForNode(variable: "items", loopVariable: "item", nodes: nodes, emptyNodes: [])
    try expect(try node.render(context)) == "112233"
  }
}
