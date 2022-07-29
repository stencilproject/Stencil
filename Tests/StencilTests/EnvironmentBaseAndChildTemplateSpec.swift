//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import PathKit
import Spectre
@testable import Stencil
import XCTest

final class EnvironmentBaseAndChildTemplateTests: XCTestCase {
  private var environment = Environment(loader: ExampleLoader())
  private var childTemplate: Template = ""
  private var baseTemplate: Template = ""

  override func setUp() {
    super.setUp()

    let path = Path(#file as String) + ".." + "fixtures"
    let loader = FileSystemLoader(paths: [path])
    environment = Environment(loader: loader)
    childTemplate = ""
    baseTemplate = ""
  }

  override func tearDown() {
    super.tearDown()
  }

  func testSyntaxErrorInBaseTemplate() throws {
    childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
    baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

    try expectError(
      reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
      childToken: "extends \"invalid-base.html\"",
      baseToken: "target|unknown"
    )
  }

  func testRuntimeErrorInBaseTemplate() throws {
    let filterExtension = Extension()
    filterExtension.registerFilter("unknown") {  (_: Any?) in
      throw TemplateSyntaxError("filter error")
    }
    environment.extensions += [filterExtension]

    childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
    baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

    try expectError(
      reason: "filter error",
      childToken: "extends \"invalid-base.html\"",
      baseToken: "target|unknown"
    )
  }

  func testSyntaxErrorInChildTemplate() throws {
    childTemplate = Template(
      templateString: """
      {% extends "base.html" %}
      {% block body %}Child {{ target|unknown }}{% endblock %}
      """,
      environment: environment,
      name: nil
    )

    try expectError(
      reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
      childToken: "target|unknown",
      baseToken: nil
    )
  }

  func testRuntimeErrorInChildTemplate() throws {
    let filterExtension = Extension()
    filterExtension.registerFilter("unknown") {  (_: Any?) in
      throw TemplateSyntaxError("filter error")
    }
    environment.extensions += [filterExtension]

    childTemplate = Template(
      templateString: """
      {% extends "base.html" %}
      {% block body %}Child {{ target|unknown }}{% endblock %}
      """,
      environment: environment,
      name: nil
    )

    try expectError(
      reason: "filter error",
      childToken: "target|unknown",
      baseToken: nil
    )
  }

  private func expectError(
    reason: String,
    childToken: String,
    baseToken: String?,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) throws {
    var expectedError = expectedSyntaxError(token: childToken, template: childTemplate, description: reason)
    if let baseToken = baseToken {
      expectedError.stackTrace = [
        expectedSyntaxError(
          token: baseToken,
          template: baseTemplate,
          description: reason
        ).token
      ].compactMap { $0 }
    }
    let error = try expect(
      self.environment.render(template: self.childTemplate, context: ["target": "World"]),
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
