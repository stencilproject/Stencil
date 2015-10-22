import XCTest
import Stencil


class FilterTests: XCTestCase {
  func testCapitalizeFilter() {
    let template = Template(templateString: "{{ name|capitalize }}")
    let result = try? template.render(Context(dictionary: ["name": "kyle"]))
    XCTAssertEqual(result, "Kyle")
  }

  func testUppercaseFilter() {
    let template = Template(templateString: "{{ name|uppercase }}")
    let result = try? template.render(Context(dictionary: ["name": "kyle"]))
    XCTAssertEqual(result, "KYLE")
  }

  func testLowercaseFilter() {
    let template = Template(templateString: "{{ name|lowercase }}")
    let result = try? template.render(Context(dictionary: ["name": "Kyle"]))
    XCTAssertEqual(result, "kyle")
  }
}