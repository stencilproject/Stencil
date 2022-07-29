//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
import Stencil
import XCTest

final class TrimBehaviourTests: XCTestCase {
  func testSmartTrimCanRemoveNewlines() throws {
    let templateString = """
      {% for item in items %}
        - {{item}}
      {% endfor %}
      text
      """

    let context = ["items": ["item 1", "item 2"]]
    let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
    let result = try template.render(context)

    // swiftlint:disable indentation_width
    try expect(result) == """
        - item 1
        - item 2
      text
      """
    // swiftlint:enable indentation_width
  }

  func testSmartTrimOnlyRemoveSingleNewlines() throws {
    let templateString = """
      {% for item in items %}

        - {{item}}
      {% endfor %}
      text
      """

    let context = ["items": ["item 1", "item 2"]]
    let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
    let result = try template.render(context)

    // swiftlint:disable indentation_width
    try expect(result) == """

        - item 1

        - item 2
      text
      """
    // swiftlint:enable indentation_width
  }

  func testSmartTrimCanRemoveNewlinesWhileKeepingWhitespace() throws {
    // swiftlint:disable indentation_width
    let templateString = """
          Items:
          {% for item in items %}
              - {{item}}
          {% endfor %}
      """
    // swiftlint:enable indentation_width

    let context = ["items": ["item 1", "item 2"]]
    let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
    let result = try template.render(context)

    // swiftlint:disable indentation_width
    try expect(result) == """
          Items:
              - item 1
              - item 2

      """
    // swiftlint:enable indentation_width
  }

  func testTrimSymbols() {
    it("Respects whitespace control symbols in for tags") {
      // swiftlint:disable indentation_width
      let template: Template = """
        {% for num in numbers -%}
            {{num}}
        {%- endfor %}
        """
      // swiftlint:enable indentation_width
      let result = try template.render([ "numbers": Array(1...9) ])
      try expect(result) == "123456789"
    }
    it("Respects whitespace control symbols in if tags") {
      let template: Template = """
        {% if value -%}
          {{text}}
        {%- endif %}
        """
      let result = try template.render([ "text": "hello", "value": true ])
      try expect(result) == "hello"
    }
  }

  func testTrimSymbolsOverridingEnvironment() {
    let environment = Environment(trimBehaviour: .all)

    it("respects whitespace control symbols in if tags") {
      // swiftlint:disable indentation_width
      let templateString = """
          {% if value +%}
          {{text}}
        {%+ endif %}

        """
      // swiftlint:enable indentation_width
      let template = Template(templateString: templateString, environment: environment)
      let result = try template.render([ "text": "hello", "value": true ])
      try expect(result) == "\n  hello\n"
    }

    it("can customize blocks on same line as text") {
      // swiftlint:disable indentation_width
      let templateString = """
            Items:{% for item in items +%}
                - {{item}}
            {%- endfor %}
        """
      // swiftlint:enable indentation_width

      let context = ["items": ["item 1", "item 2"]]
      let template = Template(templateString: templateString, environment: environment)
      let result = try template.render(context)

      // swiftlint:disable indentation_width
      try expect(result) == """
            Items:
                - item 1
                - item 2
        """
      // swiftlint:enable indentation_width
    }
  }
}
