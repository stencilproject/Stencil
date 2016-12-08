public protocol HTMLString {
  var html: String { get }
}


struct EscapedHTML: HTMLString, CustomStringConvertible {
  let value: String

  var html: String { return value }
  var description: String { return value }
}


func escaped(html: String) -> HTMLString {
  return EscapedHTML(value: html)
}


func escapeHTML(_ value: String) -> String {
  return value
    .replacingOccurrences(of: "&", with: "&amp;")
    .replacingOccurrences(of: "'", with: "&39;")
    .replacingOccurrences(of: "<", with: "&lt;")
    .replacingOccurrences(of: ">", with: "&gt;")
    .replacingOccurrences(of: "\"", with: "&quot;")
}
