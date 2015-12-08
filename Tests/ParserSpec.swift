import Spectre
import Stencil


describe("TokenParser") {
  $0.it("can parse a text token") {
    let parser = TokenParser(tokens: [
      Token.Text(value: "Hello World")
    ], namespace: Namespace())

    let nodes = try parser.parse()
    let node = nodes.first as? TextNode

    try expect(nodes.count) == 1
    try expect(node?.text) == "Hello World"
  }

  $0.it("can parse a variable token") {
    let parser = TokenParser(tokens: [
      Token.Variable(value: "'name'")
    ], namespace: Namespace())

    let nodes = try parser.parse()
    let node = nodes.first as? VariableNode
    try expect(nodes.count) == 1
    let result = try node?.render(Context())
    try expect(result) == "name"
  }

  $0.it("can parse a comment token") {
    let parser = TokenParser(tokens: [
      Token.Comment(value: "Secret stuff!")
    ], namespace: Namespace())

    let nodes = try parser.parse()
    try expect(nodes.count) == 0
  }

  $0.it("can parse a tag token") {
    let parser = TokenParser(tokens: [
      Token.Block(value: "now"),
    ], namespace: Namespace())

    let nodes = try parser.parse()
    try expect(nodes.count) == 1
  }

  $0.it("errors when parsing an unknown tag") {
    let parser = TokenParser(tokens: [
      Token.Block(value: "unknown"),
    ], namespace: Namespace())

    try expect(try parser.parse()).toThrow(TemplateSyntaxError("Unknown template tag 'unknown'"))
  }
}
