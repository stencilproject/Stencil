import Spectre
@testable import Stencil
import PathKit


func testInclude() {
  describe("Include") {
    let path = Path(#file) + ".." + "fixtures"
    let loader = FileSystemLoader(paths: [path])
    let environment = Environment(loader: loader)

    $0.describe("parsing") {
      $0.it("throws an error when no template is given") {
        let tokens: [Token] = [ .block(value: "include") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())

        let error = TemplateSyntaxError("'include' tag requires one argument, the template file to be included. Another optional argument can be used to specify the context that will be passed to the included file, using the format \"using myContext\"")
        try expect(try parser.parse()).toThrow(error)
      }

      $0.it("can parse a valid include block") {
        let tokens: [Token] = [ .block(value: "include \"test.html\"") ]
        let parser = TokenParser(tokens: tokens, environment: Environment())

        let nodes = try parser.parse()
        let node = nodes.first as? IncludeNode
        try expect(nodes.count) == 1
        try expect(node?.templateName) == Variable("\"test.html\"")
      }
    }

    $0.describe("rendering") {
      $0.it("throws an error when rendering without a loader") {
        let node = IncludeNode(templateName: Variable("\"test.html\""))

        do {
          _ = try node.render(Context())
        } catch {
          try expect("\(error)") == "Template named `test.html` does not exist. No loaders found"
        }
      }

      $0.it("throws an error when it cannot find the included template") {
        let node = IncludeNode(templateName: Variable("\"unknown.html\""))

        do {
          _ = try node.render(Context(environment: environment))
        } catch {
          try expect("\(error)".hasPrefix("Template named `unknown.html` does not exist in loader")).to.beTrue()
        }
      }

      $0.it("successfully renders a found included template") {
        let node = IncludeNode(templateName: Variable("\"test.html\""))
        let context = Context(dictionary: ["target": "World"], environment: environment)
        let value = try node.render(context)
        try expect(value) == "Hello World!"
      }

      $0.it("successfully indents included content") {
          let template = Template(templateString: "Include:\n\t{% include \"include.html\" %}\nnewline")
          let context = Context(dictionary: ["items": [["name":"one"], ["name": "two"]]], environment: environment)
          let value = try template.render(context)
          try expect(value) == "Include:\n\tI have 2 items:\n\t  one\n\t  two\n\nnewline"
      }

      $0.it("successfully passes context") {
        let template = Template(templateString: "{% include \"test.html\" using child %}")
        let context = Context(dictionary: ["child": ["target": "World"]], environment: environment)
        let value = try template.render(context)
        try expect(value) == "Hello World!"
      }
    }
  }
}
