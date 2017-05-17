import Spectre
@testable import Stencil


func testLexer() {
  describe("Lexer") {
    $0.it("can tokenize text") {
      let lexer = Lexer(templateString: "Hello World")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "Hello World")
    }

    $0.it("can tokenize a comment") {
      let lexer = Lexer(templateString: "{# Comment #}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .comment(value: "Comment")
    }

    $0.it("can tokenize a variable") {
      let lexer = Lexer(templateString: "{{ Variable }}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .variable(value: "Variable")
    }

    $0.it("can tokenize unclosed tag by ignoring it") {
      let lexer = Lexer(templateString: "{{ thing")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "")
    }

    $0.it("can tokenize a mixture of content") {
      let lexer = Lexer(templateString: "My name is {{ name }}.")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 3
      try expect(tokens[0]) == Token.text(value: "My name is ")
      try expect(tokens[1]) == Token.variable(value: "name")
      try expect(tokens[2]) == Token.text(value: ".")
    }

    $0.it("can tokenize two variables without being greedy") {
      let lexer = Lexer(templateString: "{{ thing }}{{ name }}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 2
      try expect(tokens[0]) == Token.variable(value: "thing")
      try expect(tokens[1]) == Token.variable(value: "name")
    }
  }
}
