//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class ContextTests: XCTestCase {
  func testContextSubscripting() {
    describe("Context Subscripting") { test in
      var context = Context()
      test.before {
        context = Context(dictionary: ["name": "Kyle"])
      }

      test.it("allows you to get a value via subscripting") {
        try expect(context["name"] as? String) == "Kyle"
      }

      test.it("allows you to set a value via subscripting") {
        context["name"] = "Katie"

        try expect(context["name"] as? String) == "Katie"
      }

      test.it("allows you to remove a value via subscripting") {
        context["name"] = nil

        try expect(context["name"]).to.beNil()
      }

      test.it("allows you to retrieve a value from a parent") {
        try context.push {
          try expect(context["name"] as? String) == "Kyle"
        }
      }

      test.it("allows you to override a parent's value") {
        try context.push {
          context["name"] = "Katie"
          try expect(context["name"] as? String) == "Katie"
        }
      }
    }
  }

  func testContextRestoration() {
    describe("Context Restoration") { test in
      var context = Context()
      test.before {
        context = Context(dictionary: ["name": "Kyle"])
      }

      test.it("allows you to pop to restore previous state") {
        context.push {
          context["name"] = "Katie"
        }

        try expect(context["name"] as? String) == "Kyle"
      }

      test.it("allows you to remove a parent's value in a level") {
        try context.push {
          context["name"] = nil
          try expect(context["name"]).to.beNil()
        }

        try expect(context["name"] as? String) == "Kyle"
      }

      test.it("allows you to push a dictionary and run a closure then restoring previous state") {
        var didRun = false

        try context.push(dictionary: ["name": "Katie"]) {
          didRun = true
          try expect(context["name"] as? String) == "Katie"
        }

        try expect(didRun).to.beTrue()
        try expect(context["name"] as? String) == "Kyle"
      }

      test.it("allows you to flatten the context contents") {
        try context.push(dictionary: ["test": "abc"]) {
          let flattened = context.flatten()

          try expect(flattened.count) == 2
          try expect(flattened["name"] as? String) == "Kyle"
          try expect(flattened["test"] as? String) == "abc"
        }
      }
    }
  }

  func testContextLazyEvaluation() {
    let ticker = Ticker()
    var context = Context()
    var wrapper = LazyValueWrapper("")

    describe("Lazy evaluation") { test in
      test.before {
        ticker.count = 0
        wrapper = LazyValueWrapper(ticker.tick())
        context = Context(dictionary: ["name": wrapper])
      }

      test.it("Evaluates lazy data") {
        let template = Template(templateString: "{{ name }}")
        let result = try template.render(context)
        try expect(result) == "Kyle"
        try expect(ticker.count) == 1
      }

      test.it("Evaluates lazy only once") {
        let template = Template(templateString: "{{ name }}{{ name }}")
        let result = try template.render(context)
        try expect(result) == "KyleKyle"
        try expect(ticker.count) == 1
      }

      test.it("Does not evaluate lazy data when not used") {
        let template = Template(templateString: "{{ 'Katie' }}")
        let result = try template.render(context)
        try expect(result) == "Katie"
        try expect(ticker.count) == 0
      }
    }
  }

  func testContextLazyAccessTypes() {
    it("Supports evaluation via context reference") {
      let context = Context(dictionary: ["name": "Kyle"])
      context["alias"] = LazyValueWrapper { $0["name"] ?? "" }
      let template = Template(templateString: "{{ alias }}")

      try context.push(dictionary: ["name": "Katie"]) {
        let result = try template.render(context)
        try expect(result) == "Katie"
      }
    }

    it("Supports evaluation via context copy") {
      let context = Context(dictionary: ["name": "Kyle"])
      context["alias"] = LazyValueWrapper(copying: context) { $0["name"] ?? "" }
      let template = Template(templateString: "{{ alias }}")

      try context.push(dictionary: ["name": "Katie"]) {
        let result = try template.render(context)
        try expect(result) == "Kyle"
      }
    }
  }
}

// MARK: - Helpers

private final class Ticker {
  var count: Int = 0
  func tick() -> String {
    count += 1
    return "Kyle"
  }
}
