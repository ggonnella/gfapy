.. testsetup:: *

    import gfapy
    gfa = gfapy.Gfa()

.. _references:

References
----------

Some fields in GFA lines contain identifiers or lists of identifiers
(sometimes followed by orientation strings), which reference other lines
of the GFA file. In Gfapy it is possible to follow these references and
traverse the graph.

Connecting a line to a Gfa object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In stand-alone line instances, the identifiers which reference other
lines are either strings containing the line name, pairs of strings
(name and orientation) in a ``gfapy.OrientedLine`` object, or lists of
lines names or ``gfapy.OrientedLine`` objects.

Using the ``add_line(line)`` (alias: ``append(line)``) method of the
``gfapy.Gfa`` object, or the equivalent ``connect(gfa)`` method of the
gfapy.Line instance, a line is added to a Gfa instance (this is done
automatically when a GFA file is parsed). All strings expressing
references are then changed into references to the corresponding line
objects. The method ``is_connected()`` allows to determine if a line is
connected to a gfapy instance. The read-only property ``gfa`` contains
the ``gfapy.Gfa`` instance to which the line is connected.

.. doctest::

    >>> gfa = gfapy.Gfa(version='gfa1')
    >>> link = gfapy.Line("L\tA\t-\tB\t+\t20M")
    >>> link.is_connected()
    False
    >>> link.gfa is None
    True
    >>> type(link.from_segment)
    <class 'str'>
    >>> gfa.append(link)
    >>> link.is_connected()
    True
    >>> link.gfa #doctest: +ELLIPSIS
    <gfapy.gfa.Gfa object at ...>
    >>> type(link.from_segment)
    <class 'gfapy.line.segment.gfa1.GFA1'>

References for each record type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following tables describes the references contained in each record
type. The notation ``[]`` represent lists.

GFA1
^^^^

+---------------+-------------------+---------------------------+
| Record type   | Fields            | Type of reference         |
+===============+===================+===========================+
| Link          | from, to          | Segment                   |
+---------------+-------------------+---------------------------+
| Containment   | from, to          | Segment                   |
+---------------+-------------------+---------------------------+
| Path          | segment\_names,   | [OrientedLine(Segment)]   |
+---------------+-------------------+---------------------------+
|               | links (1)         | [OrientedLine(Link)]      |
+---------------+-------------------+---------------------------+

(1): paths contain information in the fields segment\_names and
overlaps, which allow to find the identify from which they depend; these
links can be retrieved using ``links`` (which is not a field).

GFA2
^^^^

+---------------+--------------+------------------------------------+
| Record type   | Fields       | Type of reference                  |
+===============+==============+====================================+
| Edge          | sid1, sid2   | Segment                            |
+---------------+--------------+------------------------------------+
| Gap           | sid1, sid2   | Segment                            |
+---------------+--------------+------------------------------------+
| Fragment      | sid          | Segment                            |
+---------------+--------------+------------------------------------+
| Set           | items        | [Edge/Set/Path/Segment]            |
+---------------+--------------+------------------------------------+
| Path          | items        | [OrientedLine(Edge/Set/Segment)]   |
+---------------+--------------+------------------------------------+

Backreferences for each record type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When a line containing a reference to another line is connected to a Gfa
object, backreferences to it are created in the targeted line.

