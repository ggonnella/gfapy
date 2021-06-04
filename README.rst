Gfapy
~~~~~

|travis| |readthedocs| |latesttag| |license| |requiresio|

|bioconda| |pypi| |debian| |ubuntu|

.. sphinx-begin

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

Gfapy has been written for Python 3 and tested using Python version 3.7.
It does not require any additional Python packages or other software.

Installation
~~~~~~~~~~~~

Gfapy is distributed as a Python package and can be installed using
the Python package manager pip, as well as conda (in the Bioconda channel).
It is also available as a package in some Linux distributions (Debian, Ubuntu).

The following command installs the current stable version from the Python
Packages index::

  pip install gfapy

If you would like to install the current development version from Github,
use the following command::

  pip install -e git+https://github.com/ggonnella/gfapy.git#egg=gfapy

Alternatively it is possible to install gfapy using conda. Gfapy is
included in the Bioconda (https://bioconda.github.io/) channel::

  conda install -c bioconda gfapy

Usage
~~~~~

If you installed gfapy as described above, you can import it in your script
using the conventional Python syntax::

  >>> import gfapy

Documentation
~~~~~~~~~~~~~

The documentation, including this introduction to Gfapy, a user manual
and the API documentation is hosted on the ReadTheDocs server,
at the URL http://gfapy.readthedocs.io/en/latest/ and it can be
downloaded as PDF from the URL
https://github.com/ggonnella/gfapy/blob/master/manual/gfapy-manual.pdf.

References
~~~~~~~~~~

Giorgio Gonnella and Stefan Kurtz "GfaPy: a flexible and extensible software
library for handling sequence graphs in Python", Bioinformatics (2017) btx398
https://doi.org/10.1093/bioinformatics/btx398

.. sphinx-end

.. |travis|
   image:: https://travis-ci.com/ggonnella/gfapy.svg?branch=master
   :target: https://travis-ci.com/ggonnella/gfapy
   :alt: Travis

.. |latesttag|
   image:: https://img.shields.io/github/v/tag/ggonnella/gfapy
   :target: https://github.com/ggonnella/gfapy/tags
   :alt: Latest GitHub tag

.. |readthedocs|
   image:: https://readthedocs.org/projects/pip/badge/?version=stable
   :target: https://pip.pypa.io/en/stable/?badge=stable
   :alt: ReadTheDocs

.. |bioconda|
   image:: https://img.shields.io/conda/vn/bioconda/gfapy
   :target: https://bioconda.github.io/recipes/gfapy/README.html
   :alt: Bioconda

.. |pypi|
   image:: https://img.shields.io/pypi/v/gfapy
   :target: https://pypi.org/project/gfapy/
   :alt: PyPI

.. |debian|
   image:: https://img.shields.io/debian/v/gfapy
   :target: https://packages.debian.org/search?keywords=gfapy
   :alt: Debian

.. |ubuntu|
   image:: https://img.shields.io/ubuntu/v/gfapy
   :target: https://packages.ubuntu.com/search?keywords=gfapy
   :alt: Ubuntu

.. |license|
   image:: https://img.shields.io/pypi/l/gfapy
   :target: https://github.com/ggonnella/gfapy/blob/master/LICENSE.txt
   :alt: ISC License
   
.. |requiresio|
   image:: https://requires.io/github/ggonnella/gfapy/requirements.svg?branch=master
   :target: https://requires.io/github/ggonnella/gfapy/requirements/?branch=master
   :alt: Requirements Status
