import Spectre
@testable import Stencil
import XCTest

final class ContextTests: XCTestCase {
  func testContextSubscripting() {
    describe("Context Subscripting") {
      var context = Context()
      $0.before {
        context = Context(dictionary: ["name": "Kyle"])
      }

      $0.it("allows you to get a value via subscripting") {
        try expect(context["name"] as? String) == "Kyle"
      }

      $0.it("allows you to set a value via subscripting") {
        context["name"] = "Katie"

        try expect(context["name"] as? String) == "Katie"
      }

      $0.it("allows you to remove a value via subscripting") {
        context["name"] = nil

        try expect(context["name"]).to.beNil()
      }

      $0.it("allows you to retrieve a value from a parent") {
        try context.push {
          try expect(context["name"] as? String) == "Kyle"
        }
      }

      $0.it("allows you to override a parent's value") {
        try context.push {
          context["name"] = "Katie"
          try expect(context["name"] as? String) == "Katie"
        }
      }
    }
  }

  func testContextRestoration() {
    describe("Context Restoration") {
      var context = Context()
      $0.before {
        context = Context(dictionary: ["name": "Kyle"])
      }

      $0.it("allows you to pop to restore previous state") {
        context.push {
          context["name"] = "Katie"
        }

        try expect(context["name"] as? String) == "Kyle"
      }

      $0.it("allows you to remove a parent's value in a level") {
        try context.push {
          context["name"] = nil
          try expect(context["name"]).to.beNil()
        }

        try expect(context["name"] as? String) == "Kyle"
      }

      $0.it("allows you to push a dictionary and run a closure then restoring previous state") {
        var didRun = false

        try context.push(dictionary: ["name": "Katie"]) {
          didRun = true
          try expect(context["name"] as? String) == "Katie"
        }

        try expect(didRun).to.beTrue()
        try expect(context["name"] as? String) == "Kyle"
      }

      $0.it("allows you to flatten the context contents") {
        try context.push(dictionary: ["test": "abc"]) {
          let flattened = context.flatten()

          try expect(flattened.count) == 2
          try expect(flattened["name"] as? String) == "Kyle"
          try expect(flattened["test"] as? String) == "abc"
        }
      }
    }
  }
}
