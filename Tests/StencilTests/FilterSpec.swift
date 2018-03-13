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

  describe("string filters") {
    $0.context("given string") {
      $0.it("transforms a string to be capitalized") {
        let template = Template(templateString: "{{ name|capitalize }}")
        let result = try template.render(Context(dictionary: ["name": "kyle"]))
        try expect(result) == "Kyle"
      }

      $0.it("transforms a string to be uppercase") {
        let template = Template(templateString: "{{ name|uppercase }}")
        let result = try template.render(Context(dictionary: ["name": "kyle"]))
        try expect(result) == "KYLE"
      }

      $0.it("transforms a string to be lowercase") {
        let template = Template(templateString: "{{ name|lowercase }}")
        let result = try template.render(Context(dictionary: ["name": "Kyle"]))
        try expect(result) == "kyle"
      }
    }

    $0.context("given array of strings") {
      $0.it("transforms a string to be capitalized") {
        let template = Template(templateString: "{{ names|capitalize }}")
        let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
        try expect(result) == "[\"Kyle\", \"Kyle\"]"
      }

      $0.it("transforms a string to be uppercase") {
        let template = Template(templateString: "{{ names|uppercase }}")
        let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
        try expect(result) == "[\"KYLE\", \"KYLE\"]"
      }

      $0.it("transforms a string to be lowercase") {
        let template = Template(templateString: "{{ names|lowercase }}")
        let result = try template.render(Context(dictionary: ["names": ["Kyle", "Kyle"]]))
        try expect(result) == "[\"kyle\", \"kyle\"]"
      }
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

    $0.it("can use int as default") {
      let template = Template(templateString: "{{ value|default:1 }}")
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "1"
    }

    $0.it("can use float as default") {
      let template = Template(templateString: "{{ value|default:1.5 }}")
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "1.5"
    }

    $0.it("checks for underlying nil value correctly") {
      let template = Template(templateString: "Hello {{ user.name|default:\"anonymous\" }}")
      let nilName: String? = nil
      let user: [String: Any?] = ["name": nilName]
      let result = try template.render(Context(dictionary: ["user": user]))
      try expect(result) == "Hello anonymous"
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

  describe("split filter") {
    let template = Template(templateString: "{{ value|split:\", \" }}")

    $0.it("split a string into array") {
      let result = try template.render(Context(dictionary: ["value": "One, Two"]))
      try expect(result) == "[\"One\", \"Two\"]"
    }

    $0.it("can split without arguments") {
      let template = Template(templateString: "{{ value|split }}")
      let result = try template.render(Context(dictionary: ["value": "One, Two"]))
      try expect(result) == "[\"One,\", \"Two\"]"
    }
  }


  describe("filter suggestion") {

    $0.it("made for unknown filter") {
      let template = Template(templateString: "{{ value|unknownFilter }}")
      let expectedError = TemplateSyntaxError("Unknown filter 'unknownFilter'. Found similar filters: 'knownFilter'")

      let filterExtension = Extension()
      filterExtension.registerFilter("knownFilter") { value, _ in value }

      try expect(template.render(Context(dictionary: [:], environment: Environment(extensions: [filterExtension])))).toThrow(expectedError)
    }

    $0.it("made for multiple similar filters") {
      let template = Template(templateString: "{{ value|lowerFirst }}")
      let expectedError = TemplateSyntaxError("Unknown filter 'lowerFirst'. Found similar filters: 'lowerFirstWord', 'lowercase'")

      let filterExtension = Extension()
      filterExtension.registerFilter("lowerFirstWord") { value, _ in value }
      filterExtension.registerFilter("lowerFirstLetter") { value, _ in value }

      try expect(template.render(Context(dictionary: [:], environment: Environment(extensions: [filterExtension])))).toThrow(expectedError)
    }

    $0.it("not made when can't find similar filter") {
      let template = Template(templateString: "{{ value|unknownFilter }}")
      let expectedError = TemplateSyntaxError("Unknown filter 'unknownFilter'.")
      try expect(template.render(Context(dictionary: [:]))).toThrow(expectedError)
    }

  }


  describe("indent filter") {
    $0.it("indents content") {
      let template = Template(templateString: "{{ value|indent:2 }}")
      let result = try template.render(Context(dictionary: ["value": "One\nTwo"]))
      try expect(result) == "One\n  Two"
    }

    $0.it("can indent with arbitrary character") {
      let template = Template(templateString: "{{ value|indent:2,\"\t\" }}")
      let result = try template.render(Context(dictionary: ["value": "One\nTwo"]))
      try expect(result) == "One\n\t\tTwo"
    }

    $0.it("can indent first line") {
      let template = Template(templateString: "{{ value|indent:2,\" \",true }}")
      let result = try template.render(Context(dictionary: ["value": "One\nTwo"]))
      try expect(result) == "  One\n  Two"
    }

    $0.it("does not indent empty lines") {
      let template = Template(templateString: "{{ value|indent }}")
      let result = try template.render(Context(dictionary: ["value": "One\n\n\nTwo\n\n"]))
      try expect(result) == "One\n\n\n    Two\n\n"
    }
  }
}
