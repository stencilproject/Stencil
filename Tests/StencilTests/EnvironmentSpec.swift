import Spectre
import PathKit
@testable import Stencil


func testEnvironment() {
  describe("Environment") {
    var environment: Environment!
    var template: Template!
    
    $0.before {
      environment =  Environment(loader: ExampleLoader())
      template = nil
    }

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
      guard let range = template.templateString.range(of: token) else {
        fatalError("Can't find '\(token)' in '\(template)'")
      }
      let rangeLine = template.templateString.rangeLine(range)
      let sourceMap = SourceMap(filename: template.name, line: rangeLine)
      let token = Token.block(value: token, at: sourceMap)
      return TemplateSyntaxError(reason: description, token: token, stackTrace: [])
    }

    func expectError(reason: String, token: String,
                     file: String = #file, line: Int = #line, function: String = #function) throws {
      let expectedError = expectedSyntaxError(token: token, template: template, description: reason)
      
      let error = try expect(environment.render(template: template, context: ["names": ["Bob", "Alice"], "name": "Bob"]),
                             file: file, line: line, function: function).toThrow() as TemplateSyntaxError
      let reporter = SimpleErrorReporter()
      try expect(reporter.renderError(error), file: file, line: line, function: function) == reporter.renderError(expectedError)
    }

    $0.context("given syntax error") {

      $0.it("reports syntax error on invalid for tag syntax") {
        template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
        try expectError(reason: "'for' statements should use the syntax: `for <x> in <y> [where <condition>]`.", token: "for name in")
      }
      
      $0.it("reports syntax error on missing endfor") {
        template = "{% for name in names %}{{ name }}"
        try expectError(reason: "`endfor` was not found.", token: "for name in names")
      }
      
      $0.it("reports syntax error on unknown tag") {
        template = "{% for name in names %}{{ name }}{% end %}"
        try expectError(reason: "Unknown template tag 'end'", token: "end")
      }

    }
    
    $0.context("given unknown filter") {
      
      $0.it("reports syntax error in for tag") {
        template = "{% for name in names|unknown %}{{ name }}{% endfor %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "names|unknown")
      }
      
      $0.it("reports syntax error in for-where tag") {
        template = "{% for name in names where name|unknown %}{{ name }}{% endfor %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "name|unknown")
      }
      
      $0.it("reports syntax error in if tag") {
        template = "{% if name|unknown %}{{ name }}{% endif %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "name|unknown")
      }
      
      $0.it("reports syntax error in elif tag") {
        template = "{% if name %}{{ name }}{% elif name|unknown %}{% endif %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "name|unknown")
      }
      
      $0.it("reports syntax error in ifnot tag") {
        template = "{% ifnot name|unknown %}{{ name }}{% endif %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "name|unknown")
      }
      
      $0.it("reports syntax error in filter tag") {
        template = "{% filter unknown %}Text{% endfilter %}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "filter unknown")
      }
      
      $0.it("reports syntax error in variable tag") {
        template = "{{ name|unknown }}"
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.", token: "name|unknown")
      }
      
    }
    
    $0.context("given rendering error") {
      
      $0.it("reports rendering error in variable filter") {
        let filterExtension = Extension()
        filterExtension.registerFilter("throw") { (value: Any?) in
          throw TemplateSyntaxError("filter error")
        }
        environment.extensions += [filterExtension]

        template = Template(templateString: "{{ name|throw }}", environment: environment)
        try expectError(reason: "filter error", token: "name|throw")
      }
      
      $0.it("reports rendering error in filter tag") {
        let filterExtension = Extension()
        filterExtension.registerFilter("throw") { (value: Any?) in
          throw TemplateSyntaxError("filter error")
        }
        environment.extensions += [filterExtension]

        template = Template(templateString: "{% filter throw %}Test{% endfilter %}", environment: environment)
        try expectError(reason: "filter error", token: "filter throw")
      }
      
      $0.it("reports rendering error in simple tag") {
        let tagExtension = Extension()
        tagExtension.registerSimpleTag("simpletag") { context in
          throw TemplateSyntaxError("simpletag error")
        }
        environment.extensions += [tagExtension]

        template = Template(templateString: "{% simpletag %}", environment: environment)
        try expectError(reason: "simpletag error", token: "simpletag")
      }
      
      $0.it("reporsts passing argument to simple filter") {
        template = "{{ name|uppercase:5 }}"
        try expectError(reason: "cannot invoke filter with an argument", token: "name|uppercase:5")
      }
      
      $0.it("reports rendering error in custom tag") {
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]
        
        template = Template(templateString: "{% customtag %}", environment: environment)
        try expectError(reason: "Custom Error", token: "customtag")
      }
      
      $0.it("reports rendering error in for body") {
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]

        template = Template(templateString: "{% for name in names %}{% customtag %}{% endfor %}", environment: environment)
        try expectError(reason: "Custom Error", token: "customtag")
      }
      
      $0.it("reports rendering error in block") {
        let tagExtension = Extension()
        tagExtension.registerTag("customtag") { parser, token in
          return ErrorNode(token: token)
        }
        environment.extensions += [tagExtension]

        template = Template(templateString: "{% block some %}{% customtag %}{% endblock %}", environment: environment)
        try expectError(reason: "Custom Error", token: "customtag")
      }
    }
    
    $0.context("given included template") {
      let path = Path(#file) + ".." + "fixtures"
      let loader = FileSystemLoader(paths: [path])
      var environment = Environment(loader: loader)
      var template: Template!
      var includedTemplate: Template!
      
      $0.before {
        environment = Environment(loader: loader)
        template = nil
        includedTemplate = nil
      }
      
      func expectError(reason: String, token: String, includedToken: String,
                       file: String = #file, line: Int = #line, function: String = #function) throws {
        var expectedError = expectedSyntaxError(token: token, template: template, description: reason)
        expectedError.stackTrace = [expectedSyntaxError(token: includedToken, template: includedTemplate, description: reason).token!]
        
        let error = try expect(environment.render(template: template, context: ["target": "World"]),
                               file: file, line: line, function: function).toThrow() as TemplateSyntaxError
        let reporter = SimpleErrorReporter()
        try expect(reporter.renderError(error), file: file, line: line, function: function) == reporter.renderError(expectedError)
      }
      
      $0.it("reports syntax error in included template") {
        template = Template(templateString: "{% include \"invalid-include.html\" %}", environment: environment)
        includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
                        token: "include \"invalid-include.html\"",
                        includedToken: "target|unknown")
      }
      
      $0.it("reports runtime error in included template") {
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]
        
        template = Template(templateString: "{% include \"invalid-include.html\" %}", environment: environment)
        includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

        try expectError(reason: "filter error",
                        token: "include \"invalid-include.html\"",
                        includedToken: "target|unknown")
      }
      
    }
    
    $0.context("given base and child templates") {
      let path = Path(#file) + ".." + "fixtures"
      let loader = FileSystemLoader(paths: [path])
      var environment: Environment!
      var childTemplate: Template!
      var baseTemplate: Template!

      $0.before {
        environment = Environment(loader: loader)
        childTemplate = nil
        baseTemplate = nil
      }
      
      func expectError(reason: String, childToken: String, baseToken: String?,
                       file: String = #file, line: Int = #line, function: String = #function) throws {
        var expectedError = expectedSyntaxError(token: childToken, template: childTemplate, description: reason)
        if let baseToken = baseToken {
          expectedError.stackTrace = [expectedSyntaxError(token: baseToken, template: baseTemplate, description: reason).token!]
        }
        let error = try expect(environment.render(template: childTemplate, context: ["target": "World"]),
                               file: file, line: line, function: function).toThrow() as TemplateSyntaxError
        let reporter = SimpleErrorReporter()
        try expect(reporter.renderError(error), file: file, line: line, function: function) == reporter.renderError(expectedError)
      }

      $0.it("reports syntax error in base template") {
        childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
        baseTemplate = try environment.loadTemplate(name: "invalid-base.html")
        
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
                        childToken: "extends \"invalid-base.html\"",
                        baseToken: "target|unknown")
      }
      
      $0.it("reports runtime error in base template") {
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]

        childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
        baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

        try expectError(reason: "filter error",
                        childToken: "block.super",
                        baseToken: "target|unknown")
      }
      
      $0.it("reports syntax error in child template") {
        childTemplate = Template(templateString: "{% extends \"base.html\" %}\n" +
          "{% block body %}Child {{ target|unknown }}{% endblock %}", environment: environment, name: nil)
        
        try expectError(reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
                        childToken: "target|unknown",
                        baseToken: nil)
      }
      
      $0.it("reports runtime error in child template") {
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown", filter: {  (_: Any?) in
          throw TemplateSyntaxError("filter error")
        })
        environment.extensions += [filterExtension]

        childTemplate = Template(templateString: "{% extends \"base.html\" %}\n" +
          "{% block body %}Child {{ target|unknown }}{% endblock %}", environment: environment, name: nil)

        try expectError(reason: "filter error",
                        childToken: "target|unknown",
                        baseToken: nil)
      }
      
    }
    
  }
}

extension Expectation {
  @discardableResult
  func toThrow<T: Error>() throws -> T {
    var thrownError: Error? = nil
    
    do {
      _ = try expression()
    } catch {
      thrownError = error
    }
    
    if let thrownError = thrownError {
      if let thrownError = thrownError as? T {
        return thrownError
      } else {
        throw failure("\(thrownError) is not \(T.self)")
      }
    } else {
      throw failure("expression did not throw an error")
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
