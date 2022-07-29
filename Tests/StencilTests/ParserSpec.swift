//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class TokenParserTests: XCTestCase {
  func testTextToken() throws {
    let parser = TokenParser(tokens: [
      .text(value: "Hello World", at: .unknown)
    ], environment: Environment())

    let nodes = try parser.parse()
    let node = nodes.first as? TextNode

    try expect(nodes.count) == 1
    try expect(node?.text) == "Hello World"
  }

  func testVariableToken() throws {
    let parser = TokenParser(tokens: [
      .variable(value: "'name'", at: .unknown)
    ], environment: Environment())

    let nodes = try parser.parse()
    let node = nodes.first as? VariableNode
    try expect(nodes.count) == 1
    let result = try node?.render(Context())
    try expect(result) == "name"
  }

  func testCommentToken() throws {
    let parser = TokenParser(tokens: [
      .comment(value: "Secret stuff!", at: .unknown)
    ], environment: Environment())

    let nodes = try parser.parse()
    try expect(nodes.count) == 0
  }

  func testTagToken() throws {
    let simpleExtension = Extension()
    simpleExtension.registerSimpleTag("known") { _ in
      ""
    }

    let parser = TokenParser(tokens: [
      .block(value: "known", at: .unknown)
    ], environment: Environment(extensions: [simpleExtension]))

    let nodes = try parser.parse()
    try expect(nodes.count) == 1
  }

  func testErrorUnknownTag() throws {
    let tokens: [Token] = [.block(value: "unknown", at: .unknown)]
    let parser = TokenParser(tokens: tokens, environment: Environment())

    try expect(try parser.parse()).toThrow(TemplateSyntaxError(
      reason: "Unknown template tag 'unknown'",
      token: tokens.first
    ))
  }

  func testTransformWhitespaceBehaviourToTrimBehaviour() throws {
    let simpleExtension = Extension()
    simpleExtension.registerSimpleTag("known") { _ in "" }

    let parser = TokenParser(tokens: [
      .block(value: "known", at: .unknown, whitespace: WhitespaceBehaviour(leading: .unspecified, trailing: .trim)),
      .text(value: "      \nSome text     ", at: .unknown),
      .block(value: "known", at: .unknown, whitespace: WhitespaceBehaviour(leading: .keep, trailing: .trim))
    ], environment: Environment(extensions: [simpleExtension]))

    let nodes = try parser.parse()
    try expect(nodes.count) == 3
    let textNode = nodes[1] as? TextNode
    try expect(textNode?.text) == "      \nSome text     "
    try expect(textNode?.trimBehaviour) == TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .nothing)
  }
}
