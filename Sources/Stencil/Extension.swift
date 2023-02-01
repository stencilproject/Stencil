//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

/// Container for registered tags and filters
open class Extension {
  typealias TagParser = (TokenParser, Token) throws -> NodeType

  var tags = [String: TagParser]()
  var filters = [String: Filter]()

  /// Simple initializer
  public init() {
  }

  /// Registers a new template tag
  public func registerTag(_ name: String, parser: @escaping (TokenParser, Token) throws -> NodeType) {
    tags[name] = parser
  }

  /// Registers a simple template tag with a name and a handler
  public func registerSimpleTag(_ name: String, handler: @escaping (Context) throws -> String) {
    registerTag(name) { _, token in
      SimpleNode(token: token, handler: handler)
    }
  }

  /// Registers boolean filter with it's negative counterpart
  public func registerFilter(name: String, negativeFilterName: String, filter: @escaping (Any?) throws -> Bool?) {
    // swiftlint:disable:previous discouraged_optional_boolean
    filters[name] = .simple(filter)
    filters[negativeFilterName] = .simple { value in
      guard let result = try filter(value) else { return nil }
      return !result
    }
  }

  /// Registers a template filter with the given name
  public func registerFilter(_ name: String, filter: @escaping (Any?) throws -> Any?) {
    filters[name] = .simple(filter)
  }

  /// Registers a template filter with the given name
  public func registerFilter(_ name: String, filter: @escaping (Any?, [Any?]) throws -> Any?) {
    filters[name] = .arguments { value, args, _ in try filter(value, args) }
  }

  /// Registers a template filter with the given name
  public func registerFilter(_ name: String, filter: @escaping (Any?, [Any?], Context) throws -> Any?) {
    filters[name] = .arguments(filter)
  }
}

class DefaultExtension: Extension {
  override init() {
    super.init()
    registerDefaultTags()
    registerDefaultFilters()
  }

  fileprivate func registerDefaultTags() {
    registerTag("for", parser: ForNode.parse)
    registerTag("break", parser: LoopTerminationNode.parse)
    registerTag("continue", parser: LoopTerminationNode.parse)
    registerTag("if", parser: IfNode.parse)
    registerTag("ifnot", parser: IfNode.parse_ifnot)
    #if !os(Linux)
      registerTag("now", parser: NowNode.parse)
    #endif
    registerTag("include", parser: IncludeNode.parse)
    registerTag("extends", parser: ExtendsNode.parse)
    registerTag("block", parser: BlockNode.parse)
    registerTag("filter", parser: FilterNode.parse)
  }

  fileprivate func registerDefaultFilters() {
    registerFilter("default", filter: defaultFilter)
    registerFilter("capitalize", filter: capitalise)
    registerFilter("uppercase", filter: uppercase)
    registerFilter("lowercase", filter: lowercase)
    registerFilter("join", filter: joinFilter)
    registerFilter("split", filter: splitFilter)
    registerFilter("indent", filter: indentFilter)
    registerFilter("filter", filter: filterFilter)
    registerFilter("unique", filter: unique)
  }
}

protocol FilterType {
  func invoke(value: Any?, arguments: [Any?], context: Context) throws -> Any?
}

enum Filter: FilterType {
  case simple(((Any?) throws -> Any?))
  case arguments(((Any?, [Any?], Context) throws -> Any?))

  func invoke(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
    switch self {
    case let .simple(filter):
      if !arguments.isEmpty {
        throw TemplateSyntaxError("Can't invoke filter with an argument")
      }
      return try filter(value)
    case let .arguments(filter):
      return try filter(value, arguments, context)
    }
  }
}
