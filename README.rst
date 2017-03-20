The Graphical Fragment Assembly (GFA) are formats for the representation
of sequence graphs, including assembly, variation and splicing graphs.
Two versions of GFA have been defined (GFA1 and GFA2) and several sequence
analysis programs have been adopting the formats as an interchange format,
which allow to easily combine different sequence analysis tools.

This library implements the GFA1 and GFA2 specification
described at https://github.com/GFA-spec/GFA-spec/blob/master/GFA-spec.md.
It allows to create a Gfa object from a file in the GFA format
or from scratch, to enumerate the graph elements (segments, links,
containments, paths and header lines), to traverse the graph (by
traversing all links outgoing from or incoming to a segment), to search for
elements (e.g. which links connect two segments) and to manipulate the
graph (e.g. to eliminate a link or a segment or to duplicate a segment
distributing the read counts evenly on the copies).

The GFA format can be easily extended by users by defining own custom
tags and record types. In Gfapy, it is easy to write extensions modules,
which allow to define custom record types and datatypes for the parsing
and validation of custom fields. The custom lines can be connected, using
references, to each other and to lines of the standard record types.

Requirements
~~~~~~~~~~~~

Gfapy has been written for Python 3 and tested using Python version 3.3.
It does not require any additional Python packages or other software.

Installation
~~~~~~~~~~~~

Gfapy is distributed as a Python package and can be installed using
the python package manager pip.

The following command installs the current stable version from the Python
Packages index::

  pip install gfapy

If you would like to install the current development version from Github,
use the following command::

  pip install -e git+https://github.com/ggonnella/gfapy.git#egg=gfapy

Usage
~~~~~

If you installed gfapy as described above, you can import it in your script
using the conventional Python syntax::

  >>> import gfapy

Documentation
~~~~~~~~~~~~~

The documentation, including this introduction to Gfapy, an user manual
and the API documentation is hosted on the ReadTheDocs server,
at the URL http://gfapy.readthedocs.io/en/latest/ and it can be
downloaded as PDF from the URL
https://github.com/ggonnella/gfapy/blob/master/manual/gfapy-manual.pdf.

References
~~~~~~~~~~

The manuscript describing Gfapy has been submitted and is currently under
review. This section will be updated, as soon as the publication is available.
