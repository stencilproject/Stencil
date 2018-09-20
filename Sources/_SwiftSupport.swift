import Foundation

#if !swift(>=4.1)
  public extension Sequence {
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
      return try flatMap(transform)
    }
  }
#endif

#if !swift(>=4.1)
  public extension Collection {
    func index(_ index: Self.Index, offsetBy offset: Int) -> Self.Index {
        let indexDistance = Self.IndexDistance(offset)
        return self.index(index, offsetBy: indexDistance)
    }
  }
#endif

#if !swift(>=4.1)
public extension TemplateSyntaxError {
  public static func == (lhs: TemplateSyntaxError, rhs: TemplateSyntaxError) -> Bool {
    return lhs.reason == rhs.reason &&
      lhs.description == rhs.description &&
      lhs.token == rhs.token &&
      lhs.stackTrace == rhs.stackTrace &&
      lhs.templateName == rhs.templateName
  }
}
#endif

#if !swift(>=4.1)
public extension Variable {
  public static func == (lhs: Variable, rhs: Variable) -> Bool {
    return lhs.variable == rhs.variable
  }
}
#endif
