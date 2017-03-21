.. testsetup:: *

    import gfapy

.. _positions:

Positions
---------

The only position field in GFA1 is the ``pos`` field in the C lines.
This represents the starting position of the contained segment in the
container segment and is 0-based.

Some fields in GFA2 E lines (``beg1, beg2, end1, end2``) and F lines
(``s_beg, s_end, f_beg, f_end``) are positions. According to the
specification, they are 0-based and represent virtual ticks before and
after each string in the sequence. Thus ranges are represented similarly
to the Python range conventions: e.g. a 1-character prefix of a sequence
will have begin 0 and end 1.

Last positions in GFA2
~~~~~~~~~~~~~~~~~~~~~~

The GFA2 positions must contain an additional string (``$``) appended to
the integer, if (and only if) they are the last position in the segment
sequence. These particular positions are represented in Gfapy as
instances of the class :class:`~gfapy.lastpos.LastPos`.

To create a lastpos instance, the constructor can be used with an
integer, or the string representation (which must end with the dollar
sign, otherwise an integer is returned):

.. doctest::

    >>> str(gfapy.LastPos(12))
    '12$'
    >>> gfapy.LastPos("12")
    12
    >>> str(gfapy.LastPos("12"))
    '12'
    >>> gfapy.LastPos("12$")
    gfapy.LastPos(12)
    >>> str(gfapy.LastPos("12$"))
    '12$'

Subtracting an integer from a lastpos returns a lastpos if 0 subtracted,
an integer otherwise. This allows to do some arithmetic on positions
without making them invalid.

.. doctest::

    >>> gfapy.LastPos(12) - 0
    gfapy.LastPos(12)
    >>> gfapy.LastPos(12) - 1
    11

The functions :func:`~gfapy.lastpos.islastpos` and
:func:`~gfapy.lastpos.isfirstpos` allow to
determine if a position value is 0 (first), or the last position, using
the same syntax for lastpos and integer instances.

.. doctest::

    >>> gfapy.isfirstpos(0)
    True
    >>> gfapy.islastpos(0)
    False
    >>> gfapy.isfirstpos(12)
    False
    >>> gfapy.islastpos(12)
    False
    >>> gfapy.islastpos(gfapy.LastPos("12"))
    False
    >>> gfapy.islastpos(gfapy.LastPos("12$"))
    True
