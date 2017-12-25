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
      let lexeme = Token.block(value: token, at: template.templateString.range(of: token)!)
      return TemplateSyntaxError(reason: description, lexeme: lexeme, template: template, parentError: nil)
    }
    
    $0.it("reports syntax error on invalid for tag syntax") {
      let template: Template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
      let error = expectedSyntaxError(token: "for name in", template: template, description: "'for' statements should use the following syntax 'for x in y where condition'.")
      try expect(try environment.renderTemplate(string: template.templateString, context:["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.it("reports syntax error on missing endfor") {
      let template: Template = "{% for name in names %}{{ name }}"
      let error = expectedSyntaxError(token: "for name in names", template: template, description: "`endfor` was not found.")
      try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.it("reports syntax error on unknown tag") {
      let template: Template = "{% for name in names %}{{ name }}{% end %}"
      let error = expectedSyntaxError(token: "end", template: template, description: "Unknown template tag 'end'")
      try expect(try environment.renderTemplate(string: template.templateString, context: ["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.context("given unknown filter") {
      func expectedFilterError(token: String, template: Template) -> TemplateSyntaxError {
        return expectedSyntaxError(token: token, template: template, description: "Unknown filter 'unknown'")
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
        let error = expectedFilterError(token: "filter unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: [:])).toThrow(error)
      }
      
      $0.it("reports syntax error in variable tag") {
        let template: Template = "{{ name|unknown }}"
        let error = expectedFilterError(token: "name|unknown", template: template)
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
      
    }
    
    $0.context("given rendering error") {
      $0.it("reports rendering error in variable filter") {
        let template: Template = "{{ name|throw }}"

        var environment = environment
        let filterExtension = Extension()
        filterExtension.registerFilter("throw") { (value: Any?) in
          throw TemplateSyntaxError("Filter rendering error")
        }
        environment.extensions += [filterExtension]
        
        let error = expectedSyntaxError(token: "name|throw", template: template, description: "Filter rendering error")
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "Bob"])).toThrow(error)
      }
      
      $0.it("reports rendering error in filter tag") {
        let template: Template = "{% filter throw %}Test{% endfilter %}"
        
        var environment = environment
        let filterExtension = Extension()
        filterExtension.registerFilter("throw") { (value: Any?) in
          throw TemplateSyntaxError("Filter rendering error")
        }
        environment.extensions += [filterExtension]
        
        let error = expectedSyntaxError(token: "filter throw", template: template, description: "Filter rendering error")
        try expect(try environment.renderTemplate(string: template.templateString, context: [:])).toThrow(error)
      }
      
      $0.it("reports rendering error in simple tag") {
        let template: Template = "{% simpletag %}"

        var environment = environment
        let tagExtension = Extension()
        tagExtension.registerSimpleTag("simpletag") { context in
          throw TemplateSyntaxError("simpletag error")
        }
        environment.extensions += [tagExtension]
        
        let error = expectedSyntaxError(token: "simpletag", template: template, description: "simpletag error")
        try expect(try environment.renderTemplate(string: template.templateString, context: [:])).toThrow(error)
      }
      
      $0.it("reporsts passing argument to simple filter") {
        let template: Template = "{{ name|uppercase:5 }}"
        
        let error = expectedSyntaxError(token: "name|uppercase:5", template: template, description: "cannot invoke filter with an argument")
        try expect(try environment.renderTemplate(string: template.templateString, context: ["name": "kyle"])).toThrow(error)
      }
      
      $0.it("reports rendering error in custom tag") {
        let template: Template = "{% customtag %}"

        var environment = environment
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]
        
        let error = expectedSyntaxError(token: "customtag", template: template, description: "Custom Error")
        try expect(try environment.renderTemplate(string: template.templateString, context: [:])).toThrow(error)
      }
      
      $0.it("reports rendering error in for body") {
        let template: Template = "{% for item in array %}{% customtag %}{% endfor %}"

        var environment = environment
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]
        
        let error = expectedSyntaxError(token: "customtag", template: template, description: "Custom Error")
        try expect(try environment.renderTemplate(string: template.templateString, context: ["array": ["a"]])).toThrow(error)
      }
      
      $0.it("reports rendering error in block") {
        let template: Template = "{% block some %}{% customtag %}{% endblock %}"
        
        var environment = environment
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]
        
        let error = expectedSyntaxError(token: "customtag", template: template, description: "Custom Error")
        try expect(try environment.renderTemplate(string: template.templateString, context: ["array": ["a"]])).toThrow(error)
      }
    }
    
    $0.context("given related templates") {
      let path = Path(#file) + ".." + "fixtures"
      let loader = FileSystemLoader(paths: [path])
      let environment = Environment(loader: loader)
      
      $0.it("reports syntax error in included template") {
        let template: Template = "{% include \"invalid-include.html\" %}"
        let includedTemplate = try environment.loadTemplate(name: "invalid-include.html")
        
        let parentError = expectedSyntaxError(token: "target|unknown", template: includedTemplate, description: "Unknown filter 'unknown'")
        var error = expectedSyntaxError(token: "include \"invalid-include.html\"", template: template, description: "Unknown filter 'unknown'")
        error.parentError = parentError
        
        try expect(environment.renderTemplate(string: template.templateString, context: ["target": "World"])).toThrow(error)
      }
      
      $0.it("reports runtime error in included template") {
        var environment = environment
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]
        
        let template: Template = "{% include \"invalid-include.html\" %}"
        let includedTemplate = try environment.loadTemplate(name: "invalid-include.html")
        
        let parentError = expectedSyntaxError(token: "target|unknown", template: includedTemplate, description: "filter error")
        var error = expectedSyntaxError(token: "include \"invalid-include.html\"", template: template, description: "filter error")
        error.parentError = parentError
        
        try expect(environment.renderTemplate(string: template.templateString, context: ["target": "World"])).toThrow(error)
      }

      $0.it("reports syntax error in base template") {
        let template = try environment.loadTemplate(name: "invalid-child-super.html")
        let baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

        let parentError = expectedSyntaxError(token: "target|unknown", template: baseTemplate, description: "Unknown filter 'unknown'")
        var error = expectedSyntaxError(token: "extends \"invalid-base.html\"", template: template, description: "Unknown filter 'unknown'")
        error.parentError = parentError

        try expect(environment.render(template: template, context: ["target": "World"])).toThrow(error)
      }

      $0.it("reports runtime error in base template") {
        var environment = environment
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]

        let template = try environment.loadTemplate(name: "invalid-child-super.html")
        let baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

        let parentError = expectedSyntaxError(token: "target|unknown", template: baseTemplate, description: "filter error")
        var error = expectedSyntaxError(token: "extends \"invalid-base.html\"", template: template, description: "filter error")
        error.parentError = parentError

        try expect(environment.render(template: template, context: ["target": "World"])).toThrow(error)
      }
      
      $0.it("reports syntax error in child template") {
        let template = Template.init(templateString: "{% extends \"base.html\" %}\n" +
          "{% block body %}Child {{ target|unknown }}{% endblock %}", environment: environment, name: nil)
        let error = expectedSyntaxError(token: "target|unknown", template: template, description: "Unknown filter 'unknown'")
        
        try expect(environment.render(template: template, context: ["target": "World"])).toThrow(error)
      }
      
      $0.it("reports runtime error in child template") {
        var environment = environment
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]
        
        let template = Template.init(templateString: "{% extends \"base.html\" %}\n" +
          "{% block body %}Child {{ target|unknown }}{% endblock %}", environment: environment, name: nil)
        let error = expectedSyntaxError(token: "target|unknown", template: template, description: "filter error")
        
        try expect(environment.render(template: template, context: ["target": "World"])).toThrow(error)
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
