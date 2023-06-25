//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Foundation

/// Type used for loading a template
public protocol Loader {
  /// Load a template with the given name
  func loadTemplate(name: String, environment: Environment) throws -> Template
  /// Load a template with the given list of names
  func loadTemplate(names: [String], environment: Environment) throws -> Template
}

extension Loader {
  /// Default implementation, tries to load the first template that exists from the list of given names
  public func loadTemplate(names: [String], environment: Environment) throws -> Template {
    for name in names {
      do {
        return try loadTemplate(name: name, environment: environment)
      } catch is TemplateDoesNotExist {
        continue
      } catch {
        throw error
      }
    }

    throw TemplateDoesNotExist(templateNames: names, loader: self)
  }
}

// A class for loading a template from disk
public class FileSystemLoader: Loader, CustomStringConvertible {
  public let paths: [String]

  public init(paths: [URL]) {
    self.paths = paths.map {
      $0.withUnsafeFileSystemRepresentation { String(cString: $0!) }
    }
  }

  public init(bundle: [Bundle]) {
    self.paths = bundle.map {
      URL(fileURLWithPath: $0.bundlePath).withUnsafeFileSystemRepresentation { String(cString: $0!) }
    }
  }

  public var description: String {
    "FileSystemLoader(\(paths))"
  }

  public func loadTemplate(name: String, environment: Environment) throws -> Template {
    return try loadTemplate(names: [name], environment: environment)
  }

  public func loadTemplate(names: [String], environment: Environment) throws -> Template {
    for path in paths {
      for templateName in names {
        let templatePath = URL(fileURLWithPath: templateName, relativeTo: URL(fileURLWithPath: path))
        if !templatePath.withUnsafeFileSystemRepresentation({ String(cString: $0!) }).hasPrefix(path) {
          throw SuspiciousFileOperation(basePath: path, path: templateName)
        }

        if FileManager.default.fileExists(atPath: templatePath.path) {
          let content = try String(contentsOf: templatePath)
          return environment.templateClass.init(templateString: content, environment: environment, name: templateName)
        }
      }
    }

    throw TemplateDoesNotExist(templateNames: names, loader: self)
  }
}

public class DictionaryLoader: Loader {
  public let templates: [String: String]

  public init(templates: [String: String]) {
    self.templates = templates
  }

  public func loadTemplate(name: String, environment: Environment) throws -> Template {
    if let content = templates[name] {
      return environment.templateClass.init(templateString: content, environment: environment, name: name)
    }

    throw TemplateDoesNotExist(templateNames: [name], loader: self)
  }

  public func loadTemplate(names: [String], environment: Environment) throws -> Template {
    for name in names {
      if let content = templates[name] {
        return environment.templateClass.init(templateString: content, environment: environment, name: name)
      }
    }

    throw TemplateDoesNotExist(templateNames: names, loader: self)
  }
}

class SuspiciousFileOperation: Error {
  let basePath: String
  let path: String

  init(basePath: String, path: String) {
    self.basePath = basePath
    self.path = path
  }

  var description: String {
    "Path `\(path)` is located outside of base path `\(basePath)`"
  }
}
