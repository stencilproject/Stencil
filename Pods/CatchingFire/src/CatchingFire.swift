//
//  CatchingFire.swift
//  CatchingFire
//
//  Created by Marius Rackwitz on 7.7.15.
//  Copyright © 2015 Marius Rackwitz. All rights reserved.
//

import XCTest


/// This allows you to write safe tests for the happy path of failable functions.
/// It helps you to avoid the `try!` operator in tests.
///
/// If you want to test a function, which may fail in general, you may think of using `try`.
/// But this would mean that you have to declare your test method as throwing, which causes that
/// XCTest doesn't execute the test anymore.
///
/// So in consequence, you would usually need to write:
///
///     XCTAssertEqual(try! fib(x), 21)
///
/// If the expression fails, your whole test suite doesn't execute further and aborts immediately,
/// which is very undesirable, especially on CI, but also for your workflow when you use TDD.
///
/// Instead you can write now:
///
///     AssertNoThrow {
///         XCTAssertEqual(try fib(x), 21)
///     }
///
/// Or alternatively:
///
///     AssertNoThrow(try fib(x)).map { (y: Int) in
///         XCTAssertEqual(y, 21)
///     }
///
/// If the expression fails, your test fails.
///
public func AssertNoThrow<R>(@autoclosure closure: () throws -> R) -> R? {
    var result: R?
    AssertNoThrow() {
        result = try closure()
    }
    return result
}

public func AssertNoThrow(@noescape closure: () throws -> ()) {
    do {
        try closure()
    } catch let error {
        XCTFail("Caught unexpected error <\(error)>.")
    }
}


/// This allows to easily write exhaustive tests for the exception paths of failable functions.
/// It helps you to avoid writing the same boilerplate code over and over again for tests.
///
/// If you want to test a function, that it fails for given arguments, you would usually need
/// to write:
///
///     do {
///         try fib(-1)
///         XCTFail("Expected to fail, but did not failed!")
///     } catch Error.ArgumentMayNotBeNegative {
///         // succeed silently
///     } catch error {
///         XCTFail("Failed with a different error than expected!")
///     }
///
/// Instead you can write now:
///
///     AssertThrows(Error.ArgumentMayNotBeNegative) {
///         try fib(-1)
///     }
///
/// If the expression or closure doesn't throw the expected error, your test fails.
///
public func AssertThrows<R, E where E: ErrorType>(expectedError: E, @autoclosure _ closure: () throws -> R) -> () {
    AssertThrows(expectedError) { try closure() }
}

public func AssertThrows<E where E: ErrorType>(expectedError: E, @noescape _ closure: () throws -> ()) -> () {
    do {
        try closure()
        XCTFail("Expected to catch <\(expectedError)>, "
            + "but no error was thrown.")
    } catch expectedError {
        return // that's what we expected
    } catch {
        XCTFail("Caught error <\(error)>, "
            + "but not of the expected type and value "
            + "<\(expectedError)>.")
    }
}

public func AssertThrows<R, E where E: ErrorType, E: Equatable>(expectedError: E, @autoclosure _ closure: () throws -> R) -> () {
    AssertThrows(expectedError) { try closure() }
}

public func AssertThrows<E where E: ErrorType, E: Equatable>(expectedError: E, @noescape _ closure: () throws -> ()) -> () {
    do {
        try closure()
        XCTFail("Expected to catch <\(expectedError)>, "
            + "but no error was thrown.")
    } catch let error as E {
        XCTAssertEqual(error, expectedError,
            "Caught error <\(error)> is of the expected type <\(E.self)>, "
                + "but not the expected case <\(expectedError)>.")
    } catch {
        XCTFail("Caught error <\(error)>, "
            + "but not of the expected type and value "
            + "<\(expectedError)>.")
    }
}

/// Implement pattern matching for ErrorTypes
internal func ~=(lhs: ErrorType, rhs: ErrorType) -> Bool {
    return lhs._domain == rhs._domain
        && rhs._code   == rhs._code
}

/// Helper struct to catch errors thrown by others, which aren't publicly exposed.
///
/// Note:
///   Don't use this when a given ErrorType implementation exists.
///   If you want to use that to test errors thrown in your own framework, you should
///   consider to adopt an enumeration-based approach first in the framework code itself and expose
///   them instead as part of the public API. Even if you have some internal error cases, you can
////  put them in a separate enum and import your framework as `@testable` in your tests without
///   affecting the public API, if that matters.
///
public struct Error : ErrorType {
    public let domain: String
    public let code: Int
    
    public var _domain: String {
        return domain
    }
    public var _code: Int {
        return code
    }
}

/// Extend our Error type to conform `Equatable`.
extension Error : Equatable {}

/// Implement the `==` operator as required by protocol `Equatable`.
public func ==(lhs: Error, rhs: Error) -> Bool {
    return lhs._domain == rhs._domain
        && lhs._code   == rhs._code
}

/// Implement pattern matching for Error & ErrorType
public func ~=(lhs: Error, rhs: ErrorType) -> Bool {
    return lhs._domain == rhs._domain
        && rhs._code   == rhs._code
}
