public struct SourceMap: CustomStringConvertible, Equatable {
  public let fileName: String?
  public let start: String.Index
  public let end: String.Index

  public var description: String {
    return "SourceMap(\(fileName ?? "") \(start) \(end))"
  }
}


public func == (lhs: SourceMap, rhs: SourceMap) -> Bool {
  return lhs.fileName == rhs.fileName && lhs.start == rhs.start && lhs.end == rhs.end
}
