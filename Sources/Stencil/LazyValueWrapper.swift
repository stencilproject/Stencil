//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

/// Used to lazily set context data. Useful for example if you have some data that requires heavy calculations, and may
/// not be used in every render possiblity.
public final class LazyValueWrapper {
  private let closure: (Context) throws -> Any
  private let context: Context?
  private var cachedValue: Any?

  /// Create a wrapper that'll use a **reference** to the current context.
  /// This means when the closure is evaluated, it'll use the **active** context at that moment.
  ///
  /// - Parameters:
  ///   - closure: The closure to lazily evaluate
  public init(closure: @escaping (Context) throws -> Any) {
    self.context = nil
    self.closure = closure
  }

  /// Create a wrapper that'll create a **copy** of the current context.
  /// This means when the closure is evaluated, it'll use the context **as it was** when this wrapper was created.
  ///
  /// - Parameters:
  ///   - context: The context to use during evaluation
  ///   - closure: The closure to lazily evaluate
  /// - Note: This will use more memory than the other `init` as it needs to keep a copy of the full context around.
  public init(copying context: Context, closure: @escaping (Context) throws -> Any) {
    self.context = Context(dictionaries: context.dictionaries, environment: context.environment)
    self.closure = closure
  }

  /// Shortcut for creating a lazy wrapper when you don't need access to the Stencil context.
  ///
  /// - Parameters:
  ///   - closure: The closure to lazily evaluate
  public init(_ closure: @autoclosure @escaping () throws -> Any) {
    self.context = nil
    self.closure = { _ in try closure() }
  }
}

extension LazyValueWrapper {
  func value(context: Context) throws -> Any {
    if let value = cachedValue {
      return value
    } else {
      let value = try closure(self.context ?? context)
      cachedValue = value
      return value
    }
  }
}

extension LazyValueWrapper: Resolvable {
  public func resolve(_ context: Context) throws -> Any? {
    let value = try self.value(context: context)
    return try (value as? Resolvable)?.resolve(context) ?? value
  }
}
