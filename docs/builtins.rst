Built-in template tags and filters
==================================

.. _built-in-tags:

Built-in Tags
-------------

``for``
~~~~~~~

A for loop allows you to iterate over an array found by variable lookup.

.. code-block:: html+django

    <ul>
      {% for user in users %}
        <li>{{ user }}</li>
      {% endfor %}
    </ul>

The ``for`` tag can iterate over dictionaries.

.. code-block:: html+django

    <ul>
      {% for key, value in dict %}
        <li>{{ key }}: {{ value }}</li>
      {% endfor %}
    </ul>
    
It can also iterate over ranges, tuple elements, structs' and classes' stored properties (using ``Mirror``).

You can iterate over range literals created using ``N...M`` syntax, both in ascending and descending order:

.. code-block:: html+django

    <ul>
      {% for i in 1...array.count %}
        <li>{{ i }}</li>
      {% endfor %}
    </ul>

The ``for`` tag can contain optional ``where`` expression to filter out
elements on which this expression evaluates to false.

.. code-block:: html+django

    <ul>
      {% for user in users where user.name != "Kyle" %}
        <li>{{ user }}</li>
      {% endfor %}
    </ul>

The ``for`` tag can take an optional ``{% empty %}`` block that will be
displayed if the given list is empty or could not be found.

.. code-block:: html+django

    <ul>
      {% for user in users %}
        <li>{{ user }}</li>
      {% empty %}
        <li>There are no users.</li>
      {% endfor %}
    </ul>

The for block sets a few variables available within the loop:

- ``first`` - True if this is the first time through the loop
- ``last`` - True if this is the last time through the loop
- ``counter`` - The current iteration of the loop (1 indexed)
- ``counter0`` - The current iteration of the loop (0 indexed)
- ``length`` - The total length of the loop

For example:

.. code-block:: html+django

    {% for user in users %}
      {% if forloop.first %}
        This is the first user.
      {% endif %}
    {% endfor %}

.. code-block:: html+django

    {% for user in users %}
      This is user number {{ forloop.counter }} user.
    {% endfor %}


``if``
~~~~~~

The ``{% if %}`` tag evaluates a variable, and if that variable evaluates to
true the contents of the block are processed. Being true is defined as:

* Present in the context
* Being non-empty (dictionaries or arrays)
* Not being a false boolean value
* Not being a numerical value of 0 or below
* Not being an empty string

.. code-block:: html+django

    {% if admin %}
      The user is an administrator.
    {% elif user %}
      A user is logged in.
    {% else %}
      No user was found.
    {% endif %}

Operators
^^^^^^^^^

``if`` tags may combine ``and``, ``or`` and ``not`` to test multiple variables
or to negate a variable.

.. code-block:: html+django

    {% if one and two %}
        Both one and two evaluate to true.
    {% endif %}

    {% if not one %}
        One evaluates to false
    {% endif %}

    {% if one or two %}
        Either one or two evaluates to true.
    {% endif %}

    {% if not one or two %}
        One does not evaluate to false or two evaluates to true.
    {% endif %}

You may use ``and``, ``or`` and ``not`` multiple times together. ``not`` has
higest precedence followed by ``and``. For example:

.. code-block:: html+django

    {% if one or two and three %}

Will be treated as:

.. code-block:: text

    one or (two and three)

You can use parentheses to change operator precedence. For example:

.. code-block:: html+django

    {% if (one or two) and three %}

Will be treated as:

.. code-block:: text

    (one or two) and three


``==`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value == other_value %}
      value is equal to other_value
    {% endif %}

.. note:: The equality operator only supports numerical, string and boolean types.

``!=`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value != other_value %}
      value is not equal to other_value
    {% endif %}

.. note:: The inequality operator only supports numerical, string and boolean types.

``<`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value < other_value %}
      value is less than other_value
    {% endif %}

.. note:: The less than operator only supports numerical types.

``<=`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value <= other_value %}
      value is less than or equal to other_value
    {% endif %}

.. note:: The less than equal operator only supports numerical types.

