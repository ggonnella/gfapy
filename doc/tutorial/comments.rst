Comments
--------

GFA lines starting with a ``#`` symbol are considered comments. In Gfapy
comments are represented by instances of ``gfapy.line.Comment``. They
have a similar interface to other line instances, with some differences,
e.g. they do not support tags.

Accessing the comments
~~~~~~~~~~~~~~~~~~~~~~

Adding a comment to a ``gfapy.Gfa`` instance is done similary to other
lines, by using the ``add_line(line)`` method. The comments of a Gfa
object can be accessed using the ``comments`` method. This returns a
list of comment line instances. To remove a comment from the Gfa, you
need to find the instance in the list, and call ``disconnect()`` on it.

.. code:: python

    g.add_line("# this is a comment")
    [str(c) for c in g.comments] # => ["# this is a comment"]
    g.comments[0].disconnect()
    g.comments # => []

Accessing the comment content
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The content of the comment line, excluding the initial +#+ and eventual
initial spacing characters, is included in the field +content+.

The initial spacing characters can be read/changed using the +spacer+
field. The default value is a single space.

.. code:: python

    g.add_line("# this is a comment")
    c = g.comments[-1]
    g.content # => "this is a comment"
    g.spacer # => " "

Tags are not supported by comment lines. If the line contains tags,
these are nor parsed, but included in the +content+ field. Trying to set
tags values raises exceptions.

.. code:: python

    c = gfapy.Line.from_string("# this is not a tag\txx:i:1")
    c.content # => "this is not a tag\txx:i:1"
    c.xx # => None
    c.xx = 1 # raises an exception
