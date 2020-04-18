.. testsetup:: *

    import gfapy
    gfa = gfapy.Gfa()
    gfa1 = gfapy.Gfa()
    gfa1.add_line("H\tVN:Z:1.0")
    gfa1.add_line("# this is a comment")
    gfa1.add_line("S\t1\t*")
    gfa1.add_line("S\t2\t*")
    gfa1.add_line("S\t3\t*")
    gfa2 = gfapy.Gfa()
    gfa2.add_line("H\tVN:Z:2.0\tTS:i:100")
    gfa2.add_line("X\tcustom line")
    gfa2.add_line("Y\tcustom line")

.. _gfa:

The Gfa class
-------------

The content of a GFA file is represented in Gfapy by an instance of the class
:class:`~gfapy.gfa.Gfa`.  In most cases, the Gfa instance will be constructed
from the data contained in a GFA file, using the method
:func:`Gfa.from_file() <gfapy.gfa.Gfa.from_file>`.

Alternatively, it is possible to use the construct of the class; it takes an
optional positional parameter, the content of a GFA file (as string, or as list
of strings, one per line of the GFA file).  If no GFA content is provided, the
Gfa instance will be empty.

.. doctest::

    >>> gfa = gfapy.Gfa("H\tVN:Z:1.0\nS\tA\t*")
    >>> print(len(gfa.lines))
    2
    >>> gfa = gfapy.Gfa(["H\tVN:Z:1.0", "S\tA\t*", "S\tB\t*"])
    >>> print(len(gfa.lines))
    3
    >>> gfa = gfapy.Gfa()
    >>> print(len(gfa.lines))
    0

The string representation of the Gfa object (which can be obtained using
``str()``) is the textual representation in GFA format.
Using :func:`Gfa.to_file(filename) <gfapy.gfa.Gfa.to_file>` allows
writing this representation to a GFA file (the content of the file is
overwritten).

.. doctest::

    >>> g1 = gfapy.Gfa()
    >>> g1.append("H\tVN:Z:1.0")
    >>> g1.append("S\ta\t*")
    >>> g1.to_file("my.gfa") #doctest: +SKIP
    >>> g2 = gfapy.Gfa.from_file("my.gfa") #doctest: +SKIP
    >>> str(g1)
    'H\tVN:Z:1.0\nS\ta\t*'


All methods for creating a Gfa (constructor and from_file) accept
a ``vlevel`` parameter, the validation level,
and can assume the values 0, 1, 2 and 3. A higher value means
more validations are performed. The :ref:`validation` chapter explains
the meaning of the different validation levels in detail.
The default value is 1.

.. doctest::

    >>> gfapy.Gfa().vlevel
    1
    >>> gfapy.Gfa(vlevel = 0).vlevel
    0

A further parameter is ``version``. It can be set to ``'gfa1'``,
``'gfa2'`` or left to the default value (``None``). The default
is to auto-detect the version of the GFA from the line content.
If the version is set manually, any content not compatible to the
specified version will trigger an exception. If the version is
set automatically, an exception will be raised if two lines
are found, with content incompatible to each other (e.g. a GFA1
segment followed by a GFA2 segment).

.. doctest::

    >>> g = gfapy.Gfa(version='gfa2')
    >>> g.version
    'gfa2'
    >>> g.add_line("S\t1\t*")
    Traceback (most recent call last):
    ...
    gfapy.error.VersionError: Version: 1.0 (None)
    ...
    >>> g = gfapy.Gfa()
    >>> g.version
    >>> g.add_line("S\t1\t*")
    >>> g.version
    'gfa1'
    >>> g.add_line("S\t1\t100\t*")
    Traceback (most recent call last):
    ...
    gfapy.error.VersionError: Version: 1.0 (None)
    ...

Collections of lines
~~~~~~~~~~~~~~~~~~~~

The property :attr:`~gfapy.lines.collections.Collections.lines`
of the Gfa object is a list of all the lines
in the GFA file (including the header, which is split into single-tag
lines). The list itself shall not be modified by the user directly (i.e.
adding and removing lines is done using a different interface, see
below). However the single elements of the list can be edited.

.. doctest::

   >>> for line in gfa.lines: print(line)

For most record types, a list of the lines of the record type is available
as a read-only property, which is named after the record type, in plural.

.. doctest::

   >>> [str(line) for line in gfa1.segments]
   ['S\t1\t*', 'S\t2\t*', 'S\t3\t*']
   >>> [str(line) for line in gfa2.fragments]
   []

