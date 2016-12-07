import Spectre
@testable import Stencil


func testTokenParser() {
  describe("TokenParser") {
    $0.it("can parse a text token") {
      let parser = TokenParser(tokens: [
        .text(value: "Hello World")
      ], environment: Environment())

      let nodes = try parser.parse()
      let node = nodes.first as? TextNode

      try expect(nodes.count) == 1
      try expect(node?.text) == "Hello World"
    }

    $0.it("can parse a variable token") {
      let parser = TokenParser(tokens: [
        .variable(value: "'name'")
      ], environment: Environment())

      let nodes = try parser.parse()
      let node = nodes.first as? VariableNode
      try expect(nodes.count) == 1
      let result = try node?.render(Context())
      try expect(result) == "name"
    }

    $0.it("can parse a comment token") {
      let parser = TokenParser(tokens: [
        .comment(value: "Secret stuff!")
      ], environment: Environment())

      let nodes = try parser.parse()
      try expect(nodes.count) == 0
    }

    $0.it("can parse a tag token") {
      let simpleExtension = Extension()
      simpleExtension.registerSimpleTag("known") { _ in
        return ""
      }

      let parser = TokenParser(tokens: [
        .block(value: "known"),
      ], environment: Environment(extensions: [simpleExtension]))

      let nodes = try parser.parse()
      try expect(nodes.count) == 1
    }

    $0.it("errors when parsing an unknown tag") {
      let parser = TokenParser(tokens: [
        .block(value: "unknown"),
      ], environment: Environment())

      try expect(try parser.parse()).toThrow(TemplateSyntaxError("Unknown template tag 'unknown'"))
    }
  }
}
