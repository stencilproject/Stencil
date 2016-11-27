# Stencil Changelog

## Master

### Breaking

- Many internal classes are no longer private. Some APIs were previously
  accessible due to earlier versions of Swift requiring the types to be public
  to be able to test. Now we have access to `@testable` these can correctly be
  private.

### Enhancements

- You may now register custom template filters which make use of arguments.

### Bug Fixes

- Variables (`{{ variable.5 }}`) that reference an array index at an unknown
  index will now resolve to `nil` instead of causing a crash.
  [#72](https://github.com/kylef/Stencil/issues/72)

- Templates can now extend templates that extend other templates.
  [#60](https://github.com/kylef/Stencil/issues/60)


## 0.6.0

### Enhancements

- Adds support for Swift 3.0.
