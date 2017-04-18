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
- ``counter`` - The current iteration of the loop

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
higest prescidence followed by ``and``. For example:

.. code-block:: html+django

    {% if one or two and three %}

Will be treated as:

.. code-block:: text

    one or (two and three)

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
For example, `stencil` to `Stencil`.

.. code-block:: html+django

    {{ "stencil"|capitalize }}

``uppercase``
~~~~~~~~~~~~~

The uppercase filter allows you to transform a string to uppercase.
For example, `Stencil` to `STENCIL`.

.. code-block:: html+django

    {{ "Stencil"|uppercase }}

``lowercase``
~~~~~~~~~~~~~

The uppercase filter allows you to transform a string to lowercase.
For example, `Stencil` to `stencil`.

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

.. note:: The value MUST be an array.
