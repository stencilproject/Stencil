import Spectre
@testable import Stencil


func testLexer() {
  describe("Lexer") {
    $0.it("can tokenize text") {
      let lexer = Lexer(templateString: "Hello World")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "Hello World", at: "Hello World".range)
    }

    $0.it("can tokenize a comment") {
      let lexer = Lexer(templateString: "{# Comment #}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .comment(value: "Comment", at: "{# Comment #}".range)
    }

    $0.it("can tokenize a variable") {
      let lexer = Lexer(templateString: "{{ Variable }}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .variable(value: "Variable", at: "{{ Variable }}".range)
    }

    $0.it("can tokenize unclosed tag by ignoring it") {
      let templateString = "{{ thing"
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "", at: "".range)
    }

    $0.it("can tokenize a mixture of content") {
      let templateString = "My name is {{ name }}."
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 3
      try expect(tokens[0]) == Token.text(value: "My name is ", at: templateString.range(of: "My name is ")!)
      try expect(tokens[1]) == Token.variable(value: "name", at: templateString.range(of: "{{ name }}")!)
      try expect(tokens[2]) == Token.text(value: ".", at: templateString.range(of: ".")!)
    }

    $0.it("can tokenize two variables without being greedy") {
      let templateString = "{{ thing }}{{ name }}"
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 2
      try expect(tokens[0]) == Token.variable(value: "thing", at: templateString.range(of: "{{ thing }}")!)
      try expect(tokens[1]) == Token.variable(value: "name", at: templateString.range(of: "{{ name }}")!)
    }

    $0.it("can tokenize an unclosed block") {
      let lexer = Lexer(templateString: "{%}")
      let _ = lexer.tokenize()
    }

    $0.it("can tokenize an empty variable") {
      let lexer = Lexer(templateString: "{{}}")
      let _ = lexer.tokenize()
    }
  }
}
