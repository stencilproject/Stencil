import Spectre
import PathKit
@testable import Stencil


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
    
    func expectedSyntaxError(token: String, template: Template, description: String) -> TemplateSyntaxError {
      var error = TemplateSyntaxError(description)
      error.lexeme = Token.block(value: token, at: template.templateString.range(of: token)!)
      let context = ErrorReporterContext(template: template)
      error = environment.errorReporter.contextAwareError(error, context: context) as! TemplateSyntaxError
      print(error)
      return error
    }
    
    $0.it("reports syntax error on invalid for tag syntax") {
      let template: Template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
      let error = expectedSyntaxError(
        token: "{% for name in %}",
        template: template,
        description: "'for' statements should use the following syntax 'for x in y where condition'."
      )
      try expect(try environment.renderTemplate(string: template.templateString, context:["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.it("reports syntax error on missing endfor") {
      let template: Template = "{% for name in names %}{{ name }}"
      let error = expectedSyntaxError(
        token: "{% for name in names %}",
        template: template,
        description: "`endfor` was not found."
      )
      try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.it("reports syntax error on unknown tag") {
      let template: Template = "{% for name in names %}{{ name }}{% end %}"
      let error = expectedSyntaxError(
        token: "{% end %}",
        template: template,
        description: "Unknown template tag 'end'"
      )
      try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.context("given unknown filter") {
      func expectedFilterError(token: String, template: Template) -> TemplateSyntaxError {
        return expectedSyntaxError(
          token: token,
          template: template,
          description: "Unknown filter 'unknown'"
        )
      }
      
      $0.it("reports syntax error in for tag") {
        let template: Template = "{% for name in names|unknown %}{{ name }}{% endfor %}"
        let error = expectedFilterError(token: "names|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
      }
      
      $0.it("reports syntax error in for-where tag") {
        let template: Template = "{% for name in names where name|unknown %}{{ name }}{% endfor %}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
      }
      
      $0.it("reports syntax error in if tag") {
        let template: Template = "{% if name|unknown %}{{ name }}{% endif %}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
      
      $0.it("reports syntax error in elif tag") {
        let template: Template = "{% if name %}{{ name }}{% elif name|unknown %}{% endif %}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
      
      $0.it("reports syntax error in ifnot tag") {
        let template: Template = "{% ifnot name|unknown %}{{ name }}{% endif %}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
      
      $0.it("reports syntax error in filter tag") {
        let template: Template = "{% filter unknown %}Text{% endfilter %}"
        let error = expectedFilterError(token: "{% filter unknown %}", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: [:])).toThrow(error)
      }
      
      $0.it("reports syntax error in variable tag") {
        let template: Template = "{{ name|unknown }}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
    }
    
    $0.context("given related templates") {
      let path = Path(#file) + ".." + "fixtures"
      let loader = FileSystemLoader(paths: [path])
      let environment = Environment(loader: loader)
      
      $0.it("reports syntax error in included template") {
        let template: Template = "{% include \"invalid-include.html\"%}"
        environment.errorReporter.context = ErrorReporterContext(template: template)
        
        let context = Context(dictionary: ["target": "World"], environment: environment)
        
        let includedTemplate = try environment.loadTemplate(name: "invalid-include.html")
        let error = expectedSyntaxError(token: "target|unknown", template: includedTemplate, description: "Unknown filter 'unknown'")
        
        try expect(try template.render(context)).toThrow(error)
      }
      
      $0.it("reports syntax error in extended template") {
        let template = try environment.loadTemplate(name: "invalid-child-super.html")
        let context = Context(dictionary: ["target": "World"], environment: environment)

        let baseTemplate = try environment.loadTemplate(name: "invalid-base.html")
        let error = expectedSyntaxError(token: "target|unknown", template: baseTemplate, description: "Unknown filter 'unknown'")
        
        try expect(try template.render(context)).toThrow(error)
      }
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
