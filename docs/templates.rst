Language overview
==================

- ``{{ ... }}`` for variables to print to the template output
- ``{% ... %}`` for tags
- ``{# ... #}`` for comments not included in the template output

Variables
---------

A variable can be defined in your template using the following:

.. code-block:: html+django

    {{ variable }}

Stencil will look up the variable inside the current variable context and
evaluate it. When a variable contains a dot, it will try doing the
following lookup:

- Context lookup
- Dictionary lookup
- Array and string lookup (first, last, count, by index)
- Key value coding lookup
- @dynamicMemberLookup when conforming to our `DynamicMemberLookup` marker protocol
- Type introspection (via ``Mirror``)

For example, if `people` was an array:

.. code-block:: html+django

    There are {{ people.count }} people. {{ people.first }} is the first
    person, followed by {{ people.1 }}.

You can also use the subscript operator for indirect evaluation. The expression
between brackets will be evaluated first, before the actual lookup will happen.

For example, if you have the following context:

.. code-block:: swift

    [
      "item": [
        "name": "John"
      ],
      "key": "name"
    ]

.. code-block:: html+django

    The result of {{ item[key] }} will be the same as {{ item.name }}. It will first evaluate the result of {{ key }}, and only then evaluate the lookup expression.

You can use the `LazyValueWrapper` type to have values in your context that will be lazily evaluated. The provided value will only be evaluated when it's first accessed in your template, and will be cached afterwards. For example:

.. code-block:: swift

    [
      "magic": LazyValueWrapper(myHeavyCalculations())
    ]

Boolean expressions
-------------------

Boolean expressions can be rendered using ``{{ ... }}`` tag.
For example, this will output string `true` if variable is equal to 1 and `false` otherwise:

.. code-block:: html+django

    {{ variable == 1 }}

Filters
~~~~~~~

Filters allow you to transform the values of variables. For example, they look like:

.. code-block:: html+django

    {{ variable|uppercase }}

See :ref:`all builtin filters <built-in-filters>`.

Tags
----

Tags are a mechanism to execute a piece of code, allowing you to have
control flow within your template.

.. code-block:: html+django

    {% if variable %}
      {{ variable }} was found.
    {% endif %}

A tag can also affect the context and define variables as follows:

.. code-block:: html+django

    {% for item in items %}
      {{ item }}
    {% endfor %}

Stencil includes of built-in tags which are listed below. You can also
extend Stencil by providing your own tags.

See :ref:`all builtin tags <built-in-tags>`.

Comments
--------

To comment out part of your template, you can use the following syntax:

.. code-block:: html+django

    {# My comment is completely hidden #}

.. _template-inheritance:

Whitespace Control
------------------

Stencil supports the same syntax as Jinja for whitespace control, see [their docs for more information](https://jinja.palletsprojects.com/en/3.1.x/templates/#whitespace-control).

Essentially, Stencil will **not** trim whitespace by default. However you can:

- Control how this is handled for the whole template by setting the trim behaviour. We provide a few pre-made combinations such as `nothing` (default), `smart` and `all`. More granular combinations are possible.
- You can disable this per-block using the `+` control character. For example `{{+ if … }}` to preserve whitespace before.
- You can force trimming per-block by using the `-` control character. For example `{{ if … -}}` to trim whitespace after.

Template inheritance
--------------------

Template inheritance allows the common components surrounding individual pages
to be shared across other templates. You can define blocks which can be
overidden in any child template.

Let's take a look at an example. Here is our base template (``base.html``):

.. code-block:: html+django

    <html>
      <head>
        <title>{% block title %}Example{% endblock %}</title>
      </head>

      <body>
        <aside>
          {% block sidebar %}
            <ul>
              <li><a href="/">Home</a></li>
              <li><a href="/notes/">Notes</a></li>
            </ul>
          {% endblock %}
        </aside>

        <section>
          {% block content %}{% endblock %}
        </section>
      </body>
    </html>

This example declares three blocks, ``title``, ``sidebar`` and ``content``. We
can use the ``{% extends %}`` template tag to inherit from our base template
and then use ``{% block %}`` to override any blocks from our base template.

A child template might look like the following:

.. code-block:: html+django

    {% extends "base.html" %}

    {% block title %}Notes{% endblock %}

    {% block content %}
      {% for note in notes %}
        <h2>{{ note }}</h2>
      {% endfor %}
    {% endblock %}

.. note:: You can use ``{{ block.super }}` inside a block to render the contents of the parent block inline.

Since our child template doesn't declare a sidebar block. The original sidebar
from our base template will be used. Depending on the content of ``notes`` our
template might be rendered like the following:

.. code-block:: html

    <html>
      <head>
        <title>Notes</title>
      </head>

      <body>
        <aside>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/notes/">Notes</a></li>
          </ul>
        </aside>

        <section>
          <h2>Pick up food</h2>
          <h2>Do laundry</h2>
        </section>
      </body>
    </html>

You can use as many levels of inheritance as needed. One common way of using
inheritance is the following three-level approach:

* Create a ``base.html`` template that holds the main look-and-feel of your site.
* Create a ``base_SECTIONNAME.html`` template for each “section” of your site.
  For example, ``base_news.html``, ``base_news.html``. These templates all
  extend ``base.html`` and include section-specific styles/design.
* Create individual templates for each type of page, such as a news article or
  blog entry. These templates extend the appropriate section template.

You can render block's content more than once by using ``{{ block.name }}`` **after** a block is defined.
