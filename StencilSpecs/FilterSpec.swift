import Spectre
import Stencil


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
