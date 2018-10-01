import XCTest
import Spectre
@testable import Stencil

class TemplateTests: XCTestCase {
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

    }
  }
}
