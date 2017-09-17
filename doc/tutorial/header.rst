.. testsetup:: *

    import gfapy
    gfa = gfapy.Gfa()

.. _header:

The Header
----------

GFA files may contain one or multiple header lines (record type: "H").  These
lines may be present in any part of the file, not necessarily at the beginning.

Although the header may consist of multiple lines, its content refers to the
whole file. Therefore in Gfapy the header is accessed using a single line
instance (accessible by the :attr:`~gfapy.lines.headers.Headers.header`
property). Header lines contain only tags. If not header line is present in the
Gfa, then the header line object will be empty (i.e. contain no tags).

Note that header lines cannot be connected to the Gfa as other lines (i.e.
calling :meth:`~gfapy.line.common.connection.Connection.connect` on them raises
an exception). Instead they must be merged to the existing Gfa header, using
`add_line` on the Gfa instance.

.. doctest::

    >>> gfa.add_line("H\tnn:f:1.0") #doctest: +ELLIPSIS
    >>> gfa.header.nn
    1.0
    >>> gfapy.Line("H\tnn:f:1.0").connect(gfa)
    Traceback (most recent call last):
    ...
    gfapy.error.RuntimeError: ...

Multiple definitions of the predefined header tags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For the predefined tags (``VN`` and ``TS``), the presence of multiple
values in different lines is an error, unless the value is the same in
each instance (in which case the repeated definitions are ignored).

.. doctest::

    >>> gfa.add_line("H\tVN:Z:1.0") #doctest: +ELLIPSIS
    >>> gfa.add_line("H\tVN:Z:1.0") # ignored #doctest: +ELLIPSIS
    >>> gfa.add_line("H\tVN:Z:2.0")
    Traceback (most recent call last):
    ...
    gfapy.error.VersionError: ...

Multiple definitions of custom header tags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the tags are present only once in the header in its entirety, the access to
the tags is the same as for any other line (see the :ref:`tags` chapter).

However, the specification does not forbid custom tags to be defined with
different values in different header lines (which we name "multi-definition
tags"). This particular case is handled in the next sections.

Reading multi-definitions tags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reading, validating and setting the datatype of multi-definition tags is done
using the same methods as for all other lines (see the :ref:`tags` chapter).
However, if a tag is defined multiple times on multiple H lines, reading the
tag will return a list of the values on the lines. This array is an instance of
the subclass ``gfapy.FieldArray`` of list.

.. doctest::

    >>> gfa.add_line("H\txx:i:1") #doctest: +ELLIPSIS
    >>> gfa.add_line("H\txx:i:2") #doctest: +ELLIPSIS
    >>> gfa.add_line("H\txx:i:3") #doctest: +ELLIPSIS
    >>> gfa.header.xx
    gfapy.FieldArray('i',[1, 2, 3])

Setting tags
~~~~~~~~~~~~

There are two possibilities to set a tag for the header. The first is
the normal tag interface (using ``set`` or the tag name property). The
second is to use ``add``. The latter supports multi-definition tags,
i.e. it adds the value to the previous ones (if any), instead of
overwriting them.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.header.xx
    >>> gfa.header.add("xx", 1)
    >>> gfa.header.xx
    1
    >>> gfa.header.add("xx", 2)
    >>> gfa.header.xx
    gfapy.FieldArray('i',[1, 2])
    >>> gfa.header.set("xx", 3)
    >>> gfa.header.xx
    3

Modifying field array values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Field arrays can be modified directly (e.g. adding new values or
removing some values). After modification, the user may check if the
array values remain compatible with the datatype of the tag using the
:meth:`~gfapy.line.common.validate.Validate.validate_field`` method.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.header.xx = gfapy.FieldArray('i',[1,2,3])
    >>> gfa.header.xx
    gfapy.FieldArray('i',[1, 2, 3])
    >>> gfa.header.validate_field("xx")
    >>> gfa.header.xx.append("X")
    >>> gfa.header.validate_field("xx")
    Traceback (most recent call last):
    ...
    gfapy.error.FormatError: ...

If the field array is modified using array methods which return a list
or data of any other type, a field array must be constructed, setting
its datatype to the value returned by calling
:meth:`~gfapy.line.common.field_datatype.FieldDatatype.get_datatype`
on the header.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.header.xx = gfapy.FieldArray('i',[1,2,3])
    >>> gfa.header.xx
    gfapy.FieldArray('i',[1, 2, 3])
    >>> gfa.header.xx = gfapy.FieldArray(gfa.header.get_datatype("xx"),
    ... list(map(lambda x: x+1, gfa.header.xx)))
    >>> gfa.header.xx
    gfapy.FieldArray('i',[2, 3, 4])

String representation of the header
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For consistency with other line types, the string representation of the header
is a single-line string, eventually non standard-compliant, if it contains
multiple instances of the tag. (and when calling
:meth:`~gfapy.line.common.writer.Writer.field_to_s` for a tag present multiple
times, the output string will contain the instances of the tag, separated by
tabs).

However, when the Gfa is output to file or string, the header is split into
multiple H lines with single tags, so that standard-compliant GFA is output.
The split header can be retrieved using the
:attr:`~gfapy.lines.headers.Headers.headers` property of the Gfa instance.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.header.VN = "1.0"
    >>> gfa.header.xx = gfapy.FieldArray('i',[1,2])
    >>> gfa.header.field_to_s("xx")
    '1\t2'
    >>> gfa.header.field_to_s("xx", tag=True)
    'xx:i:1\txx:i:2'
    >>> str(gfa.header)
    'H\tVN:Z:1.0\txx:i:1\txx:i:2'
    >>> [str(h) for h in gfa.headers]
    ['H\tVN:Z:1.0', 'H\txx:i:1', 'H\txx:i:2']
    >>> str(gfa)
    'H\tVN:Z:1.0\nH\txx:i:1\nH\txx:i:2'

