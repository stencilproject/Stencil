# Stencil Changelog

## Master

### Enhancements

- You may now register custom template filters which make use of arguments.

### Bug Fixes

- Variables (`{{ variable.5 }}`) that reference an array index at an unknown
  index will now resolve to `nil` instead of causing a crash.
  [#72](https://github.com/kylef/Stencil/issues/72)


## 0.6.0

### Enhancements

- Adds support for Swift 3.0.
