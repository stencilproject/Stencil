import Spectre
import Stencil


describe("template filters") {
  let context = Context(dictionary: ["name": "Kyle"])

  $0.it("allows you to register a custom filter") {
    let template = Template(templateString: "{{ name|repeat }}")

    let namespace = Namespace()
    namespace.registerFilter("repeat") { value in
      if let value = value as? String {
        return "\(value) \(value)"
      }

      return nil
    }

    let result = try template.render(context, namespace: namespace)
    try expect(result) == "Kyle Kyle"
  }

  $0.it("allows you to register a custom filter") {
    let template = Template(templateString: "{{ name|repeat }}")
    let namespace = Namespace()
    namespace.registerFilter("repeat") { value in
      throw TemplateSyntaxError("No Repeat")
    }

    try expect(try template.render(context, namespace: namespace)).toThrow(TemplateSyntaxError("No Repeat"))
  }

  $0.it("allows whitespace in expression") {
    let template = Template(templateString: "{{ name | uppercase }}")
    let result = try template.render(Context(dictionary: ["name": "kyle"]))
    try expect(result) == "KYLE"
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
