import Foundation
import XCTest
import Stencil

class TemplateTests: XCTestCase {
  func testTemplate() {
    let context = Context(dictionary: [ "name": "Kyle" ])
    let template = Template(templateString: "Hello World")
    let result = try? template.render(context)
    XCTAssertEqual(result, "Hello World")
  }
}
