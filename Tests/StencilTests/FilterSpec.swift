import Spectre
import Stencil


func testFilter() {
  describe("template filters") {
    let context: [String: Any] = ["name": "Kyle"]

    $0.it("allows you to register a custom filter") {
      let template = Template(templateString: "{{ name|repeat }}")

      let namespace = Namespace()
      namespace.registerFilter("repeat") { (value: Any?) in
        if let value = value as? String {
          return "\(value) \(value)"
        }

        return nil
      }

      let result = try template.render(Context(dictionary: context, namespace: namespace))
      try expect(result) == "Kyle Kyle"
    }

    $0.it("allows you to register a custom filter which accepts arguments") {
      let template = Template(templateString: "{{ name|repeat:'value' }}")

      let namespace = Namespace()
      namespace.registerFilter("repeat") { value, arguments in
        print(arguments)
        if !arguments.isEmpty {
          return "\(value!) \(value!) with args \(arguments.first!!)"
        }

        return nil
      }

      let result = try template.render(Context(dictionary: context, namespace: namespace))
      try expect(result) == "Kyle Kyle with args value"
    }

    $0.it("allows you to register a custom which throws") {
      let template = Template(templateString: "{{ name|repeat }}")
      let namespace = Namespace()
      namespace.registerFilter("repeat") { (value: Any?) in
        throw TemplateSyntaxError("No Repeat")
      }

      try expect(try template.render(Context(dictionary: context, namespace: namespace))).toThrow(TemplateSyntaxError("No Repeat"))
    }

    $0.it("allows whitespace in expression") {
      let template = Template(templateString: "{{ name | uppercase }}")
      let result = try template.render(Context(dictionary: ["name": "kyle"]))
      try expect(result) == "KYLE"
    }

    $0.it("throws when you pass arguments to simple filter") {
      let template = Template(templateString: "{{ name|uppercase:5 }}")
      try expect(try template.render(Context(dictionary: ["name": "kyle"]))).toThrow()
    }
  }


  describe("capitalize filter") {
    let template = Template(templateString: "{{ name|capitalize }}")

    $0.it("capitalizes a string") {
      let result = try template.render(Context(dictionary: ["name": "kyle"]))
      try expect(result) == "Kyle"
    }
  }


  describe("uppercase filter") {
    let template = Template(templateString: "{{ name|uppercase }}")

    $0.it("transforms a string to be uppercase") {
      let result = try template.render(Context(dictionary: ["name": "kyle"]))
      try expect(result) == "KYLE"
    }
  }

  describe("lowercase filter") {
    let template = Template(templateString: "{{ name|lowercase }}")

    $0.it("transforms a string to be lowercase") {
      let result = try template.render(Context(dictionary: ["name": "Kyle"]))
      try expect(result) == "kyle"
    }
  }

  describe("default filter") {
    let template = Template(templateString: "Hello {{ name|default:\"World\" }}")

    $0.it("shows the variable value") {
      let result = try template.render(Context(dictionary: ["name": "Kyle"]))
      try expect(result) == "Hello Kyle"
    }

    $0.it("shows the default value") {
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "Hello World"
    }
  }

  describe("join filter") {
    let template = Template(templateString: "{{ value|join:\", \" }}")

    $0.it("transforms a string to be lowercase") {
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "One, Two"
    }
  }
}
