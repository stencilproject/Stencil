import Foundation
import XCTest
import Stencil
import CatchingFire

class TemplateTests: XCTestCase {

  func testTemplate() {
    let context = Context(dictionary: [ "name": "Kyle" ])
    let template = Template(templateString: "Hello World")
    AssertNoThrow() {
      let result = try template.render(context)
      XCTAssertEqual(result, "Hello World")
    }
  }

}
