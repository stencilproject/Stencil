import XCTest

import StencilTests

var tests = [XCTestCaseEntry]()
tests += StencilTests.__allTests()

XCTMain(tests)
