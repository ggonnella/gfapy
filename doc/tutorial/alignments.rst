.. testsetup:: *

    import gfapy
    from gfapy import is_placeholder, Alignment
    h = "H\tVN:Z:2.0\tTS:i:100"
    sA = "S\tA\t100\t*"
    sB = "S\tB\t100\t*"
    x = "E\tx\tA+\tB-\t0\t100$\t0\t100$\t4,2\tTS:i:50"
    gfa = gfapy.Gfa([h, sA, sB, x])

.. _alignments:

Alignments
~~~~~~~~~~

Some GFA1 (L/C overlap, P overlaps) and GFA2 (E/F alignment) fields contain
alignments or lists of alignments.  The alignment can be left unspecified and a
placeholder symbol ``*`` used instead. In GFA1 the alignments can be given as
CIGAR strings, in GFA2 also as Dazzler traces.

Gfapy uses three different classes for representing the content of alignment fields:
:class:`~gfapy.alignment.cigar.CIGAR`, :class:`~gfapy.alignment.trace.Trace`
and :class:`~gfapy.alignment.placeholder.AlignmentPlaceholder`.

Creating an alignment
^^^^^^^^^^^^^^^^^^^^^

An alignment instance is usually created from its GFA string
representation or from a list by using the
:class:`gfapy.Alignment() <gfapy.alignment.alignment.Alignment>`
constructor.

.. doctest::

    >>> from gfapy import Alignment
    >>> Alignment("*")
    gfapy.AlignmentPlaceholder()
    >>> Alignment("10,10,10")
    gfapy.Trace([10,10,10])
    >>> Alignment([10,10,10])
    gfapy.Trace([10,10,10])
    >>> Alignment("30M2I")
    gfapy.CIGAR([gfapy.CIGAR.Operation(30,'M'), gfapy.CIGAR.Operation(2,'I')])

If the argument is an alignment object it will be returned,
so that is always safe to call the method on a variable which can
contain a string or an alignment instance:

.. doctest::

    >>> Alignment(Alignment("*"))
    gfapy.AlignmentPlaceholder()
    >>> Alignment(Alignment("10,10"))
    gfapy.Trace([10,10])

Recognizing undefined alignments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :func:`gfapy.is_placeholder() <gfapy.placeholder.is_placeholder>` method
allows to test if an alignment field contains an undefined value (placeholder)
instead of a defined value (CIGAR string, trace). The method accepts as
argument either an alignment object or a string or list representation.

.. doctest::

    >>> from gfapy import is_placeholder, Alignment
    >>> is_placeholder(Alignment("30M"))
    False
    >>> is_placeholder(Alignment("10,10"))
    False
    >>> is_placeholder(Alignment("*"))
    True
    >>> is_placeholder("*")
    True
    >>> is_placeholder("30M")
    False
    >>> is_placeholder("10,10")
    False
    >>> is_placeholder([])
    True
    >>> is_placeholder([10,10])
    False

Note that, as a placeholder is ``False`` in boolean context, just a
``if not aligment`` will also work, if alignment is an alignment object.
But this of course, does not work, if it is a string representation.
Therefore it is better to use the
:func:`gfapy.is_placeholder() <gfapy.placeholder.is_placeholder>` method,
which works in both cases.

.. doctest::

    >>> if not Alignment("*"): print('no alignment')
    no alignment
    >>> if is_placeholder(Alignment("*")): print('no alignment')
    no alignment
    >>> if "*": print('not a placeholder...?')
    not a placeholder...?
    >>> if is_placeholder("*"): print('really? it is a placeholder!')
    really? it is a placeholder!

Reading and editing CIGARs
^^^^^^^^^^^^^^^^^^^^^^^^^^

CIGARs are represented by specialized lists, instances of the class
:class:`~gfapy.alignment.cigar.CIGAR`, whose elements are CIGAR operations
CIGAR operations are represented by instance of the class
:class:`~gfapy.alignment.cigar.CIGAR.Operation`,
and provide the properties ``length`` (length of the operation, an integer)
and ``code`` (one-letter string which specifies the type of operation).
Note that not all operations allowed in SAM files (for which CIGAR strings
were first defined) are also meaningful in GFA and thus GFA2 only allows
the operations ``M``, ``I``, ``D`` and ``P``.

