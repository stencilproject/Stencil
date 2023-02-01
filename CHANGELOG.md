# 0.15.2

### Enhancements

- Added support for unique filter using `unique`. This filter allows you to extract unique values from an array
  [David Bertet](https://github.com/DavidBertet)

## 0.15.1

### Bug Fixes

- Fix bug in `LazyValueWrapper`, causing it to never resolve.  
  [David Jennes](https://github.com/djbe)
  [#328](https://github.com/stencilproject/Stencil/pull/328)

## 0.15.0

### Breaking

- Drop support for Swift < 5. For Swift 4.2 support, you should use Stencil 0.14.2.  
  [David Jennes](https://github.com/djbe)
  [#323](https://github.com/stencilproject/Stencil/pull/323)

### Enhancements

- Added support for trimming whitespace around blocks with Jinja2 whitespace control symbols. eg `{%- if value +%}`.  
  [Miguel Bejar](https://github.com/bejar37)
  [Yonas Kolb](https://github.com/yonaskolb)
  [#92](https://github.com/stencilproject/Stencil/pull/92)
  [#287](https://github.com/stencilproject/Stencil/pull/287)
- Added support for adding default whitespace trimming behaviour to an environment.  
  [Yonas Kolb](https://github.com/yonaskolb)
  [#287](https://github.com/stencilproject/Stencil/pull/287)
- Blocks now can be used repeatedly in the template. When block is rendered for the first time its content will be cached and it can be rendered again later using `{{ block.block_name }}`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#158](https://github.com/stencilproject/Stencil/issues/158)
  [#182](https://github.com/stencilproject/Stencil/pull/182)
- Added `break` and `continue` tags to break or continue current loop.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#175](https://github.com/stencilproject/Stencil/pull/175)
- You can now access outer loop's scope by labeling it: `{% outer: for ... %}... {% for ... %} {{ outer.counter }} {% endfor %}{% endfor %}`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#175](https://github.com/stencilproject/Stencil/pull/175)
- Boolean expressions can now be rendered, i.e `{{ name == "John" }}` will render `true` or `false` depending on the evaluation result.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [David Jennes](https://github.com/djbe)
  [#164](https://github.com/stencilproject/Stencil/pull/164)
  [#325](https://github.com/stencilproject/Stencil/pull/325)
- Enable dynamic member lookup using a new `DynamicMemberLookup` marker protocol. Conform your own types to this protocol to support dynamic member from with contexts.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#219](https://github.com/stencilproject/Stencil/issues/219)
  [#246](https://github.com/stencilproject/Stencil/pull/246)
- Allow providing lazily evaluated context data, using the `LazyValueWrapper` structure.  
  [David Jennes](https://github.com/djbe)
  [#324](https://github.com/stencilproject/Stencil/pull/324)

### Bug Fixes

- Fixed using `{{ block.super }}` inside nodes other than `block`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#266](https://github.com/stencilproject/Stencil/issues/266)
  [#267](https://github.com/stencilproject/Stencil/pull/267)

### Internal Changes

- Updated internal maintenance scripts, and switched to GitHub actions.  
  [David Jennes](https://github.com/djbe)
  [#321](https://github.com/stencilproject/Stencil/pull/321)
- Made the `tokens` property on a `Template` public.  
  [Stefanomondino](https://github.com/stefanomondino)
  [#292](https://github.com/stencilproject/Stencil/pull/292)
- Made the `Template.render(_:)` method (that accepts a `Context`) public.  
  [David Jennes](https://github.com/djbe)
  [#322](https://github.com/stencilproject/Stencil/pull/322)

## 0.14.2

### Internal Changes

- Update Spectre (0.10) and PathKit to support Xcode 13.  
  [Astromonkee](https://github.com/astromonkee)
  [#314](https://github.com/stencilproject/Stencil/pull/314)

## 0.14.1

### Bug Fixes

- Fix for crashing range indexes when variable length is 1.  
  [Łukasz Kuczborski](https://github.com/lkuczborski)
  [#306](https://github.com/stencilproject/Stencil/pull/306)


## 0.14.0

### Breaking

- Drop support for Swift < 4.2. For Swift 4 support, you should use Stencil 0.13.1.  
  [David Jennes](https://github.com/djbe)
  [#294](https://github.com/stencilproject/Stencil/pull/294)

### Enhancements

- Added support for dynamic filter using `filter` filter. With that you can define a variable with a name of filter
, i.e. `myfilter = "uppercase"` and then use it to invoke this filter with `{{ string|filter:myfilter }}`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#203](https://github.com/stencilproject/Stencil/pull/203)

### Bug Fixes

- Fixed using parenthesis in boolean expressions, they now can be used without spaces around them.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#254](https://github.com/stencilproject/Stencil/pull/254)
- Throw syntax error on empty variable tags (`{{ }}`) instead `fatalError`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#263](https://github.com/stencilproject/Stencil/pull/263)

### Internal Changes

- `Token` type converted to struct to allow computing token components only once.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#256](https://github.com/stencilproject/Stencil/pull/256)
- Added SwiftLint to the project.  
  [David Jennes](https://github.com/djbe)
  [#249](https://github.com/stencilproject/Stencil/pull/249)
- Updated to Swift 5.  
  [Jungwon An](https://github.com/kawoou)
  [#268](https://github.com/stencilproject/Stencil/pull/268)


## 0.13.1

### Bug Fixes

- Fixed a bug in Stencil 0.13 where tags without spaces were incorrectly parsed.  
  [David Jennes](https://github.com/djbe)
  [#252](https://github.com/stencilproject/Stencil/pull/252)


## 0.13.0

### Breaking

- Now requires Swift 4.1 or newer.  
  [Yonas Kolb](https://github.com/yonaskolb)
  [#228](https://github.com/stencilproject/Stencil/pull/228)

### Enhancements

- You can now use parentheses in boolean expressions to change operator precedence.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#165](https://github.com/stencilproject/Stencil/pull/165)
- Added method to add boolean filters with their negative counterparts.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#160](https://github.com/stencilproject/Stencil/pull/160)
- Now you can conditionally render variables with `{{ variable if condition }}`, which is a shorthand for `{% if condition %}{{ variable }}{% endif %}`. You can also use `else` like `{{ variable1 if condition else variable2 }}`, which is a shorthand for `{% if condition %}{{ variable1 }}{% else %}{{ variable2 }}{% endif %}`  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#243](https://github.com/stencilproject/Stencil/pull/243)
- Now you can access string characters by index or get string length the same was as if it was an array, i.e. `{{ 'string'.first }}`, `{{ 'string'.last }}`, `{{ 'string'.1 }}`, `{{ 'string'.count }}`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#245](https://github.com/stencilproject/Stencil/pull/245)

### Bug Fixes

- Fixed the performance issues introduced in Stencil 0.12 with the error log improvements.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#230](https://github.com/stencilproject/Stencil/pull/230)
- Now accessing undefined keys in NSObject does not cause runtime crash and instead renders empty string.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#234](https://github.com/stencilproject/Stencil/pull/234)
- `for` tag: When iterating over a dictionary the keys will now always be sorted (in an ascending order) to ensure consistent output generation.  
  [David Jennes](https://github.com/djbe)
  [#240](https://github.com/stencilproject/Stencil/pull/240)

### Internal Changes

- Updated the codebase to use Swift 4 features.  
  [David Jennes](https://github.com/djbe)
  [#239](https://github.com/stencilproject/Stencil/pull/239)
- Update to Spectre 0.9.0.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#247](https://github.com/stencilproject/Stencil/pull/247)
- Optimise Scanner performance.  
  [Eric Thorpe](https://github.com/trametheka)
  [Sébastien Duperron](https://github.com/Liquidsoul)
  [David Jennes](https://github.com/djbe)
  [#226](https://github.com/stencilproject/Stencil/pull/226)


## 0.12.1

### Internal Changes

- Updated the PathKit dependency to 0.9.0 in CocoaPods, to be in line with SPM.  
  [David Jennes](https://github.com/djbe)
  [#227](https://github.com/stencilproject/Stencil/pull/227)


## 0.12.0

### Enhancements

- Added an optional second parameter to the `include` tag for passing a sub context to the included file.  
  [Yonas Kolb](https://github.com/yonaskolb)
  [#214](https://github.com/stencilproject/Stencil/pull/214)
- Variables now support the subscript notation. For example, if you have a variable `key = "name"`, and an
  object `item = ["name": "John"]`, then `{{ item[key] }}` will evaluate to "John".  
  [David Jennes](https://github.com/djbe)
  [#215](https://github.com/stencilproject/Stencil/pull/215)
- Adds support for using spaces in filter expression.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#178](https://github.com/stencilproject/Stencil/pull/178)
- Improvements in error reporting.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#167](https://github.com/stencilproject/Stencil/pull/167)

### Bug Fixes

- Fixed using quote as a filter parameter.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#210](https://github.com/stencilproject/Stencil/pull/210)


## 0.11.0 (2018-04-04)

### Enhancements

- Added support for resolving superclass properties for not-NSObject subclasses.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#152](https://github.com/stencilproject/Stencil/pull/152)
- The `{% for %}` tag can now iterate over tuples, structures and classes via
  their stored properties.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#173](https://github.com/stencilproject/Stencil/pull/173)
- Added `split` filter.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#187](https://github.com/stencilproject/Stencil/pull/187)
- Allow default string filters to be applied to arrays.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#190](https://github.com/stencilproject/Stencil/pull/190)
- Similar filters are suggested when unknown filter is used.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#186](https://github.com/stencilproject/Stencil/pull/186)
- Added `indent` filter.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#188](https://github.com/stencilproject/Stencil/pull/188)
- Allow using new lines inside tags.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#202](https://github.com/stencilproject/Stencil/pull/202)
- Added support for iterating arrays of tuples.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#177](https://github.com/stencilproject/Stencil/pull/177)
- Added support for ranges in if-in expression.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#193](https://github.com/stencilproject/Stencil/pull/193)
- Added property `forloop.length` to get number of items in the loop.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#171](https://github.com/stencilproject/Stencil/pull/171)
- Now you can construct ranges for loops using `a...b` syntax, i.e. `for i in 1...array.count`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#192](https://github.com/stencilproject/Stencil/pull/192)

### Bug Fixes

- Fixed rendering `{{ block.super }}` with several levels of inheritance.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#154](https://github.com/stencilproject/Stencil/pull/154)
- Fixed checking dictionary values for nil in `default` filter.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#162](https://github.com/stencilproject/Stencil/pull/162)
- Fixed comparing string variables with string literals, in Swift 4 string literals became `Substring` and thus couldn't be directly compared to strings.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#168](https://github.com/stencilproject/Stencil/pull/168)
- Integer literals now resolve into Int values, not Float.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#181](https://github.com/stencilproject/Stencil/pull/181)
- Fixed accessing properties of optional properties via reflection.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#204](https://github.com/stencilproject/Stencil/pull/204)
- No longer render optional values in arrays as `Optional(..)`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#205](https://github.com/stencilproject/Stencil/pull/205)
- Fixed subscription tuples by value index, i.e. `{{ tuple.0 }}`.  
  [Ilya Puchka](https://github.com/ilyapuchka)
  [#172](https://github.com/stencilproject/Stencil/pull/172)


## 0.10.1

### Enhancements

- Add support for Xcode 9.1.

## 0.10.0

### Enhancements

- Adds `counter0` to for loop context allowing you to get the current index of
  the for loop 0 indexed.
- Introduces a new `DictionaryLoader` for loading templates from a Swift
  Dictionary.
- Added `in` expression in if tag for strings and arrays of hashable types
- You can now access the amount of items in a dictionary using the `count`
  property.

### Bug Fixes

- Fixes a potential crash when using the `{% for %}` template tag with the
  incorrect amount of arguments.
- Fixes a potential crash when using incomplete tokens in a template for
  example, `{%%}` or `{{}}`.
- Fixes evaluating nil properties as true


## 0.9.0

### Enhancements

- `for` block now can contain `where` expression to filter array items. For example `{% for item in items where item > 1 %}` is now supported.
- `if` blocks may now contain else if (`elif`) conditions.

  ```html+django
  {% if one or two and not three %}
    one or two but not three
  {% elif four %}
    four
  {% else %}
    not one, two, or four
  {% endif %}
  ```

- `for` block now allows you to iterate over array of tuples or dictionaries.

  ```html+django
  {% for key,value in thing %}
    <li>{{ key }}: {{ value }}</li>
  {% endfor %}
  ```

### Bug Fixes

- You can now use literal filter arguments which contain quotes.
  [#98](https://github.com/stencilproject/Stencil/pull/98)


## 0.8.0

### Breaking

- It is no longer possible to create `Context` objects. Instead, you can pass a
  dictionary directly to a `Template`s `render` method.

  ```diff
  - try template.render(Context(dictionary: ["name": "Kyle"]))
  + try template.render(["name": "Kyle"])
  ```

- Template loader are no longer passed into a `Context`, instead you will need
  to pass the `Loader` to an `Environment` and create a template from the
  `Environment`.

  ```diff
  let loader = FileSystemLoader(paths: ["templates/"])

  - let template = loader.loadTemplate(name: "index.html")
  - try template.render(Context(dictionary: ["loader": loader]))
  + let environment = Environment(loader: loader)
  + try environment.renderTemplate(name: "index.html")
  ```

- `Loader`s will now throw a `TemplateDoesNotExist` error when a template
  is not found.

- `Namespace` has been removed and replaced by extensions. You can create an
  extension including any custom template tags and filters. A collection of
  extensions can be passed to an `Environment`.

### Enhancements

- `Environment` is a new way to load templates. You can configure an
  environment with custom template filters, tags and loaders and then create a
  template from an environment.

  Environment also provides a convenience method to render a template directly.

- `FileSystemLoader` will now ensure that template paths are within the base
  path. Any template names that try to escape the base path will raise a
  `SuspiciousFileOperation` error.

- New `{% filter %}` tag allowing you to perform a filter across the contents
  of a block.

  ```html+django
  {% filter lowercase %}
    This Text Will Be Lowercased.
  {% endfilter %}
  ```

- You can now use `{{ block.super }}` to render a super block from another `{%
  block %}`.

- `Environment` allows you to provide a custom `Template` subclass, allowing
  new template to use a specific subclass.

- If expressions may now contain filters on variables. For example
  `{% if name|uppercase == "TEST" %}` is now supported.

### Deprecations

- `Template` initialisers have been deprecated in favour of using a template
  loader such as `FileSystemLoader` inside an `Environment`.

- The use of whitespace inside variable filter expression is now deprecated.

  ```diff
  - {{ name | uppercase }}
  + {{ name|uppercase }}
  ```

### Bug Fixes

- Restores compatibility with ARM based platforms such as iOS. Stencil 0.7
  introduced compilation errors due to using the `Float80` type which is not
  available.


## 0.7.1

### Bug Fixes

- Fixes an issue where using `{% if %}` statements which use operators would
  throw a syntax error.


## 0.7.0

### Breaking

- `TemplateLoader` has been renamed to `FileSystemLoader`. The
  `loadTemplate(s)` methods are now throwing and now take labels for the `name`
  and `names` arguments.

- Many internal classes are no longer public. Some APIs were previously
  accessible due to earlier versions of Swift requiring the types to be public
  to be able to test. Now we have access to `@testable` these can correctly be
  private.

- `{% ifnot %}` tag is now deprecated, please use `{% if not %}` instead.

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

- `{% for %}` tag now supports filters.

    ```html+django
    {% for user in non_admins|default:admins %}
      {{ user }}
    {% endfor %}
    ```

### Bug Fixes

- Variables (`{{ variable.5 }}`) that reference an array index at an unknown
  index will now resolve to `nil` instead of causing a crash.  
  [#72](https://github.com/stencilproject/Stencil/issues/72)

- Templates can now extend templates that extend other templates.  
  [#60](https://github.com/stencilproject/Stencil/issues/60)

- If comparisons will now treat 0 and below numbers as negative.


## 0.6.0

### Enhancements

- Adds support for Swift 3.0.
