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
        Token.mkBlock("known"),
      ], environment: Environment(extensions: [simpleExtension]))

      let nodes = try parser.parse()
      try expect(nodes.count) == 1
    }

    $0.it("errors when parsing an unknown tag") {
      let parser = TokenParser(tokens: [
        Token.mkBlock("unknown"),
      ], environment: Environment())

      try expect(try parser.parse()).toThrow(TemplateSyntaxError("Unknown template tag 'unknown'"))
    }

    $0.it("Can trim whitespace") {

      let simpleExtension = Extension()
      simpleExtension.registerSimpleTag("known") { _ in
        return ""
      }

      let parser = TokenParser(tokens: [
        Token.block(value: "known", newline: WhitespaceBehavior(leading: .unspecified, trailing: .trim)),
        Token.text(value: "      \nSome text     "),
        Token.block(value: "known", newline: WhitespaceBehavior(leading: .keep, trailing: .trim))
      ], environment: Environment(extensions: [simpleExtension]))

      let nodes = try parser.parse()
      try expect(nodes.count) == 3
      let textNode = nodes[1] as? TextNode
      try expect(textNode?.text) == "      \nSome text     "
      try expect(textNode?.trimBehavior) == TextNode.TrimBehavior(trimLeft: true, trimRight: false)
    }
  }
}