For each backreference collection a read-only property exist, which is
named as the collection (e.g. ``dovetails_L`` for segments). Note that
the reference list returned by these arrays are read-only and editing
the references is done using other methods (see the section "Editing
reference fields" below).

.. code:: python

    segment.dovetails_L # => [gfapy.line.edge.Link(...), ...]

The following tables describe the backreferences collections for each
record type.

GFA1
^^^^

+---------------+-------------------------+
| Record type   | Backreferences          |
+===============+=========================+
| Segment       | dovetails\_L            |
+---------------+-------------------------+
|               | dovetails\_R            |
+---------------+-------------------------+
|               | edges\_to\_contained    |
+---------------+-------------------------+
|               | edges\_to\_containers   |
+---------------+-------------------------+
|               | paths                   |
+---------------+-------------------------+
| Link          | paths                   |
+---------------+-------------------------+

GFA2
^^^^

+---------------+-------------------------+--------+
| Record type   | Backreferences          | Type   |
+===============+=========================+========+
| Segment       | dovetails\_L            | E      |
+---------------+-------------------------+--------+
|               | dovetails\_R            | E      |
+---------------+-------------------------+--------+
|               | edges\_to\_contained    | E      |
+---------------+-------------------------+--------+
|               | edges\_to\_containers   | E      |
+---------------+-------------------------+--------+
|               | internals               | E      |
+---------------+-------------------------+--------+
|               | gaps\_L                 | G      |
+---------------+-------------------------+--------+
|               | gaps\_R                 | G      |
+---------------+-------------------------+--------+
|               | fragments               | F      |
+---------------+-------------------------+--------+
|               | paths                   | O      |
+---------------+-------------------------+--------+
|               | sets                    | U      |
+---------------+-------------------------+--------+
| Edge          | paths                   | O      |
+---------------+-------------------------+--------+
|               | sets                    | U      |
+---------------+-------------------------+--------+
| O Group       | paths                   | O      |
+---------------+-------------------------+--------+
|               | sets                    | U      |
+---------------+-------------------------+--------+
| U Group       | sets                    | U      |
+---------------+-------------------------+--------+

Segment backreference convenience methods
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For segments, additional methods are available which combine in
different way the backreferences information. The
`dovetails_of_end` and `gaps_of_end` methods take an
argument ``L`` or ``R`` and return the dovetails overlaps (or gaps) of the
left or, respectively, right end of the segment sequence
(equivalent to the segment properties ``dovetails_L``/``dovetails_R`` and
``gaps_L``/``gaps_R``).

The segment ``containments`` property is a list of both containments where the
segment is the container or the contained segment. The segment ``edges``
property is a list of all edges (dovetails, containments and internals)
with a reference to the segment.

Other methods directly compute list of segments from the edges lists
mentioned above. The ``neighbours_L``, ``neighbours_R`` properties and
the `neighbours` method compute the set of segment instances which are
connected by dovetails to the segment.
The ``containers`` and ``contained``
properties similarly compute the set of segment instances which,
respectively, contains the segment, or are contained in the segment.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.append('S\tA\t*')
    >>> s = gfa.segment('A')
    >>> gfa.append('S\tB\t*')
    >>> gfa.append('S\tC\t*')
    >>> gfa.append('L\tA\t-\tB\t+\t*')
    >>> gfa.append('C\tA\t+\tC\t+\t10\t*')
    >>> [str(l) for l in s.dovetails_of_end("L")]
    ['L\tA\t-\tB\t+\t*']
    >>> s.dovetails_L == s.dovetails_of_end("L")
    True
    >>> s.gaps_of_end("R")
    []
    >>> [str(e) for e in s.edges]
    ['L\tA\t-\tB\t+\t*', 'C\tA\t+\tC\t+\t10\t*']
    >>> [str(n) for n in s.neighbours_L]
    ['S\tB\t*']
    >>> s.containers
    []
    >>> [str(c) for c in s.contained]
    ['S\tC\t*']

Multiline group definitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The GFA2 specification opens the possibility (experimental) to define
groups on multiple lines, by using the same ID for each line defining
the group. This is supported by gfapy.

This means that if multiple `Ordered` or
`Unordered` instances connected to a Gfa object have
the same ``gid``, they are merged into a single instance (technically
the last one getting added to the graph object). The items list are
merged.

The tags of multiple line defining a group shall not contradict each
other (i.e. either are the tag names on different lines defining the
group all different, or, if the same tag is present on different lines,
the value and datatype must be the same, in which case the multiple
definition will be ignored).

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.add_line("U\tu1\ts1 s2 s3")
    >>> [s.name for s in gfa.sets[-1].items]
    ['s1', 's2', 's3']
    >>> gfa.add_line('U\tu1\t4 5')
    >>> [s.name for s in gfa.sets[-1].items]
    ['s1', 's2', 's3', '4', '5']

Induced set and captured path
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The item list in GFA2 sets and paths may not contain elements which are
implicitly involved. For example a path may contain segments, without
specifying the edges connecting them, if there is only one such edge.
Alternatively a path may contain edges, without explicitly indicating the
segments. Similarly a set may contain edges, but not the segments
referred to in them, or contain segments which are connected by edges,
without the edges themselves. Furthermore groups may refer to other
groups (set to sets or paths, paths to paths only), which then
indirectly contain references to segments and edges.

Gfapy provides methods for the computation of the sets of segments and
edges which are implied by an ordered or unordered group. Thereby all
references to subgroups are resolved and implicit elements are added, as
described in the specification. The computation can, therefore, only be
applied to connected lines. For unordered groups, this computation is
provided by the method ``induced_set()``, which returns an array of
segment and edge instances. For ordered group, the computation is
provided by the method ``captured_path()``, which returns a list of
``gfapy.OrientedLine`` instances, alternating segment and edge instances
(and starting and ending in segments).

The methods ``induced_segments_set()``, ``induced_edges_set()``,
``captured_segments()`` and ``captured_edges()`` return, respectively,
the list of only segments or edges, in ordered or unordered groups.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.add_line("S\ts1\t100\t*")
    >>> gfa.add_line("S\ts2\t100\t*")
    >>> gfa.add_line("S\ts3\t100\t*")
    >>> gfa.add_line("E\te1\ts1+\ts2-\t0\t10\t90\t100$\t*")
    >>> gfa.add_line("U\tu1\ts1 s2 s3")
    >>> u = gfa.sets[-1]
    >>> [l.name for l in u.induced_edges_set]
    ['e1']
    >>> [l.name for l in u.induced_segments_set ]
    ['s1', 's2', 's3']
    >>> [l.name for l in u.induced_set ]
    ['s1', 's2', 's3', 'e1']

Disconnecting a line from a Gfa object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lines can be disconnected using the ``rm(line)`` method of the
``gfapy.Gfa`` object or the ``disconnect()`` method of the line
instance.

.. doctest::

    >>> gfa = gfapy.Gfa()
    >>> gfa.append('S\tsA\t*')
    >>> gfa.append('S\tsB\t*')
    >>> line = gfa.segment("sA")
    >>> gfa.segment_names
    ['sA', 'sB']
    >>> gfa.rm(line)
    >>> gfa.segment_names
    ['sB']
    >>> line = gfa.segment('sB')
    >>> line.disconnect()
    >>> gfa.segment_names
    []

Disconnecting a line affects other lines as well. Lines which are
dependent on the disconnected line are disconnected as well. Any other
reference to disconnected lines is removed as well. In the disconnected
line, references to lines are transformed back to strings and
backreferences are deleted.

The following tables show which dependent lines are disconnected if they
refer to a line which is being disconnected.

GFA1
^^^^

+---------------+---------------------------------+
| Record type   | Dependent lines                 |
+===============+=================================+
| Segment       | links (+ paths), containments   |
+---------------+---------------------------------+
| Link          | paths                           |
+---------------+---------------------------------+

GFA2
^^^^

+---------------+---------------------------------------+
| Record type   | Dependent lines                       |
+===============+=======================================+
| Segment       | edges, gaps, fragments, sets, paths   |
+---------------+---------------------------------------+
| Edge          | sets, paths                           |
+---------------+---------------------------------------+
| Sets          | sets, paths                           |
+---------------+---------------------------------------+

Editing reference fields
~~~~~~~~~~~~~~~~~~~~~~~~

In connected line instances, it is not allowed to directly change the
content of fields containing references to other lines, as this would
make the state of the Gfa object invalid.

Besides the fields containing references, some other fields are
read-only in connected lines. Changing some of the fields would require
moving the backreferences to other collections (position fields of edges
and gaps, ``from_orient`` and ``to_orient`` of links). The overlaps
field of connected links is readonly as it may be necessary to identify
the link in paths.

Renaming an element
^^^^^^^^^^^^^^^^^^^

The name field of a line (e.g. segment ``name``/``sid``) is not a
reference and thus can be edited also in connected lines. When the name
of the line is changed, no manual editing of references (e.g. from/to
fields in links) is necessary, as all lines which refer to the line will
still refer to the same instance. The references to the instance in the
Gfa lines collections will be automatically updated. Also, the new name
will be correctly used when converting to string, such as when the Gfa
instance is written to a GFA file.

Renaming a line to a name which already exists has the same effect of
adding a line with that name. That is, in most cases,
``gfapy.NotUniqueError`` is raised. An exception are GFA2 sets and
paths: in this case the line will be appended to the existing line with
the same name (as described in "Multiline group definitions").

Adding and removing group elements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Elements of GFA2 groups can be added and removed from both connected and
non-connected lines, using the following methods.

To add an item to or remove an item from an unordered group, use the
methods ``add_item(item)`` and ``rm_item(item)``, which take as argument
either a string (identifier) or a line instance.

To append or prepend an item to an ordered group, use the methods
``append_item(item)`` and ``prepend_item(item)``. To remove the first or
the last item of an ordered group use the methods ``rm_first_item()``
and ``rm_last_item()``.

Editing read-only fields of connected lines
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Editing the read-only information of edges, gaps, links, containments,
fragments and paths is more complicated. These lines shall be
disconnected before the edit and connected again to the Gfa object after
it. Before disconnecting a line, you should check if there are other
lines dependent on it (see tables above). If so, you will have to
disconnect these lines first, eventually update their fields and
reconnect them at the end of the operation.

Virtual lines
~~~~~~~~~~~~~

The order of the lines in GFA is not prescribed. Therefore, during
parsing, or constructing a Gfa in memory, it is possible that a line is
referenced to, before it is added to the Gfa instance. Whenever this
happens, Gfapy creates a "virtual" line instance.

Users do not have to handle with virtual lines, if they work with
complete and valid GFA files.

Virtual lines are similar to normal line instances, with some
limitations (they contain only limited information and it is not allowed
to add tags to them). To check if a line is a virtual line, one can use
the ``virtual`` property of the line.

As soon as the parser founds the real line corresponding to a previously
introduced virtual line, the virtual line is exchanged with the real
line and all references are corrected to point to the real line.

.. doctest::

    >>> g = gfapy.Gfa()
    >>> g.add_line("S\t1\t*")
    >>> g.add_line("L\t1\t+\t2\t+\t*")
    >>> l = g.dovetails[0]
    >>> g.segment("1").virtual
    False
    >>> g.segment("2").virtual
    True
    >>> l.to_segment == g.segment("2")
    True
    >>> g.segment("2").dovetails == [l]
    True
    >>> g.add_line("S\t2\t*")
    >>> g.segment("2").virtual
    False
    >>> l.to_segment == g.segment("2")
    True
    >>> g.segment("2").dovetails == [l]
    True
