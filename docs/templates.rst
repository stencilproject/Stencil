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
- Array lookup (first, last, count, index)
- Key value coding lookup
- Type introspection

For example, if `people` was an array:

.. code-block:: html+django

    There are {{ people.count }} people. {{ people.first }} is the first
    person, followed by {{ people.1 }}.

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
