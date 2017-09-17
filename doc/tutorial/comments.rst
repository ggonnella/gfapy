.. testsetup:: *

    import gfapy
    g = gfapy.Gfa()

.. _comments:

Comments
--------

GFA lines starting with a ``#`` symbol are considered comments. In Gfapy
comments are represented by instances of the class :class:`gfapy.line.Comment
<gfapy.line.comment.comment.Comment>`. They have a similar interface to other
line instances, with some differences, e.g. they do not support tags.

The comments collection
~~~~~~~~~~~~~~~~~~~~~~~

The comments of a Gfa object are accessed using the :func:`Gfa.comments
<gfapy.lines.collections.Collections.comments>` property.  This is a list of
comment line instances. The single elements can be modified, but the list
itself is read-only.  To remove a comment from the Gfa, you need to find the
instance in the list, and call
:func:`~gfapy.line.common.disconnection.Disconnection.disconnect` on it.  To
add a comment to a :class:`~gfapy.gfa.Gfa` instance is done similarly to other
lines, by using the :func:`Gfa.add_line(line)
<gfapy.lines.creators.Creators.add_line>` method.

.. doctest::

    >>> g.add_line("# this is a comment") #doctest: +ELLIPSIS
    >>> [str(c) for c in g.comments]
    ['# this is a comment']
    >>> g.comments[0].disconnect()
    >>> g.comments
    []

Accessing the comment content
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The content of the comment line, excluding the initial ``#`` and eventual
initial spacing characters, is included in the ``content`` field.  The initial
spacing characters can be read/changed using the ``spacer`` field. The default
value is a single space.

.. doctest::

    >>> g.add_line("# this is a comment") #doctest: +ELLIPSIS
    >>> c = g.comments[-1]
    >>> c.content
    'this is a comment'
    >>> c.spacer
    ' '
    >>> c.spacer = '___'
    >>> str(c)
    '#___this is a comment'

Tags are not supported by comment lines. If the line contains tags,
these are nor parsed, but included in the ``content`` field. Trying to set
tags raises exceptions.

.. doctest::

    >>> c = gfapy.Line("# this is not a tag\txx:i:1")
    >>> c.content
    'this is not a tag\txx:i:1'
    >>> c.xx
    >>> c.xx = 1
    Traceback (most recent call last):
    ...
    gfapy.error.RuntimeError: Tags of comment lines cannot be set
