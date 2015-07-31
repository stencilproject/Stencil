# CatchingFire

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/mrackwitz/CatchingFire/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/CatchingFire.svg?style=flat)](https://github.com/mrackwitz/CatchingFire)

CatchingFire is a Swift test framework, which helps making expectations against the error handling of your code. It provides for this purpose two higher-order functions, which take throwing functions and check whether the given closure throws or not. It integrates seamlessly with the expecters provided by `XCTest`.

## Usage

### AssertNotThrow

`AssertNotThrow` allows you to write safe tests for the happy path of failable functions.
It helps you to avoid the `try!` operator in tests.

If you want to test a function, which may fail in general, you may think of using `try`.
But this would mean that you have to declare your test method as throwing, which causes that
XCTest doesn't execute the test anymore.

So in consequence, you would usually need to write:

```swift
XCTAssertEqual(try! fib(x), 21)
```

If the expression fails, your whole test suite doesn't execute further and aborts immediately,
which is very undesirable, especially on CI, but also for your workflow when you use TDD.

Instead you can write now:

```swift
AssertNotThrow {
    XCTAssertEqual(try fib(x), 21)
}
```

Or alternatively:

```swift
AssertNotThrow(try fib(x)).map { (y: Int) in
    XCTAssertEqual(y, 21)
}
```

If the expression fails, your test fails.

### AssertThrow

`AssertThrow` allows to easily write exhaustive tests for the exception paths of failable functions.
It helps you to avoid writing the same boilerplate code over and over again for tests.

If you want to test a function, that it fails for given arguments, you would usually need
to write:

```swift
do {
    try fib(-1)
    XCTFail("Expected to fail, but did not failed!")
} catch Error.ArgumentMayNotBeNegative {
    // succeed silently
} catch error {
    XCTFail("Failed with a different error than expected!")
}
```

Instead you can write now:

```swift
AssertThrow(Error.ArgumentMayNotBeNegative) {
    try fib(-1)
}
```

If the expression or closure doesn't throw the expected error, your test fails.


## Installation

CatchingFire is available through [CocoaPods](http://cocoapods.org). To install
it, simply add it to your test target in your Podfile:

```ruby
use_frameworks!
target "AppTest" do
  pod 'CatchingFire'
end
```


## Author

Marius Rackwitz, git@mariusrackwitz.de  
Find me on Twitter as [@mrackwitz](https://twitter.com/mrackwitz).


## License

Version is available under the MIT license. See the LICENSE file for more info.
