import Spectre
import Stencil


describe("Token") {
  $0.it("can split the contents into components") {
    let token = Token.Text(value: "hello world")
    let components = token.components()

    try expect(components.count) == 2
    try expect(components[0]) == "hello"
    try expect(components[1]) == "world"
  }

  $0.it("can split the contents into components with single quoted strings") {
    let token = Token.Text(value: "hello 'kyle fuller'")
    let components = token.components()

    try expect(components.count) == 2
    try expect(components[0]) == "hello"
    try expect(components[1]) == "'kyle fuller'"
  }

  $0.it("can split the contents into components with double quoted strings") {
    let token = Token.Text(value: "hello \"kyle fuller\"")
    let components = token.components()

    try expect(components.count) == 2
    try expect(components[0]) == "hello"
    try expect(components[1]) == "\"kyle fuller\""
  }
}
