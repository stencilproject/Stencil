import Spectre
@testable import Stencil


func testLexer() {
  describe("Lexer") {
    $0.it("can tokenize text") {
      let lexer = Lexer(templateString: "Hello World")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "Hello World", at: SourceMap(line: ("Hello World", 1, 0)))
    }

    $0.it("can tokenize a comment") {
      let lexer = Lexer(templateString: "{# Comment #}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .comment(value: "Comment", at: SourceMap(line: ("{# Comment #}", 1, 3)))
    }

    $0.it("can tokenize a variable") {
      let lexer = Lexer(templateString: "{{ Variable }}")
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .variable(value: "Variable", at: SourceMap(line: ("{{ Variable }}", 1, 3)))
    }

    $0.it("can tokenize unclosed tag by ignoring it") {
      let templateString = "{{ thing"
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 1
      try expect(tokens.first) == .text(value: "", at: SourceMap(line: ("{{ thing", 1, 0)))
    }

    $0.it("can tokenize a mixture of content") {
      let templateString = "My name is {{ myname }}."
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 3
      try expect(tokens[0]) == Token.text(value: "My name is ", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "My name is ")!)))
      try expect(tokens[1]) == Token.variable(value: "myname", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "myname")!)))
      try expect(tokens[2]) == Token.text(value: ".", at: SourceMap(line: templateString.rangeLine(templateString.range(of: ".")!)))
    }

    $0.it("can tokenize two variables without being greedy") {
      let templateString = "{{ thing }}{{ name }}"
      let lexer = Lexer(templateString: templateString)
      let tokens = lexer.tokenize()

      try expect(tokens.count) == 2
      try expect(tokens[0]) == Token.variable(value: "thing", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "thing")!)))
      try expect(tokens[1]) == Token.variable(value: "name", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "name")!)))
    }

    $0.it("can tokenize an unclosed block") {
      let lexer = Lexer(templateString: "{%}")
      let _ = lexer.tokenize()
    }

    $0.it("can tokenize an empty variable") {
      let lexer = Lexer(templateString: "{{}}")
      let _ = lexer.tokenize()
    }

    $0.it("can tokenize with new lines") {
      let templateString =
        "My name is {%\n" +
          "    if name\n" +
          "     and\n" +
          "    name\n" +
          "%}{{\n" +
          "name\n" +
          "}}{%\n" +
      "endif %}."

      let lexer = Lexer(templateString: templateString)

      let tokens = lexer.tokenize()

      try expect(tokens.count) == 5
      try expect(tokens[0]) == Token.text(value: "My name is ", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "My name is")!)))
      try expect(tokens[1]) == Token.block(value: "if name and name", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "{%")!)))
      try expect(tokens[2]) == Token.variable(value: "name", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "name", options: [.backwards])!)))
      try expect(tokens[3]) == Token.block(value: "endif", at: SourceMap(line: templateString.rangeLine(templateString.range(of: "endif")!)))
      try expect(tokens[4]) == Token.text(value: ".", at: SourceMap(line: templateString.rangeLine(templateString.range(of: ".")!)))
    }
  }
}