.. doctest::

    >>> cigar = gfapy.Alignment("30M")
    >>> isinstance(cigar, list)
    True
    >>> operation = cigar[0]
    >>> type(operation)
    <class 'gfapy.alignment.cigar.CIGAR.Operation'>
    >>> operation.code
    'M'
    >>> operation.code = 'D'
    >>> operation.length
    30
    >>> len(operation)
    30
    >>> str(operation)
    '30D'

As a CIGAR instance is a list, list methods apply to it. If the array is
emptied, its string representation will be the placeholder symbol ``*``.

.. doctest::

    >>> cigar = gfapy.Alignment("1I20M2D")
    >>> cigar[0].code = "M"
    >>> cigar.pop(1)
    gfapy.CIGAR.Operation(20,'M')
    >>> str(cigar)
    '1M2D'
    >>> cigar[:] = []
    >>> str(cigar)
    '*'

The validate :func:`CIGAR.validate() <gfapy.alignment.cigar.CIGAR.validate>`
function checks if a CIGAR instance is valid. A version can be provided, as the
CIGAR validation is version specific (as GFA2 forbids some CIGAR operations).

.. doctest::

    >>> cigar = gfapy.Alignment("30M10D20M5I10M")
    >>> cigar.validate()
    >>> cigar[1].code = "L"
    >>> cigar.validate()
    Traceback (most recent call last):
      ...
    gfapy.error.ValueError:
    >>> cigar = gfapy.Alignment("30M10D20M5I10M")
    >>> cigar[1].code = "X"
    >>> cigar.validate(version="gfa1")
    >>> cigar.validate(version="gfa2")
    Traceback (most recent call last):
      ...
    gfapy.error.ValueError:

Reading and editing traces
^^^^^^^^^^^^^^^^^^^^^^^^^^

Traces are arrays of non-negative integers. The values are interpreted
using a trace spacing value. If traces are used, a trace spacing value
must be defined in a TS integer tag, either in the header, or in the
single lines which contain traces (which takes precedence over the
header global value).

.. doctest::

    >>> print(gfa) #doctest: +SKIP
    H TS:i:100
    E x A+ B- 0 100$ 0 100$ 4,2 TS:i:50
    ...
    >>> gfa.header.TS
    100
    >>> gfa.line("x").TS
    50

Query, reference and complement
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CIGARs are asymmetric, i.e.\ they consider one sequence as reference and
another sequence as query.

The :func:`~gfapy.alignment.cigar.CIGAR.length_on_reference` and
:func:`~gfapy.alignment.cigar.CIGAR.length_on_query` methods compute the length
of the alignment on the two sequences. These methods are used by the library
e.g. to convert GFA1 L lines to GFA2 E lines (which is only possible if CIGARs
are provided).

.. doctest::

    >>> cigar = gfapy.Alignment("30M10D20M5I10M")
    >>> cigar.length_on_reference()
    70
    >>> cigar.length_on_query()
    65

CIGARs are dependent on which sequence is taken as reference and which
is taken as query. For each alignment, a complement CIGAR can be
computed using the method
:func:`~gfapy.alignment.cigar.CIGAR.complement`; it is the CIGAR obtained
when the two sequences are switched.

.. doctest::

    >>> cigar = gfapy.Alignment("2M1D3M")
    >>> str(cigar.complement())
    '3M1I2M'

The current version of Gfapy does not provide a way to compute the
alignment, thus the trace information can be accessed and edited, but
not used for this purpose. Because of this there is currently no way in
Gfapy to compute a complement trace (trace obtained when the sequences
are switched).

.. doctest::

    >>> trace = gfapy.Alignment("1,2,3")
    >>> str(trace.complement())
    '*'

The complement of a placeholder is a placeholder:

.. doctest::

    >>> str(gfapy.Alignment("*").complement())
    '*'
