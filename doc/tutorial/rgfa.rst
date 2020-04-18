.. testsetup:: *

    import gfapy

.. _rgfa:

rGFA
----

gfapy supports the rGFA format as a dialect of GFA1.
The support is still experimental. Please contact the authors
for any bug or feature request regarding rGFA.

The main issue with rGFA is that application specific tags are defined, which
are upper case. This is forbidden by the GFA specification. In order
to support them a dialect keyword has been added to the constructor
`Gfa()` and to func:`Gfa.from_file() <gfapy.gfa.Gfa.from_file>`.
If dialect is set to `"rgfa"`, the custom tags are allowed to be upper
case.

rGFA is (except for the case of the tags) a subset of GFA1.
Thus, when the rgfa dialect is selected in the constructors, a validation test
is performed, to ensure that GFA version is 1, that only rGFA-compatible lines
are used (S and L) and that the required tags are present and
tags have the required datatypes.
The validations can also be executed manually using
`Gfa.validate_rgfa() <gfapy.gfa.Gfa.validate_rgfa>`.

.. doctest::

   >>> g = gfapy.Gfa("S\tS1\tCTGAA\tSN:Z:chr1\tSO:i:0\tSR:i:0")
   Traceback (most recent call last):
   gfapy.error.FormatError: ...
   >>> g = gfapy.Gfa("S\tS1\tCTGAA\tSN:Z:chr1\tSO:i:0\tSR:i:0", dialect="rgfa")
   >>> g.segment_names
   ['S1']
   >>> g.stable_sequence_names
   ['chr1']
   >>> g.add_line("S\tS2\tACG\tSN:Z:chr1\tSO:i:5\tSR:i:0")

