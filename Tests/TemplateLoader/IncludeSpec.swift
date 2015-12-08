import Spectre
import Stencil
import PathKit


describe("Include") {
  let path = Path(__FILE__) + ".." + ".." + "Tests" + "fixtures"
  let loader = TemplateLoader(paths: [path])

  $0.describe("parsing") {
    $0.it("throws an error when no template is given") {
      let tokens = [ Token.Block(value: "include") ]
      let parser = TokenParser(tokens: tokens, namespace: Namespace())

      let error = TemplateSyntaxError("'include' tag takes one argument, the template file to be included")
      try expect(try parser.parse()).toThrow(error)
    }

    $0.it("can parse a valid include block") {
      let tokens = [ Token.Block(value: "include \"test.html\"") ]
      let parser = TokenParser(tokens: tokens, namespace: Namespace())

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
        try node.render(Context())
      } catch {
        try expect("\(error)") == "Template loader not in context"
      }
    }

    $0.it("throws an error when it cannot find the included template") {
      let node = IncludeNode(templateName: Variable("\"unknown.html\""))

      do {
        try node.render(Context(dictionary: ["loader": loader]))
      } catch {
        try expect("\(error)".hasPrefix("'unknown.html' template not found")).to.beTrue()
      }
    }

    $0.it("successfully renders a found included template") {
      let node = IncludeNode(templateName: Variable("\"test.html\""))
      let context = Context(dictionary: ["loader":loader, "target": "World"])
      let value = try node.render(context)
      try expect(value) == "Hello World!"
    }
  }
}
