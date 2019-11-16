/// Creates a checker that will stop parsing if it encounters a list of tags.
/// Useful for example for scanning until a given "end"-node.
public func until(_ tags: [String]) -> ((TokenParser, Token) -> Bool) {
  { _, token in
    if let name = token.components.first {
      for tag in tags where name == tag {
        return true
      }
    }

    return false
  }
}

/// A class for parsing an array of tokens and converts them into a collection of Node's
public class TokenParser {
  /// Parser for finding a kind of node
  public typealias TagParser = (TokenParser, Token) throws -> NodeType

  fileprivate var tokens: [Token]
  fileprivate let environment: Environment
  fileprivate var previousWhiteSpace: WhitespaceBehaviour.Behaviour?

  /// Simple initializer
  public init(tokens: [Token], environment: Environment) {
    self.tokens = tokens
    self.environment = environment
  }

  /// Parse the given tokens into nodes
  public func parse() throws -> [NodeType] {
    try parse(nil)
  }

  /// Parse nodes until a specific "something" is detected, determined by the provided closure.
  /// Combine this with the `until(:)` function above to scan nodes until a given token.
  public func parse(_ parseUntil: ((_ parser: TokenParser, _ token: Token) -> (Bool))?) throws -> [NodeType] {
    var nodes = [NodeType]()

    while !tokens.isEmpty {
      guard let token = nextToken() else { break }

      switch token.kind {
      case .text:
        nodes.append(TextNode(text: token.contents, trimBehaviour: trimBehaviour))
      case .variable:
        previousWhiteSpace = nil
        try nodes.append(VariableNode.parse(self, token: token))
      case .block:
        previousWhiteSpace = token.whitespace?.trailing
        if let parseUntil = parseUntil, parseUntil(self, token) {
          prependToken(token)
          return nodes
        }

        if let tag = token.components.first {
          do {
            let parser = try environment.findTag(name: tag)
            let node = try parser(self, token)
            nodes.append(node)
          } catch {
            throw error.withToken(token)
          }
        }
      case .comment:
        previousWhiteSpace = nil
        continue
      }
    }

    return nodes
  }

  /// Pop the next token (returning it)
  public func nextToken() -> Token? {
    if !tokens.isEmpty {
      return tokens.remove(at: 0)
    }

    return nil
  }

  func peekWhitespace() -> WhitespaceBehaviour.Behaviour? {
    tokens.first?.whitespace?.leading
  }

  /// Insert a token 
  public func prependToken(_ token: Token) {
    tokens.insert(token, at: 0)
  }

  /// Create filter expression from a string contained in provided token
  public func compileFilter(_ filterToken: String, containedIn token: Token) throws -> Resolvable {
    try environment.compileFilter(filterToken, containedIn: token)
  }

  /// Create boolean expression from components contained in provided token
  public func compileExpression(components: [String], token: Token) throws -> Expression {
    try environment.compileExpression(components: components, containedIn: token)
  }

  /// Create resolvable (i.e. range variable or filter expression) from a string contained in provided token
  public func compileResolvable(_ token: String, containedIn containingToken: Token) throws -> Resolvable {
    try environment.compileResolvable(token, containedIn: containingToken)
  }

  private var trimBehaviour: TrimBehaviour {
    var behaviour: TrimBehaviour = .nothing

    if let leading = previousWhiteSpace {
      if leading == .unspecified {
        behaviour.leading = environment.trimBehaviour.trailing
      } else {
        behaviour.leading = leading == .trim ? .whitespaceAndNewLines : .nothing
      }
    }
    if let trailing = peekWhitespace() {
      if trailing == .unspecified {
        behaviour.trailing = environment.trimBehaviour.leading
      } else {
        behaviour.trailing = trailing == .trim ? .whitespaceAndNewLines : .nothing
      }
    }

    return behaviour
  }
}

extension Environment {
  func findTag(name: String) throws -> Extension.TagParser {
    for ext in extensions {
      if let filter = ext.tags[name] {
        return filter
      }
    }

    throw TemplateSyntaxError("Unknown template tag '\(name)'")
  }

