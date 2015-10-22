import Spectre
import Stencil


describe("Template") {
  $0.it("can render a template from a string") {
    let context = Context(dictionary: [ "name": "Kyle" ])
    let template = Template(templateString: "Hello World")
    let result = try template.render(context)
    try expect(result) == "Hello World"
  }
}
