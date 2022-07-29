//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import PathKit
import Spectre
@testable import Stencil
import XCTest

extension Expectation {
  @discardableResult
  func toThrow<T: Error>() throws -> T {
    var thrownError: Error?

    do {
      _ = try expression()
    } catch {
      thrownError = error
    }

    if let thrownError = thrownError {
      if let thrownError = thrownError as? T {
        return thrownError
      } else {
        throw failure("\(thrownError) is not \(T.self)")
      }
    } else {
      throw failure("expression did not throw an error")
    }
  }
}

extension XCTestCase {
  func expectedSyntaxError(token: String, template: Template, description: String) -> TemplateSyntaxError {
    guard let range = template.templateString.range(of: token) else {
      fatalError("Can't find '\(token)' in '\(template)'")
    }
    let lexer = Lexer(templateString: template.templateString)
    let location = lexer.rangeLocation(range)
    let sourceMap = SourceMap(filename: template.name, location: location)
    let token = Token.block(value: token, at: sourceMap)
    return TemplateSyntaxError(reason: description, token: token, stackTrace: [])
  }
}

// MARK: - Test Types

class ExampleLoader: Loader {
  func loadTemplate(name: String, environment: Environment) throws -> Template {
    if name == "example.html" {
      return Template(templateString: "Hello World!", environment: environment, name: name)
    }

    throw TemplateDoesNotExist(templateNames: [name], loader: self)
  }
}

class ErrorNode: NodeType {
  let token: Token?
  init(token: Token? = nil) {
    self.token = token
  }

  func render(_ context: Context) throws -> String {
    throw TemplateSyntaxError("Custom Error")
  }
}
