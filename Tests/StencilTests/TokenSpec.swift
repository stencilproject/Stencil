//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class TokenTests: XCTestCase {
  func testToken() {
    it("can split the contents into components") {
      let token = Token.text(value: "hello world", at: .unknown)
      let components = token.components

      try expect(components.count) == 2
      try expect(components[0]) == "hello"
      try expect(components[1]) == "world"
    }

    it("can split the contents into components with single quoted strings") {
      let token = Token.text(value: "hello 'kyle fuller'", at: .unknown)
      let components = token.components

      try expect(components.count) == 2
      try expect(components[0]) == "hello"
      try expect(components[1]) == "'kyle fuller'"
    }

    it("can split the contents into components with double quoted strings") {
      let token = Token.text(value: "hello \"kyle fuller\"", at: .unknown)
      let components = token.components

      try expect(components.count) == 2
      try expect(components[0]) == "hello"
      try expect(components[1]) == "\"kyle fuller\""
    }
  }
}
