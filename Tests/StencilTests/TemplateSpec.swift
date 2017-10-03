import Spectre
@testable import Stencil


func testTemplate() {
  describe("Template") {
    $0.it("can render a template from a string") {
      let template = Template(templateString: "Hello World")
      let result = try template.render([ "name": "Kyle" ])
      try expect(result) == "Hello World"
    }

    $0.it("can render a template from a string literal") {
        let template: Template = "Hello World"
        let result = try template.render([ "name": "Kyle" ])
        try expect(result) == "Hello World"
    }

    $0.it("throws syntax error on invalid for tag syntax") {
      let template: Template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
      var error = TemplateSyntaxError("'for' statements should use the following syntax 'for x in y where condition'.")
      error.token = Token.block(value: "{% for name in %}", at: template.templateString.range(of: "{% for name in %}")!)
      error = error.contextAwareError(templateName: nil, templateContent: template.templateString)!
      try expect(try template.render(["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
    $0.it("throws syntax error on missing endfor") {
      let template: Template = "{% for name in names %}{{ name }}"
      var error = TemplateSyntaxError("`endfor` was not found.")
      error.token = Token.block(value: "{% for name in names %}", at: template.templateString.range(of: "{% for name in names %}")!)
      error = error.contextAwareError(templateName: nil, templateContent: template.templateString)!
      try expect(try template.render(["names": ["Bob", "Alice"]])).toThrow(error)
    }

    $0.it("throws syntax error on unknown tag") {
      let template: Template = "{% for name in names %}{{ name }}{% end %}"
      var error = TemplateSyntaxError("Unknown template tag 'end'")
      error.token = Token.block(value: "{% end %}", at: template.templateString.range(of: "{% end %}")!)
      error = error.contextAwareError(templateName: nil, templateContent: template.templateString)!
      try expect(try template.render(["names": ["Bob", "Alice"]])).toThrow(error)
    }
    
  }
}