  func findFilter(_ name: String) throws -> FilterType {
    for ext in extensions {
      if let filter = ext.filters[name] {
        return filter
      }
    }

    let suggestedFilters = self.suggestedFilters(for: name)
    if suggestedFilters.isEmpty {
      throw TemplateSyntaxError("Unknown filter '\(name)'.")
    } else {
      throw TemplateSyntaxError(
        """
        Unknown filter '\(name)'. \
        Found similar filters: \(suggestedFilters.map { "'\($0)'" }.joined(separator: ", ")).
        """
      )
    }
  }

  private func suggestedFilters(for name: String) -> [String] {
    let allFilters = extensions.flatMap { $0.filters.keys }

    let filtersWithDistance = allFilters
      .map { (filterName: $0, distance: $0.levenshteinDistance(name)) }
      // do not suggest filters which names are shorter than the distance
      .filter { $0.filterName.count > $0.distance }
    guard let minDistance = filtersWithDistance.min(by: { $0.distance < $1.distance })?.distance else {
      return []
    }
    // suggest all filters with the same distance
    return filtersWithDistance.filter { $0.distance == minDistance }.map { $0.filterName }
  }

  /// Create filter expression from a string
  public func compileFilter(_ token: String) throws -> Resolvable {
    try FilterExpression(token: token, environment: self)
  }

  /// Create filter expression from a string contained in provided token
  public func compileFilter(_ filterToken: String, containedIn containingToken: Token) throws -> Resolvable {
    do {
      return try FilterExpression(token: filterToken, environment: self)
    } catch {
      guard var syntaxError = error as? TemplateSyntaxError, syntaxError.token == nil else {
        throw error
      }
      // find offset of filter in the containing token so that only filter is highligted, not the whole token
      if let filterTokenRange = containingToken.contents.range(of: filterToken) {
        var location = containingToken.sourceMap.location
        location.lineOffset += containingToken.contents.distance(
          from: containingToken.contents.startIndex,
          to: filterTokenRange.lowerBound
        )
        syntaxError.token = .variable(
          value: filterToken,
          at: SourceMap(filename: containingToken.sourceMap.filename, location: location)
        )
      } else {
        syntaxError.token = containingToken
      }
      throw syntaxError
    }
  }

  /// Create resolvable (i.e. range variable or filter expression) from a string
  public func compileResolvable(_ token: String) throws -> Resolvable {
    try RangeVariable(token, environment: self)
      ?? compileFilter(token)
  }

  /// Create resolvable (i.e. range variable or filter expression) from a string contained in provided token
  public func compileResolvable(_ token: String, containedIn containingToken: Token) throws -> Resolvable {
    try RangeVariable(token, environment: self, containedIn: containingToken)
      ?? compileFilter(token, containedIn: containingToken)
  }

  /// Create boolean expression from components contained in provided token
  public func compileExpression(components: [String], containedIn token: Token) throws -> Expression {
    try IfExpressionParser.parser(components: components, environment: self, token: token).parse()
  }
}

// https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
extension String {
  subscript(_ index: Int) -> Character {
    self[self.index(self.startIndex, offsetBy: index)]
  }

  func levenshteinDistance(_ target: String) -> Int {
    // create two work vectors of integer distances
    var last, current: [Int]

    // initialize v0 (the previous row of distances)
    // this row is A[0][i]: edit distance for an empty s
    // the distance is just the number of characters to delete from t
    last = [Int](0...target.count)
    current = [Int](repeating: 0, count: target.count + 1)

    for selfIndex in 0..<self.count {
      // calculate v1 (current row distances) from the previous row v0

      // first element of v1 is A[i+1][0]
      //   edit distance is delete (i+1) chars from s to match empty t
      current[0] = selfIndex + 1

      // use formula to fill in the rest of the row
      for targetIndex in 0..<target.count {
        current[targetIndex + 1] = Swift.min(
          last[targetIndex + 1] + 1,
          current[targetIndex] + 1,
          last[targetIndex] + (self[selfIndex] == target[targetIndex] ? 0 : 1)
        )
      }

      // copy v1 (current row) to v0 (previous row) for next iteration
      last = current
    }

    return current[target.count]
  }
}
