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

.. code-block:: html+django

    {% if variable %}
      The variable was found in the current context.
    {% else %}
      The variable was not found.
    {% endif %}

``ifnot``
~~~~~~~~~

.. code-block:: html+django

    {% ifnot variable %}
      The variable was NOT found in the current context.
    {% else %}
      The variable was found.
    {% endif %}

``now``
~~~~~~~

``include``
~~~~~~~~~~~

You can include another template using the `include` tag.

.. code-block:: html+django

    {% include "comment.html" %}

The `include` tag requires a TemplateLoader to be found inside your context with the paths, or bundles used to lookup the template.

.. code-block:: swift

    let context = Context(dictionary: [
      "loader": TemplateLoader(bundle:[NSBundle.mainBundle()])
    ])

``extends``
~~~~~~~~~~~

``block``
~~~~~~~~~

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
