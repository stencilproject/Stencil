import Spectre
@testable import Stencil


func testFilter() {
  describe("template filters") {
    let context: [String: Any] = ["name": "Kyle"]

    $0.it("allows you to register a custom filter") {
      let template = Template(templateString: "{{ name|repeat }}")

      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { (value: Any?) in
        if let value = value as? String {
          return "\(value) \(value)"
        }

        return nil
      }

      let result = try template.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
      try expect(result) == "Kyle Kyle"
    }

    $0.it("allows you to register a custom filter which accepts single argument") {
      let template = Template(templateString: "{{ name|repeat:'value1, \"value2\"' }}")

      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { value, arguments in
        if !arguments.isEmpty {
          return "\(value!) \(value!) with args \(arguments.first!!)"
        }

        return nil
      }

      let result = try template.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
      try expect(result) == "Kyle Kyle with args value1, \"value2\""
    }

    $0.it("allows you to register a custom filter which accepts several arguments") {
        let template = Template(templateString: "{{ name|repeat:'value\"1\"',\"value'2'\",'(key, value)' }}")

        let repeatExtension = Extension()
        repeatExtension.registerFilter("repeat") { value, arguments in
            if !arguments.isEmpty {
                return "\(value!) \(value!) with args 0: \(arguments[0]!), 1: \(arguments[1]!), 2: \(arguments[2]!)"
            }

            return nil
        }

        let result = try template.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
        try expect(result) == "Kyle Kyle with args 0: value\"1\", 1: value'2', 2: (key, value)"
    }

    $0.it("allows you to register a custom which throws") {
      let template = Template(templateString: "{{ name|repeat }}")
      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { (value: Any?) in
        throw TemplateSyntaxError("No Repeat")
      }

      let context = Context(dictionary: context, environment: Environment(extensions: [repeatExtension]))
      try expect(try template.render(context)).toThrow(TemplateSyntaxError("No Repeat"))
    }

    $0.it("allows you to override a default filter") {
      let template = Template(templateString: "{{ name|join }}")

      let repeatExtension = Extension()
      repeatExtension.registerFilter("join") { (value: Any?) in
        return "joined"
      }

      let result = try template.render(Context(dictionary: context, environment: Environment(extensions: [repeatExtension])))
      try expect(result) == "joined"
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

    $0.it("supports multiple defaults") {
      let template = Template(templateString: "Hello {{ name|default:a,b,c,\"World\" }}")
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "Hello World"
    }
  }

  describe("join filter") {
    let template = Template(templateString: "{{ value|join:\", \" }}")

    $0.it("joins a collection of strings") {
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "One, Two"
    }

    $0.it("joins a mixed-type collection") {
      let result = try template.render(Context(dictionary: ["value": ["One", 2, true, 10.5, "Five"]]))
      try expect(result) == "One, 2, true, 10.5, Five"
    }

    $0.it("can join by non string") {
      let template = Template(templateString: "{{ value|join:separator }}")
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"], "separator": true]))
      try expect(result) == "OnetrueTwo"
    }

    $0.it("can join without arguments") {
      let template = Template(templateString: "{{ value|join }}")
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "OneTwo"
    }
  }
}
