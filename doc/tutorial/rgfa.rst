.. testsetup:: *

    import gfapy

.. _rgfa:

rGFA
----

rGFA (https://github.com/lh3/gfatools/blob/master/doc/rGFA.md)
is a subset of GFA1, in which only particular line types (S and L)
are allowed, and the S lines are required to contain the tags
`SN` (of type `Z`), `SO` and `SR` (of type `i`).

When working with rGFA files, it is convenient to use the `dialect="rgfa"`
option in the constructor `Gfa()` and in
func:`Gfa.from_file() <gfapy.gfa.Gfa.from_file>`.

This ensures that additional validations are performed: GFA version must be 1,
only rGFA-compatible lines (S,L) are allowed and that the required tags are
required (with the correct datatype).  The validations can also be executed
manually using `Gfa.validate_rgfa() <gfapy.gfa.Gfa.validate_rgfa>`.

Furthermore, the `stable_sequence_names` attribute of the GFA objects
returns the set of stable sequence names contained in the `SN` tags
of the segments.

.. doctest::

   >>> g = gfapy.Gfa("S\tS1\tCTGAA\tSN:Z:chr1\tSO:i:0\tSR:i:0", dialect="rgfa")
   >>> g.segment_names
   ['S1']
   >>> g.stable_sequence_names
   ['chr1']
   >>> g.add_line("S\tS2\tACG\tSN:Z:chr1\tSO:i:5\tSR:i:0")

