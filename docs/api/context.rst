Context
=======

A Context is a structure containing any templates you would like to use in a
template. It’s somewhat like a dictionary, however you can push and pop to
scope variables. So that means that when iterating over a for loop, you can
push a new scope into the context to store any variables local to the scope.

You can initialise a ``Context`` with a ``Dictionary``.

.. code-block:: swift

    Context(dictionary: [String: Any]? = nil)

API
----

Subscripting
~~~~~~~~~~~~

You can use subscripting to get and set values from the context.

.. code-block:: swift

    context["key"] = value
    let value = context["key"]

``push()``
~~~~~~~~~~

A ``Context`` is a stack. You can push a new level onto the ``Context`` so that
modifications can easily be poped off. This is useful for isolating mutations
into scope of a template tag. Such as ``{% if %}`` and ``{% for %}`` tags.

.. code-block:: swift

    context.push(["name": "example"]) {
        // context contains name which is `example`.
    }

    // name is popped off the context after the duration of the closure.

``flatten()``
~~~~~~~~~~~~~

Using ``flatten()`` method you can get whole ``Context`` stack as one
dictionary including all variables.

.. code-block:: swift

    let dictionary = context.flatten()
