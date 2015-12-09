import Spectre
import Stencil


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
}
