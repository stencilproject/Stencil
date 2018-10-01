import Foundation

#if swift(>=4.1)
#else
  public extension Sequence {
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
      return try flatMap(transform)
    }
  }
#endif

#if swift(>=4.1)
#else
  public extension Collection {
    func index(_ i: Self.Index, offsetBy n: Int) -> Self.Index {
        let indexDistance = Self.IndexDistance(n)
        return index(i, offsetBy: indexDistance)
    }
  }
#endif

#if swift(>=4.1)
#else
public extension TemplateSyntaxError {
  public static func ==(lhs: TemplateSyntaxError, rhs: TemplateSyntaxError) -> Bool {
    return lhs.reason == rhs.reason &&
      lhs.description == rhs.description &&
      lhs.token == rhs.token &&
      lhs.stackTrace == rhs.stackTrace &&
      lhs.templateName == rhs.templateName
  }
}
#endif

#if swift(>=4.1)
#else
public extension Variable {
  public static func ==(lhs: Variable, rhs: Variable) -> Bool {
    return lhs.variable == rhs.variable
  }
}
#endif
