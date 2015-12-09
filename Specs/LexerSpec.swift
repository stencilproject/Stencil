import Spectre
import Stencil


describe("Lexer") {
  $0.it("can tokenize text") {
    let lexer = Lexer(templateString: "Hello World")
    let tokens = lexer.tokenize()

    try expect(tokens.count) == 1
    try expect(tokens.first) == Token.Text(value: "Hello World")
  }

  $0.it("can tokenize a comment") {
    let lexer = Lexer(templateString: "{# Comment #}")
    let tokens = lexer.tokenize()

    try expect(tokens.count) == (1)
    try expect(tokens.first) == Token.Comment(value: "Comment")
  }

  $0.it("can tokenize a variable") {
    let lexer = Lexer(templateString: "{{ Variable }}")
    let tokens = lexer.tokenize()

    try expect(tokens.count) == 1
    try expect(tokens.first) == Token.Variable(value: "Variable")
  }

  $0.it("can tokenize a mixture of content") {
    let lexer = Lexer(templateString: "My name is {{ name }}.")
    let tokens = lexer.tokenize()

    try expect(tokens.count) == 3
    try expect(tokens[0]) == Token.Text(value: "My name is ")
    try expect(tokens[1]) == Token.Variable(value: "name")
    try expect(tokens[2]) == Token.Text(value: ".")
  }

  $0.it("can tokenize two variables without being greedy") {
    let lexer = Lexer(templateString: "{{ thing }}{{ name }}")
    let tokens = lexer.tokenize()

    try expect(tokens.count) == 2
    try expect(tokens[0]) == Token.Variable(value: "thing")
    try expect(tokens[1]) == Token.Variable(value: "name")
  }
}
