// PathKit - Effortless path operations

import Foundation

/// Represents a filesystem path.
public struct Path : Hashable, CustomStringConvertible, StringLiteralConvertible {
    public static let separator = "/"

    private var path:String

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType

    // Returns the current working directory of the process
    public static var current:Path {
        get {
            return Path(NSFileManager().currentDirectoryPath)
        }
        set {
            NSFileManager().changeCurrentDirectoryPath(newValue.description)
        }
    }

    // MARK: Init

    public init() {
        self.path = ""
    }

    /// Create a Path from a given String
    public init(_ path:String) {
        self.path = path
    }

    /// Create a Path by joining multiple path components together
    public init(components:[String]) {
        path = Path.separator.join(components)
    }

    public init(stringLiteral value: StringLiteralType) {
        path = value
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = value
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = value
    }

    // MARK: Printable

    public var description:String {
        return self.path
    }

    public var hashValue:Int {
        return path.hashValue
    }

    /** Method for testing whether a path is absolute.
    :return: true if the path begings with a slash
    */
    public func isAbsolute() -> Bool {
        return path.hasPrefix(Path.separator)
    }

    /** Method for testing whether a path is a directory.
    :return: true if the path exists on disk and is a directory
    */
    public func isDirectory() -> Bool {
        var directory = ObjCBool(false)
        return NSFileManager().fileExistsAtPath(path, isDirectory: &directory) && directory.boolValue
    }

    /// Returns true if a path is relative (not absolute)
    public func isRelative() -> Bool {
        return !isAbsolute()
    }

    /// Returns the absolute path in the actual filesystem
    public func absolute() -> Path {
        if isAbsolute() {
            return normalize()
        }

        return (Path.current + self).normalize()
    }

    /// Normalizes the path, this clenas up redundant ".." and "." and double slashes
    public func normalize() -> Path {
        return Path((self.path as NSString).stringByStandardizingPath)
    }

    /// Returns whether a file or directory exists at a specified path
    public func exists() -> Bool {
        return NSFileManager().fileExistsAtPath(self.path)
    }

    public func delete() throws -> () {
        try NSFileManager().removeItemAtPath(self.path)
    }

    public func move(destination:Path) throws -> () {
        try NSFileManager().moveItemAtPath(self.path, toPath: destination.path)
    }

    /** Changes the current working directory of the process to the path during the execution of the given block.
    :param: closure A closure to be executed while the current directory is configured to the path.
    :note: The original working directory is restored when the block exits.
    */
    public func chdir(closure:(() -> ())) {
        let previous = Path.current
        Path.current = self
        closure()
        Path.current = previous
    }

    // MARK: Contents

    public func read() -> NSData? {
        return NSFileManager.defaultManager().contentsAtPath(self.path)
    }

    public func read() -> String? {
        if let data:NSData = read() {
            return NSString(data:data, encoding: NSUTF8StringEncoding) as? String
        }

        return nil
    }

    public func write(data:NSData) -> Bool {
        return data.writeToFile(path, atomically: true)
    }

    public func write(string:String) -> Bool {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            return write(data)
        }

        return false
    }

    // MARK: Children

    public func children(directories:Bool = true) throws -> [Path] {
        let manager = NSFileManager()
        let contents = try manager.contentsOfDirectoryAtPath(path)
        let paths = contents.map {
            self + Path($0)
        }

        if directories {
            return paths
        }
        
        return paths.filter { !$0.isDirectory() }
    }

}


/** Determines if two paths are identical
:note: The comparison is string-based. Be aware that two different paths (foo.txt and ./foo.txt) can refer to the same file.
*/
public func ==(lhs: Path, rhs: Path) -> Bool {
    return lhs.path == rhs.path
}

/// Appends a Path fragment to another Path to produce a new Path
public func +(lhs: Path, rhs: Path) -> Path {
    switch (lhs.path.hasSuffix(Path.separator), rhs.path.hasPrefix(Path.separator)) {
        case (true, true):
            return Path("\(lhs.path)\(rhs.path.substringFromIndex(rhs.path.startIndex.successor()))")
        case (false, false):
            return Path("\(lhs.path)\(Path.separator)\(rhs.path)")
        default:
            return Path("\(lhs.path)\(rhs.path)")
    }
}

