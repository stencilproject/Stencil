//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class FilterTests: XCTestCase {
  func testRegistration() {
    let context: [String: Any] = ["name": "Kyle"]

    it("allows you to register a custom filter") {
      let template = Template(templateString: "{{ name|repeat }}")

      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { (value: Any?) in
        if let value = value as? String {
          return "\(value) \(value)"
        }

        return nil
      }

      let result = try template.render(Context(
        dictionary: context,
        environment: Environment(extensions: [repeatExtension])
      ))
      try expect(result) == "Kyle Kyle"
    }

    it("allows you to register boolean filters") {
      let repeatExtension = Extension()
      repeatExtension.registerFilter(name: "isPositive", negativeFilterName: "isNotPositive") { (value: Any?) in
        if let value = value as? Int {
          return value > 0
        }
        return nil
      }

      let result = try Template(templateString: "{{ value|isPositive }}")
        .render(Context(dictionary: ["value": 1], environment: Environment(extensions: [repeatExtension])))
      try expect(result) == "true"

      let negativeResult = try Template(templateString: "{{ value|isNotPositive }}")
        .render(Context(dictionary: ["value": -1], environment: Environment(extensions: [repeatExtension])))
      try expect(negativeResult) == "true"
    }

    it("allows you to register a custom which throws") {
      let template = Template(templateString: "{{ name|repeat }}")
      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { (_: Any?) in
        throw TemplateSyntaxError("No Repeat")
      }

      let context = Context(dictionary: context, environment: Environment(extensions: [repeatExtension]))
      try expect(try template.render(context))
        .toThrow(TemplateSyntaxError(reason: "No Repeat", token: template.tokens.first))
    }

    it("throws when you pass arguments to simple filter") {
      let template = Template(templateString: "{{ name|uppercase:5 }}")
      try expect(try template.render(Context(dictionary: ["name": "kyle"]))).toThrow()
    }
  }

  func testRegistrationOverrideDefault() throws {
    let template = Template(templateString: "{{ name|join }}")
    let context: [String: Any] = ["name": "Kyle"]

    let repeatExtension = Extension()
    repeatExtension.registerFilter("join") { (_: Any?) in
      "joined"
    }

    let result = try template.render(Context(
      dictionary: context,
      environment: Environment(extensions: [repeatExtension])
    ))
    try expect(result) == "joined"
  }

  func testRegistrationWithArguments() {
    let context: [String: Any] = ["name": "Kyle"]

    it("allows you to register a custom filter which accepts single argument") {
      let template = Template(templateString: """
        {{ name|repeat:'value1, "value2"' }}
        """)

      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { value, arguments in
        guard let value = value,
          let argument = arguments.first else { return nil }

        return "\(value) \(value) with args \(argument ?? "")"
      }

      let result = try template.render(Context(
        dictionary: context,
        environment: Environment(extensions: [repeatExtension])
      ))
      try expect(result) == """
        Kyle Kyle with args value1, "value2"
        """
    }

    it("allows you to register a custom filter which accepts several arguments") {
      let template = Template(templateString: """
        {{ name|repeat:'value"1"',"value'2'",'(key, value)' }}
        """)

      let repeatExtension = Extension()
      repeatExtension.registerFilter("repeat") { value, arguments in
        guard let value = value else { return nil }
        let args = arguments.compactMap { $0 }
        return "\(value) \(value) with args 0: \(args[0]), 1: \(args[1]), 2: \(args[2])"
      }

      let result = try template.render(Context(
        dictionary: context,
        environment: Environment(extensions: [repeatExtension])
      ))
      try expect(result) == """
        Kyle Kyle with args 0: value"1", 1: value'2', 2: (key, value)
        """
    }

    it("allows whitespace in expression") {
      let template = Template(templateString: """
        {{ value | join : ", " }}
        """)
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "One, Two"
    }
  }

  func testStringFilters() {
    it("transforms a string to be capitalized") {
      let template = Template(templateString: "{{ name|capitalize }}")
      let result = try template.render(Context(dictionary: ["name": "kyle"]))
      try expect(result) == "Kyle"
    }

    it("transforms a string to be uppercase") {
      let template = Template(templateString: "{{ name|uppercase }}")
      let result = try template.render(Context(dictionary: ["name": "kyle"]))
      try expect(result) == "KYLE"
    }

    it("transforms a string to be lowercase") {
      let template = Template(templateString: "{{ name|lowercase }}")
      let result = try template.render(Context(dictionary: ["name": "Kyle"]))
      try expect(result) == "kyle"
    }
  }

  func testStringFiltersWithArrays() {
    it("transforms a string to be capitalized") {
      let template = Template(templateString: "{{ names|capitalize }}")
      let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
      try expect(result) == """
        ["Kyle", "Kyle"]
        """
    }

    it("transforms a string to be uppercase") {
      let template = Template(templateString: "{{ names|uppercase }}")
      let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
      try expect(result) == """
        ["KYLE", "KYLE"]
        """
    }

    it("transforms a string to be lowercase") {
      let template = Template(templateString: "{{ names|lowercase }}")
      let result = try template.render(Context(dictionary: ["names": ["Kyle", "Kyle"]]))
      try expect(result) == """
        ["kyle", "kyle"]
        """
    }
  }

  func testDefaultFilter() {
    let template = Template(templateString: """
      Hello {{ name|default:"World" }}
      """)

    it("shows the variable value") {
      let result = try template.render(Context(dictionary: ["name": "Kyle"]))
      try expect(result) == "Hello Kyle"
    }

    it("shows the default value") {
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "Hello World"
    }

    it("supports multiple defaults") {
      let template = Template(templateString: """
        Hello {{ name|default:a,b,c,"World" }}
        """)
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "Hello World"
    }

    it("can use int as default") {
      let template = Template(templateString: "{{ value|default:1 }}")
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "1"
    }

    it("can use float as default") {
      let template = Template(templateString: "{{ value|default:1.5 }}")
      let result = try template.render(Context(dictionary: [:]))
      try expect(result) == "1.5"
    }

    it("checks for underlying nil value correctly") {
      let template = Template(templateString: """
        Hello {{ user.name|default:"anonymous" }}
        """)
      let nilName: String? = nil
      let user: [String: Any?] = ["name": nilName]
      let result = try template.render(Context(dictionary: ["user": user]))
      try expect(result) == "Hello anonymous"
    }
  }

  func testJoinFilter() {
    let template = Template(templateString: """
      {{ value|join:", " }}
      """)

    it("joins a collection of strings") {
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "One, Two"
    }

    it("joins a mixed-type collection") {
      let result = try template.render(Context(dictionary: ["value": ["One", 2, true, 10.5, "Five"]]))
      try expect(result) == "One, 2, true, 10.5, Five"
    }

    it("can join by non string") {
      let template = Template(templateString: """
        {{ value|join:separator }}
        """)
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"], "separator": true]))
      try expect(result) == "OnetrueTwo"
    }

    it("can join without arguments") {
      let template = Template(templateString: """
        {{ value|join }}
        """)
      let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
      try expect(result) == "OneTwo"
    }
  }

  func testSplitFilter() {
    let template = Template(templateString: """
      {{ value|split:", " }}
      """)

    it("split a string into array") {
      let result = try template.render(Context(dictionary: ["value": "One, Two"]))
      try expect(result) == """
        ["One", "Two"]
        """
    }

    it("can split without arguments") {
      let template = Template(templateString: """
        {{ value|split }}
        """)
      let result = try template.render(Context(dictionary: ["value": "One, Two"]))
      try expect(result) == """
        ["One,", "Two"]
        """
    }
  }

  func testFilterSuggestion() {
    it("made for unknown filter") {
      let template = Template(templateString: "{{ value|unknownFilter }}")
      let filterExtension = Extension()
      filterExtension.registerFilter("knownFilter") { value, _ in value }

      try self.expectError(
        reason: "Unknown filter 'unknownFilter'. Found similar filters: 'knownFilter'.",
        token: "value|unknownFilter",
        template: template,
        extension: filterExtension
      )
    }

    it("made for multiple similar filters") {
      let template = Template(templateString: "{{ value|lowerFirst }}")
      let filterExtension = Extension()
      filterExtension.registerFilter("lowerFirstWord") { value, _ in value }
      filterExtension.registerFilter("lowerFirstLetter") { value, _ in value }

      try self.expectError(
        reason: "Unknown filter 'lowerFirst'. Found similar filters: 'lowerFirstWord', 'lowercase'.",
        token: "value|lowerFirst",
        template: template,
        extension: filterExtension
      )
    }

    it("not made when can't find similar filter") {
      let template = Template(templateString: "{{ value|unknownFilter }}")
      let filterExtension = Extension()
      filterExtension.registerFilter("lowerFirstWord") { value, _ in value }

      try self.expectError(
        reason: "Unknown filter 'unknownFilter'. Found similar filters: 'lowerFirstWord'.",
        token: "value|unknownFilter",
        template: template,
        extension: filterExtension
      )
    }
  }

  func testIndentContent() throws {
    let template = Template(templateString: """
      {{ value|indent:2 }}
      """)
    let result = try template.render(Context(dictionary: [
      "value": """
      One
      Two
      """
    ]))
    try expect(result) == """
      One
        Two
      """
  }

  func testIndentWithArbitraryCharacter() throws {
    let template = Template(templateString: """
      {{ value|indent:2,"\t" }}
      """)
    let result = try template.render(Context(dictionary: [
      "value": """
      One
      Two
      """
    ]))
    try expect(result) == """
      One
      \t\tTwo
      """
  }

  func testIndentFirstLine() throws {
    let template = Template(templateString: """
      {{ value|indent:2," ",true }}
      """)
    let result = try template.render(Context(dictionary: [
      "value": """
      One
      Two
      """
    ]))
    // swiftlint:disable indentation_width
    try expect(result) == """
        One
        Two
      """
    // swiftlint:enable indentation_width
  }

  func testIndentNotEmptyLines() throws {
    let template = Template(templateString: """
      {{ value|indent }}
      """)
    let result = try template.render(Context(dictionary: [
      "value": """
      One


      Two


      """
    ]))
    // swiftlint:disable indentation_width
    try expect(result) == """
      One


          Two


      """
    // swiftlint:enable indentation_width
  }

  func testDynamicFilters() throws {
    it("can apply dynamic filter") {
      let template = Template(templateString: "{{ name|filter:somefilter }}")
      let result = try template.render(Context(dictionary: ["name": "Jhon", "somefilter": "uppercase"]))
      try expect(result) == "JHON"
    }

    it("can apply dynamic filter on array") {
      let template = Template(templateString: "{{ values|filter:joinfilter }}")
      let result = try template.render(Context(dictionary: ["values": [1, 2, 3], "joinfilter": "join:\", \""]))
      try expect(result) == "1, 2, 3"
    }

    it("throws on unknown dynamic filter") {
      let template = Template(templateString: "{{ values|filter:unknown }}")
      let context = Context(dictionary: ["values": [1, 2, 3], "unknown": "absurd"])
      try expect(try template.render(context)).toThrow()
    }
  }

  private func expectError(
    reason: String,
    token: String,
    template: Template,
    extension: Extension,
    file: String = #file,
    line: Int = #line,
    function: String = #function
  ) throws {
    guard let range = template.templateString.range(of: token) else {
      fatalError("Can't find '\(token)' in '\(template)'")
    }

    let environment = Environment(extensions: [`extension`])
    let expectedError: Error = {
      let lexer = Lexer(templateString: template.templateString)
      let location = lexer.rangeLocation(range)
      let sourceMap = SourceMap(filename: template.name, location: location)
      let token = Token.block(value: token, at: sourceMap)
      return TemplateSyntaxError(reason: reason, token: token, stackTrace: [])
    }()

    let error = try expect(
      environment.render(template: template, context: [:]),
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
