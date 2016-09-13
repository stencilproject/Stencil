import XCTest


public func stencilTests() {
  testContext()
  testFilter()
  testLexer()
  testToken()
  testTokenParser()
  testTemplateLoader()
  testTemplate()
  testVariable()
  testNode()
  testForNode()
  testIfNode()
  testNowNode()
  testInclude()
  testInheritence()
  testStencil()

}


class StencilTests: XCTestCase {
  func testRunStencilTests() {
    stencilTests()
  }
}
