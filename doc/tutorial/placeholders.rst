.. testsetup:: *

    import gfapy

.. _placeholders:

Placeholders
------------

Some positional fields may contain an undefined value S: ``sequence``;
L/C: ``overlap``; P: ``overlaps``; E: ``eid``, ``alignment``; F:
``alignment``; G: ``gid``, ``var``; U/O: ``pid``. In GFA this value is
represented by a ``*``.

In Gfapy the class `Placeholder` represent the undefined value.

Distinguishing placeholders
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :func:`gfapy.is_placeholder() <gfapy.placeholder.is_placeholder>` method
allows to check if a value is a placeholder; a value is a placeholder if
it is a `Placeholder` instance, or would represent
a placeholder in GFA (a string containing ``*``), or would be represented
by a placeholder in GFA (e.g. an empty array).

.. doctest::

    >>> gfapy.is_placeholder("*")
    True
    >>> gfapy.is_placeholder("**")
    False
    >>> gfapy.is_placeholder([])
    True
    >>> gfapy.is_placeholder(gfapy.Placeholder())
    True

Note that, as a placeholder is ``False`` in boolean context, just a
``if not placeholder`` will also work, if the value is an instance
of `Placeholder`, but not always for the other cases (in particular not
for the string representation ``*``).
Therefore using
:func:`gfapy.is_placeholder() <gfapy.placeholder.is_placeholder>`
is better.

.. doctest::

    >>> if "*": print('* is not a placeholder')
    * is not a placeholder
    >>> if gfapy.is_placeholder("*"): print('but it represents a placeholder')
    but it represents a placeholder

Compatibility methods
~~~~~~~~~~~~~~~~~~~~~

Some methods are defined for placeholders, which allow them to respond
to the same methods as defined values. This allows to write generic
code.

.. doctest::

    >>> placeholder = gfapy.Placeholder()
    >>> placeholder.validate() # does nothing
    >>> len(placeholder)
    0
    >>> placeholder[1]
    gfapy.Placeholder()
    >>> placeholder + 1
    gfapy.Placeholder()

