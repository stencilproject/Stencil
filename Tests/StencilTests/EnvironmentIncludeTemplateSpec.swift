//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import PathKit
import Spectre
@testable import Stencil
import XCTest

final class EnvironmentIncludeTemplateTests: XCTestCase {
  private var environment = Environment(loader: ExampleLoader())
  private var template: Template = ""
  private var includedTemplate: Template = ""

  override func setUp() {
    super.setUp()

    let path = Path(#file as String) + ".." + "fixtures"
    let loader = FileSystemLoader(paths: [path])
    environment = Environment(loader: loader)
    template = ""
    includedTemplate = ""
  }

  override func tearDown() {
    super.tearDown()
  }

  func testSyntaxError() throws {
    template = Template(templateString: """
      {% include "invalid-include.html" %}
      """, environment: environment)
    includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

    try expectError(
      reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
      token: #"include "invalid-include.html""#,
      includedToken: "target|unknown"
    )
  }

  func testRuntimeError() throws {
    let filterExtension = Extension()
    filterExtension.registerFilter("unknown") {  (_: Any?) in
      throw TemplateSyntaxError("filter error")
    }
    environment.extensions += [filterExtension]

    template = Template(templateString: """
      {% include "invalid-include.html" %}
      """, environment: environment)
    includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

    try expectError(
      reason: "filter error",
      token: "include \"invalid-include.html\"",
      includedToken: "target|unknown"
    )
  }

  private func expectError(
    reason: String,
    token: String,
    includedToken: String,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) throws {
    var expectedError = expectedSyntaxError(token: token, template: template, description: reason)
    expectedError.stackTrace = [
      expectedSyntaxError(
        token: includedToken,
        template: includedTemplate,
        description: reason
      ).token
    ].compactMap { $0 }

    let error = try expect(
      self.environment.render(template: self.template, context: ["target": "World"]),
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
