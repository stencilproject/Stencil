import Spectre
import Stencil


func testEnvironment() {
  describe("Environment") {
    let environment = Environment(loader: ExampleLoader())

    $0.it("can load a template from a name") {
      let template = try environment.loadTemplate(name: "example.html")
      try expect(template.name) == "example.html"
    }

    $0.it("can load a template from a names") {
      let template = try environment.loadTemplate(names: ["first.html", "example.html"])
      try expect(template.name) == "example.html"
    }

    $0.it("can render a template from a string") {
      let result = try environment.renderTemplate(string: "Hello World")
      try expect(result) == "Hello World"
    }

    $0.it("can render a template from a file") {
      let result = try environment.renderTemplate(name: "example.html")
      try expect(result) == "Hello World!"
    }

    $0.it("allows you to provide a custom template class") {
      let environment = Environment(loader: ExampleLoader(), templateClass: CustomTemplate.self)
      let result = try environment.renderTemplate(string: "Hello World")

      try expect(result) == "here"
    }
  }
}


fileprivate class ExampleLoader: Loader {
  func loadTemplate(name: String, environment: Environment) throws -> Template {
    if name == "example.html" {
      return Template(templateString: "Hello World!", environment: environment, name: name)
    }

    throw TemplateDoesNotExist(templateNames: [name], loader: self)
  }
}


class CustomTemplate: Template {
  override func render(_ dictionary: [String: Any]? = nil) throws -> String {
    return "here"
  }
}
