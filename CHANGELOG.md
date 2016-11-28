# Stencil Changelog

## Master

### Breaking

- `TemplateLoader` has been renamed to `FileSystemLoader`. The
  `loadTemplate(s)` methods are now throwing and now take labels for the `name`
  and `names` arguments.

- Many internal classes are no longer private. Some APIs were previously
  accessible due to earlier versions of Swift requiring the types to be public
  to be able to test. Now we have access to `@testable` these can correctly be
  private.

### Enhancements

- Variable lookup now supports introspection of Swift types. You can now lookup
  values of Swift structures and classes inside a Context.

- If tags can now use prefix and infix operators such as `not`, `and`, `or`,
  `==`, `!=`, `>`, `>=`, `<` and `<=`.

    ```html+django
    {% if one or two and not three %}
    ```

- You may now register custom template filters which make use of arguments.
- There is now a `default` filter.

    ```html+django
    Hello {{ name|default:"World" }}
    ```

- There is now a `join` filter.

    ```html+django
    {{ value|join:", " }}
    ```

### Bug Fixes

- Variables (`{{ variable.5 }}`) that reference an array index at an unknown
  index will now resolve to `nil` instead of causing a crash.
  [#72](https://github.com/kylef/Stencil/issues/72)

- Templates can now extend templates that extend other templates.
  [#60](https://github.com/kylef/Stencil/issues/60)

- If comparisons will now treat 0 and below numbers as negative.


## 0.6.0

### Enhancements

- Adds support for Swift 3.0.