``>`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value > other_value %}
      value is more than other_value
    {% endif %}

.. note:: The more than operator only supports numerical types.

``>=`` operator
"""""""""""""""

.. code-block:: html+django

    {% if value >= other_value %}
      value is more than or equal to other_value
    {% endif %}

.. note:: The more than equal operator only supports numerical types.

``ifnot``
~~~~~~~~~

.. note:: ``{% ifnot %}`` is deprecated. You should use ``{% if not %}``.

.. code-block:: html+django

    {% ifnot variable %}
      The variable was NOT found in the current context.
    {% else %}
      The variable was found.
    {% endif %}

``now``
~~~~~~~

``filter``
~~~~~~~~~~

Filters the contents of the block.

.. code-block:: html+django

    {% filter lowercase %}
      This Text Will Be Lowercased.
    {% endfilter %}

You can chain multiple filters with a pipe (`|`).

.. code-block:: html+django

    {% filter lowercase|capitalize %}
      This Text Will First Be Lowercased, Then The First Character Will BE
      Capitalised.
    {% endfilter %}

``include``
~~~~~~~~~~~

You can include another template using the `include` tag.

.. code-block:: html+django

    {% include "comment.html" %}

By default the included file gets passed the current context. You can pass a sub context by using an optional 2nd parameter as a lookup in the current context.

.. code-block:: html+django

    {% include "comment.html" comment %}

The `include` tag requires you to provide a loader which will be used to lookup
the template.

.. code-block:: swift

    let environment = Environment(bundle: [Bundle.main])
    let template = environment.loadTemplate(name: "index.html")

``extends``
~~~~~~~~~~~

Extends the template from a parent template.

.. code-block:: html+django

    {% extends "base.html" %}

See :ref:`template-inheritance` for more information.

``block``
~~~~~~~~~

Defines a block that can be overridden by child templates. See
:ref:`template-inheritance` for more information.

.. _built-in-filters:

Built-in Filters
----------------

``capitalize``
~~~~~~~~~~~~~~

The capitalize filter allows you to capitalize a string.
For example, `stencil` to `Stencil`. Can be applied to array of strings to change each string.

.. code-block:: html+django

    {{ "stencil"|capitalize }}

``uppercase``
~~~~~~~~~~~~~

The uppercase filter allows you to transform a string to uppercase.
For example, `Stencil` to `STENCIL`. Can be applied to array of strings to change each string.

.. code-block:: html+django

    {{ "Stencil"|uppercase }}

``lowercase``
~~~~~~~~~~~~~

The uppercase filter allows you to transform a string to lowercase.
For example, `Stencil` to `stencil`. Can be applied to array of strings to change each string.

.. code-block:: html+django

    {{ "Stencil"|lowercase }}

``default``
~~~~~~~~~~~

If a variable not present in the context, use given default. Otherwise, use the
value of the variable. For example:

.. code-block:: html+django

    Hello {{ name|default:"World" }}

``join``
~~~~~~~~

Join an array of items.

.. code-block:: html+django

    {{ value|join:", " }}

.. note:: The value MUST be an array. Default argument value is empty string.

``split``
~~~~~~~~~

Split string into substrings by separator.

.. code-block:: html+django

    {{ value|split:", " }}

.. note:: The value MUST be a String. Default argument value is a single-space string.

``indent``
~~~~~~~~~

Indents lines of rendered value or block.

.. code-block:: html+django

    {{ value|indent:2," ",true }}

Filter accepts several arguments:

* indentation width: number of indentation characters to indent lines with. Default is ``4``.
* indentation character: character to be used for indentation. Default is a space.
* indent first line: whether first line of output should be indented or not. Default is ``false``.

``filter``
~~~~~~~~~

Applies the filter with the name provided as an argument to the current expression.

.. code-block:: html+django

    {{ string|filter:myfilter }}

This expression will resolve the `myfilter` variable, find a filter named the same as resolved value, and will apply it to the `string` variable. I.e. if `myfilter` variable resolves to string `uppercase` this expression will apply file `uppercase` to `string` variable.