A particular case are edges; these are in GFA1 links and containments, while in
GFA2 there is a unified edge record type, which also allows to represent
internal alignments.  In Gfapy, the
:attr:`~gfapy.lines.collections.Collections.edges` property retrieves all edges
(i.e. all E lines in GFA2, and all L and C lines in GFA1). The
:attr:`~gfapy.lines.collections.Collections.dovetails` property is a list of
all edges which represent dovetail overlaps (i.e. all L lines in GFA1 and a
subset of the E lines in GFA2). The
:attr:`~gfapy.lines.collections.Collections.containments` property is a list of
all edges which represent containments (i.e. all C lines in GFA1 and a subset
of the E lines in GFA2).

.. doctest::

   >>> gfa2.edges
   []
   >>> gfa2.dovetails
   []
   >>> gfa2.containments
   []

Paths are retrieved using the
:attr:`~gfapy.lines.collections.Collections.paths` property.  This list
contains all P lines in GFA1 and all O lines in GFA2. Sets returns the list of
all U lines in GFA2 (empty list in GFA1).

.. doctest::

   >>> gfa2.paths
   []
   >>> gfa2.sets
   []

The header contain metadata in a single or multiple lines. For ease of
access to the header information, all its tags are summarized in a
single line instance, which is retrieved using the
:attr:`~gfapy.lines.headers.Headers.header` property.  This list
The :ref:`header` chapter of this manual explains more in
detail, how to work with the header object.

.. doctest::

   >>> gfa2.header.TS
   100

All lines which start by the string ``#`` are comments; they are handled in
the :ref:`comments` chapter and are retrieved using the
:attr:`~gfapy.lines.collections.Collections.comments` property.

.. doctest::

   >>> [str(line) for line in gfa1.comments]
   ['# this is a comment']

Custom lines are lines of GFA2 files which start
with a non-standard record type. Gfapy provides basic built-in support
for accessing the information in custom lines, and allows to define
extensions for own record types for defining more advanced
functionality (see the :ref:`custom_records` chapter).

.. doctest::

   >>> [str(line) for line in gfa2.custom_records]
   ['X\tcustom line', 'Y\tcustom line']
   >>> gfa2.custom_record_keys
   ['X', 'Y']
   >>> [str(line) for line in gfa2.custom_records_of_type('X')]
   ['X\tcustom line']

Line identifiers
~~~~~~~~~~~~~~~~

Some GFA lines have a mandatory or optional identifier field: segments and
paths in GFA1, segments, gaps, edges, paths and sets in GFA2.  A line of this
type can be retrieved by identifier, using the method
:func:`Gfa.line(ID) <gfapy.gfa.Gfa.line>` using the identifier as argument.

.. doctest::

   >>> str(gfa1.line('1'))
   'S\t1\t*'

The GFA2 specification prescribes the exact namespace for the identifier
(segments, paths, sets, edges and gaps identifier share the same namespace).
The content of this namespace can be retrieved using the
:attr:`~gfapy.lines.collections.Collections.names` property.
The identifiers of single line types
can be retrieved using the properties
:attr:`~gfapy.lines.collections.Collections.segment_names`,
:attr:`~gfapy.lines.collections.Collections.edge_names`,
:attr:`~gfapy.lines.collections.Collections.gap_names`,
:attr:`~gfapy.lines.collections.Collections.path_names` and
:attr:`~gfapy.lines.collections.Collections.set_names`.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t100\t*")
   >>> g.add_line("S\tB\t100\t*")
   >>> g.add_line("S\tC\t100\t*")
   >>> g.add_line("E\tb_c\tB+\tC+\t0\t10\t90\t100$\t*")
   >>> g.add_line("O\tp1\tB+ C+")
   >>> g.add_line("U\ts1\tA b_c g")
   >>> g.add_line("G\tg\tA+\tB-\t1000\t*")
   >>> g.names
   ['A', 'B', 'C', 'b_c', 'g', 'p1', 's1']
   >>> g.segment_names
   ['A', 'B', 'C']
   >>> g.path_names
   ['p1']
   >>> g.edge_names
   ['b_c']
   >>> g.gap_names
   ['g']
   >>> g.set_names
   ['s1']

The GFA1 specification does not handle the question of the namespace of
identifiers explicitly. However, gfapy assumes and enforces
a single namespace for segment, path names and the values of the ID tags
of L and C lines. The content of this namespace can be found using
:attr:`~gfapy.lines.collections.Collections.names` property.
The identifiers of single line types
can be retrieved using the properties
:attr:`~gfapy.lines.collections.Collections.segment_names`,
:attr:`~gfapy.lines.collections.Collections.edge_names`
(ID tags of links and containments) and
:attr:`~gfapy.lines.collections.Collections.path_names`.
For GFA1, the properties
:attr:`~gfapy.lines.collections.Collections.gap_names`,
:attr:`~gfapy.lines.collections.Collections.set_names`
contain always empty lists.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t*")
   >>> g.add_line("S\tB\t*")
   >>> g.add_line("S\tC\t*")
   >>> g.add_line("L\tB\t+\tC\t+\t*\tID:Z:b_c")
   >>> g.add_line("P\tp1\tB+,C+\t*")
   >>> g.names
   ['A', 'B', 'C', 'b_c', 'p1']
   >>> g.segment_names
   ['A', 'B', 'C']
   >>> g.path_names
   ['p1']
   >>> g.edge_names
   ['b_c']
   >>> g.gap_names
   []
   >>> g.set_names
   []

