import Spectre
import Stencil


describe("template filters") {
  let context = Context(dictionary: ["name": "Kyle"])

  $0.it("allows you to register a custom filter") {
    let template = Template(templateString: "{{ name|repeat }}")
    let namespace = Namespace()
    let filter = Filter() { value in
      if let value = value as? String {
        return "\(value) \(value)"
      }

      return nil
    }
    namespace.registerFilter("repeat", filter: filter)

    let result = try template.render(context, namespace: namespace)
    try expect(result) == "Kyle Kyle"
  }

  $0.it("allows you to register a custom filter") {
    let template = Template(templateString: "{{ name|repeat }}")
    let namespace = Namespace()
    let filter = Filter() { value in
      throw TemplateSyntaxError("No Repeat")
    }
    namespace.registerFilter("repeat", filter: filter) 

    try expect(try template.render(context, namespace: namespace)).toThrow(TemplateSyntaxError("No Repeat"))
  }

  $0.it("allows whitespace in expression") {
    let template = Template(templateString: "{{ name | uppercase }}")
    let result = try template.render(Context(dictionary: ["name": "kyle"]))
    try expect(result) == "KYLE"
  }

  $0.it("allows you to pass arguments to filter function") {
    let template = Template(templateString: "{{ name|repeat:3 }}")
    let namespace = Namespace()
    let filter = Filter() { value, arguments in
      guard let value = value as? String, let repeatCount = arguments.first as? Int else {
        return nil
      }
      
      let values: [String] = Array(count: repeatCount, repeatedValue: value)
      return values.joinWithSeparator(" ")
    }
    namespace.registerFilter("repeat", filter: filter) 

    let result = try template.render(context, namespace: namespace)
    try expect(result) == "Kyle Kyle Kyle"
  }

  $0.it("throws error when passing too many arguments") {
    let template = Template(templateString: "{{ name|repeat:5 }}")
    let namespace = Namespace()
    let filter = Filter() { value in
      return nil
    }
    namespace.registerFilter("repeat", filter: filter)

    try expect(try template.render(context, namespace: namespace)).toThrow(TemplateSyntaxError("Filter 'repeat' expects no arguments. 1 argument(s) received"))
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
