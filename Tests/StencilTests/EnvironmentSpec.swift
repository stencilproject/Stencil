//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import PathKit
import Spectre
@testable import Stencil
import XCTest

final class EnvironmentTests: XCTestCase {
  private var environment = Environment(loader: ExampleLoader())
  private var template: Template = ""

  override func setUp() {
    super.setUp()

    let errorExtension = Extension()
    errorExtension.registerFilter("throw") { (_: Any?) in
      throw TemplateSyntaxError("filter error")
    }
    errorExtension.registerSimpleTag("simpletag") { _ in
      throw TemplateSyntaxError("simpletag error")
    }
    errorExtension.registerTag("customtag") { _, token in
      ErrorNode(token: token)
    }

    environment = Environment(loader: ExampleLoader())
    environment.extensions += [errorExtension]
    template = ""
  }

  override func tearDown() {
    super.tearDown()
  }

  func testLoading() {
    it("can load a template from a name") {
      let template = try self.environment.loadTemplate(name: "example.html")
      try expect(template.name) == "example.html"
    }

    it("can load a template from a names") {
      let template = try self.environment.loadTemplate(names: ["first.html", "example.html"])
      try expect(template.name) == "example.html"
    }
  }

  func testRendering() {
    it("can render a template from a string") {
      let result = try self.environment.renderTemplate(string: "Hello World")
      try expect(result) == "Hello World"
    }

    it("can render a template from a file") {
      let result = try self.environment.renderTemplate(name: "example.html")
      try expect(result) == "Hello World!"
    }

    it("allows you to provide a custom template class") {
      let environment = Environment(loader: ExampleLoader(), templateClass: CustomTemplate.self)
      let result = try environment.renderTemplate(string: "Hello World")

      try expect(result) == "here"
    }
  }

  func testSyntaxError() {
    it("reports syntax error on invalid for tag syntax") {
      self.template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
      try self.expectError(
        reason: "'for' statements should use the syntax: `for <x> in <y> [where <condition>]`.",
        token: "for name in"
      )
    }

    it("reports syntax error on missing endfor") {
      self.template = "{% for name in names %}{{ name }}"
      try self.expectError(reason: "`endfor` was not found.", token: "for name in names")
    }

    it("reports syntax error on unknown tag") {
      self.template = "{% for name in names %}{{ name }}{% end %}"
      try self.expectError(reason: "Unknown template tag 'end'", token: "end")
    }
  }

  func testUnknownFilter() {
    it("reports syntax error in for tag") {
      self.template = "{% for name in names|unknown %}{{ name }}{% endfor %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "names|unknown"
      )
    }

    it("reports syntax error in for-where tag") {
      self.template = "{% for name in names where name|unknown %}{{ name }}{% endfor %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "name|unknown"
      )
    }

    it("reports syntax error in if tag") {
      self.template = "{% if name|unknown %}{{ name }}{% endif %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "name|unknown"
      )
    }

    it("reports syntax error in elif tag") {
      self.template = "{% if name %}{{ name }}{% elif name|unknown %}{% endif %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "name|unknown"
      )
    }

    it("reports syntax error in ifnot tag") {
      self.template = "{% ifnot name|unknown %}{{ name }}{% endif %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "name|unknown"
      )
    }

    it("reports syntax error in filter tag") {
      self.template = "{% filter unknown %}Text{% endfilter %}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "filter unknown"
      )
    }

    it("reports syntax error in variable tag") {
      self.template = "{{ name|unknown }}"
      try self.expectError(
        reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
        token: "name|unknown"
      )
    }

    it("reports error in variable tag") {
      self.template = "{{ }}"
      try self.expectError(reason: "Missing variable name", token: " ")
    }
  }

  func testRenderingError() {
    it("reports rendering error in variable filter") {
      self.template = Template(templateString: "{{ name|throw }}", environment: self.environment)
      try self.expectError(reason: "filter error", token: "name|throw")
    }

    it("reports rendering error in filter tag") {
      self.template = Template(templateString: "{% filter throw %}Test{% endfilter %}", environment: self.environment)
      try self.expectError(reason: "filter error", token: "filter throw")
    }

    it("reports rendering error in simple tag") {
      self.template = Template(templateString: "{% simpletag %}", environment: self.environment)
      try self.expectError(reason: "simpletag error", token: "simpletag")
    }

    it("reports passing argument to simple filter") {
      self.template = "{{ name|uppercase:5 }}"
      try self.expectError(reason: "Can't invoke filter with an argument", token: "name|uppercase:5")
    }

    it("reports rendering error in custom tag") {
      self.template = Template(templateString: "{% customtag %}", environment: self.environment)
      try self.expectError(reason: "Custom Error", token: "customtag")
    }

    it("reports rendering error in for body") {
      self.template = Template(templateString: """
        {% for name in names %}{% customtag %}{% endfor %}
        """, environment: self.environment)
      try self.expectError(reason: "Custom Error", token: "customtag")
    }

    it("reports rendering error in block") {
      self.template = Template(
        templateString: "{% block some %}{% customtag %}{% endblock %}",
        environment: self.environment
      )
      try self.expectError(reason: "Custom Error", token: "customtag")
    }
  }

  private func expectError(
    reason: String,
    token: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) throws {
    let expectedError = expectedSyntaxError(token: token, template: template, description: reason)

    let error = try expect(
      self.environment.render(template: self.template, context: ["names": ["Bob", "Alice"], "name": "Bob"]),
      file: file,
      line: line,
      function: function
    ).toThrow() as TemplateSyntaxError
    let reporter = SimpleErrorReporter()
    try expect(
      reporter.renderError(error),
      file: file,
      line: line,
      function: function
    ) == reporter.renderError(expectedError)
  }
}

// MARK: - Helpers

private class CustomTemplate: Template {
  // swiftlint:disable discouraged_optional_collection
  override func render(_ dictionary: [String: Any]? = nil) throws -> String {
    "here"
  }
}