Identifiers of external sequences
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fragments contain identifiers which refer to external sequences
(not contained in the GFA file). According to the specification, the
these identifiers are not part of the same namespace as the identifier
of the GFA lines. They can be retrieved using the
:attr:`~gfapy.lines.collections.Collections.external_names`
property.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t100\t*")
   >>> g.add_line("F\tA\tread1+\t10\t30\t0\t20$\t20M")
   >>> g.external_names
   ['read1']

The method
:func:`Gfa.fragments_for_external(external_ID) <gfapy.lines.finders.Finders.fragments_for_external>`
retrieves all F lines with a specified external sequence identifier.

.. doctest::

   >>> f = g.fragments_for_external('read1')
   >>> len(f)
   1
   >>> str(f[0])
   'F\tA\tread1+\t10\t30\t0\t20$\t20M'

Adding new lines
~~~~~~~~~~~~~~~~

New lines can be added to a Gfa instance using the
:func:`Gfa.add_line(line) <gfapy.lines.creators.Creators.add_line>`
method or its alias
:func:`Gfa.append(line) <gfapy.lines.creators.Creators.append>`.
The argument can be either a string
describing a line with valid GFA syntax, or a :class:`~gfapy.line.line.Line`
instance. If a string is added, a line instance is created and
then added.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t*") #doctest: +ELLIPSIS
   >>> g.segment_names
   ['A']
   >>> g.append("S\tB\t*") #doctest: +ELLIPSIS
   >>> g.segment_names
   ['A', 'B']

Editing the lines
~~~~~~~~~~~~~~~~~

Accessing the information stored in the fields of a line instance is
described in the :ref:`positional_fields` and :ref:`tags` chapters.

In Gfapy, a line instance belonging to a Gfa instance is said
to be *connected* to the Gfa instance. Direct editing the content of a connected
line is only possible, for those fields which do not contain
references to other lines. For more information on how to modify the content of
the fields of connected line, see the :ref:`references` chapter.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> e = gfapy.Line("E\t*\tA+\tB-\t0\t10\t90\t100$\t*")
   >>> e.sid1 = "C+"
   >>> g.add_line(e) #doctest: +ELLIPSIS
   >>> e.sid1 = "A+"
   Traceback (most recent call last):
   gfapy.error.RuntimeError: ...

Removing lines
~~~~~~~~~~~~~~

Disconnecting a line from the Gfa instance is done using the
:func:`Gfa.rm(line) <gfapy.lines.destructors.Destructors.rm>` method. The
argument can be a line instance or the name of a line.

In alternative, a line instance can also be disconnected using the
`disconnect` method on it.  Disconnecting a line
may trigger other operations, such as the disconnection of other lines (see the
:ref:`references` chapter).

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t*") #doctest: +ELLIPSIS
   >>> g.segment_names
   ['A']
   >>> g.rm('A') #doctest: +ELLIPSIS
   >>> g.segment_names
   []
   >>> g.append("S\tB\t*") #doctest: +ELLIPSIS
   >>> g.segment_names
   ['B']
   >>> b = g.line('B')
   >>> b.disconnect()
   >>> g.segment_names
   []

Renaming lines
~~~~~~~~~~~~~~

Lines with an identifier can be renamed. This is done simply by editing
the corresponding field (such as ``name`` or ``sid`` for a segment).
This field is not a reference to another line and can be freely edited
also in line instances connected to a Gfa. All references to the line
from other lines will still be up to date, as they will refer to the
same instance (whose name has been changed) and their string
representation will use the new name.

.. doctest::

   >>> g = gfapy.Gfa()
   >>> g.add_line("S\tA\t*") #doctest: +ELLIPSIS
   >>> g.add_line("L\tA\t+\tB\t-\t*") #doctest: +ELLIPSIS
   >>> g.segment_names
   ['A', 'B']
   >>> g.dovetails[0].from_name
   'A'
   >>> g.segment('A').name = 'C'
   >>> g.segment_names
   ['B', 'C']
   >>> g.dovetails[0].from_name
   'C'
