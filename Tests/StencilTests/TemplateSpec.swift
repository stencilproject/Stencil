import Spectre
import Stencil


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
    $0.it("Respects whitespace control symbols in for tags") {
      let template: Template = "{% for num in numbers -%}\n    {{num}}\n{%- endfor %}"
      let result = try template.render([ "numbers": Array(1...9) ])
      try expect(result) == "123456789"
    }
    $0.it("Respects whitespace control symbols in if tags") {
      let template: Template = "{% if value -%}\n    {{text}}\n{%- endif %}"
      let result = try template.render([ "text": "hello", "value": true ])
      try expect(result) == "hello"
    }
    $0.it("Respects whitespace control symbols in ifnot tags") {
      let template: Template = "{% ifnot value %}{% else -%}\n    {{text}}\n{%- endif %}"
      let result = try template.render([ "text": "hello", "value": true ])
      try expect(result) == "hello"
    }
  }
}
