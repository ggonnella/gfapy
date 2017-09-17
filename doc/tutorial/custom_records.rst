.. testsetup:: *

    import gfapy
    g = gfapy.Gfa(version = 'gfa2')

.. _custom_records:

Custom records
--------------

The GFA2 specification considers each line which starts with a non-standard
record type a custom (i.e. user- or program-specific) record.
Gfapy allows to retrieve these records and access their data using a
similar interface to that for the predefined record types.

Retrieving, adding and deleting custom records
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gfa instances have the property
:func:`~gfapy.lines.collections.Collections.custom_records`,
a list of all line instances with a non-standard record type. Among these,
records of a specific record type are retrieved using the method
:func:`Gfa.custom_records_of_type(record_type)
<gfapy.lines.collections.Collections.custom_records_of_type>`.
Lines are added and deleted using the same methods
(:func:`~gfapy.lines.creators.Creators.add_line` and
:func:`~gfapy.line.common.disconnection.Disconnection.disconnect`) as for
other line types.

.. doctest::

   >>> g.add_line("X\tcustom line") #doctest: +ELLIPSIS
   >>> g.add_line("Y\tcustom line") #doctest: +ELLIPSIS
   >>> [str(line) for line in g.custom_records] #doctest: +SKIP
   ['X\tcustom line', 'Y\tcustom line']
   >>> g.custom_record_keys) #doctest: +SKIP
   ['X', 'Y']
   >>> [str(line) for line in g.custom_records_of_type('X')]
   ['X\tcustom line']
   >>> g.custom_records_of_type("X")[-1].disconnect()
   >>> g.custom_records_of_type('X')
   []

Interface without extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If no extension (see :ref:`extensions` section) has been defined to handle a
custom record type, the interface has some limitations: the field content is
not validated, and the field names are unknown.  The generic custom record
class is employed
(:class:`~gfapy.line.custom_record.custom_record.CustomRecord`).

As the name of the positional fields in a custom record is not known, a generic
name ``field1``, ``field2``, ... is used.  The number of positional fields is
found by getting the length of the
:attr:`~gfapy.line.custom_record.init.Init.positional_fieldnames` list.

.. doctest::

   >>> g.add_line("X\ta\tb\tcc:i:10\tdd:i:100") #doctest: +ELLIPSIS
   >>> x = g.custom_records_of_type('X')[-1]
   >>> len(x.positional_fieldnames)
   2
   >>> x.field1
   'a'
   >>> x.field2
   'b'

Positional fields are allowed to contain any character (including non-printable
characters and spacing characters), except tabs and newlines (as they are
structural elements of the line).  No further validation is performed.

As Gfapy cannot know how many positional fields are present when parsing custom
records, a heuristic approach is followed, to identify tags. A field resembles
a tag if it starts with ``tn:d:`` where ``tn`` is a valid tag name and ``d`` a
valid tag datatype (see :ref:`tags` chapter). The fields are parsed from the
last to the first.

As soon as a field is found which does not resemble a tag, all remaining fields
are considered positionals (even if another field parsed later resembles a
tag). Due to this, invalid tags are sometimes wrongly taken as positional
fields (this can be avoided by writing an extension).

.. doctest::

    >>> g.add_line("X\ta\tb\tcc:i:10\tdd:i:100") #doctest: +ELLIPSIS
    >>> x1 = g.custom_records_of_type("X")[-1]
    >>> x1.cc
    10
    >>> x1.dd
    100
    >>> g.add_line("X\ta\tb\tcc:i:10\tdd:i:100\te") #doctest: +ELLIPSIS
    >>> x2 = g.custom_records_of_type("X")[-1]
    >>> x2.cc
    >>> x2.field3
    'cc:i:10'
    >>> g.add_line("Z\ta\tb\tcc:i:10\tddd:i:100") #doctest: +ELLIPSIS
    >>> x3 = g.custom_records_of_type("Z")[-1]
    >>> x3.cc
    >>> x3.field3
    'cc:i:10'
    >>> x3.field4
    'ddd:i:100'

.. _extensions:

Extensions
~~~~~~~~~~

The support for custom fields is limited, as Gfapy does not know which and how
many fields are there and how shall they be validated. It is possible to create
an extension of Gfapy, which defines new record types: this will allow to use
these record types in a similar way to the built-in types.

As an example, an extension will be described, which defines two record types:
T for taxa and M for assignments of segments to taxa. For further information
about the possible usage case for this extension, see the Supplemental
Information to the manuscript describing Gfapy.

The T records will contain a single positional field, ``tid``, a GFA2
identifier, and an optional UL string tag.  The M records will contain three
positional fields (all three GFA2 identifier): a name field ``mid`` (optional),
and two references, ``tid`` to a T line and ``sid`` to an S line. The SC
integer tag will be also defined.  Here is an example of a GFA containing M and
T lines:

.. code::

  S sA 1000 *
  S sB 1000 *
  M assignment1 t123 sA SC:i:40
  M assignment2 t123 sB
  M * B12c sB SC:i:20
  T B12c
  T t123 UL:Z:http://www.taxon123.com

Writing subclasses of the :class:`~gfapy.line.line.Line` class, it is possible to
communicate to Gfapy, how records of the M and T class shall be handled.  This
only requires to define some constants and to call the class method
:func:`~gfapy.line.line.Line.register_extension`.

The constants to define are ``RECORD TYPE``, which shall be the content
of the record type field (e.g. ``M``); ``POSFIELDS`` shall contain an ordered
dict, specifying the datatype for each positional field, in the order these
fields are found in the line; ``TAGS_DATATYPE`` is a dict, specifying the
datatype of the predefined optional tags; ``NAME_FIELD`` is a field name,
and specifies which field contains the identifier of the line.
For details on predefined and custom datatypes, see the next sections
(:ref:`predefined_datatypes` and :ref:`custom_datatypes`).

To handle references, :func:`~gfapy.line.line.Line.register_extension`
can be supplied with a ``references`` parameter, a list of triples
``(fieldname, classname, backreferences)``.  Thereby ``fieldname`` is the name
of the field in the corresponding record containing the reference (e.g.
``sid``), ``classname`` is the name of the class to which the reference goes
(e.g. ``gfa.line.segment.GFA2``), and \texttt{backreferences} is how the
collection of backreferences shall be called, in the records to which reference
points to (e.g. ``metagenomic_assignments``).

.. code:: python

  from collections include OrderedDict

  class Taxon(gfapy.Line):
    RECORD_TYPE = "T"
    POSFIELDS = OrderedDict([("tid","identifier_gfa2")])
    TAGS_DATATYPE = {"UL":"Z"}
    NAME_FIELD = "tid"

  Taxon.register_extension()

  class MetagenomicAssignment(gfapy.Line):
    RECORD_TYPE = "M"
    POSFIELDS = OrderedDict([("mid","optional_identifier_gfa2"),
                             ("tid","identifier_gfa2"),
                             ("sid","identifier_gfa2")])
    TAGS_DATATYPE = {"SC":"i"}
    NAME_FIELD = "mid"

  MetagenomicAssignment.register_extension(references=
      [("sid", gfapy.line.segment.GFA2, "metagenomic_assignments"),
       ("tid", Taxon, "metagenomic_assignments")])

.. _predefined_datatypes:

Predefined datatypes for extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The datatype of fields is specified in Gfapy using classes, which provide
functions for decoding, encoding and validating the corresponding data.
Gfapy contains a number of datatypes which correspond to the description
of the field content in the GFA1 and GFA2 specification.

When writing extensions only the GFA2 field datatypes are generally used
(as GFA1 does not contain custom fields). They are summarized in
the following table:

+-------------------------------------+---------------+--------------------------------------------------------+
| Name                                | Example       | Description                                            |
+=====================================+===============+========================================================+
| ``alignment_gfa2``                  | ``12M1I3M``   | CIGAR string, Trace alignment or Placeholder (``*``)   |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``identifier_gfa2``                 | ``S1``        | ID of a line                                           |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``oriented_identifier_gfa2``        | ``S1+``       | ID of a line followed by ``+`` or ``-``                |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``optional_identifier_gfa2``        | ``*``         | ID of a line or Placeholder (``*``)                    |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``identifier_list_gfa2``            | ``S1 S2``     | space separated list of line IDs                       |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``oriented_identifier_list_gfa2``   | ``S1+ S2-``   | space separated list of line IDs plus orientations     |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``position_gfa2``                   | ``120$``      | non-negative integer, optionally followed by ``$``     |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``sequence_gfa2``                   | ``ACGNNYR``   | sequence of printable chars., no whitespace            |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``string``                          | ``a b_c;d``   | string, no tabs and newlines (Z tags)                  |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``char``                            | ``A``         | single character (A tags)                              |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``float``                           | ``1.12``      | float (f tags)                                         |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``integer``                         | ``-12``       | integer (i tags)                                       |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``optional_integer``                | ``*``         | integer or placeholder                                 |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``numeric_array``                   | ``c,10,3``    | array of integers or floats (B tags)                   |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``byte_array``                      | ``12F1FF``    | hexadecimal byte string (H tags)                       |
+-------------------------------------+---------------+--------------------------------------------------------+
| ``json``                            | ``{’b’:2}``   | JSON string, no tabs and newlines (J tags)             |
+-------------------------------------+---------------+--------------------------------------------------------+

.. _custom_datatypes:

Custom datatypes for extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For custom records, one sometimes needs datatypes not yet available in the GFA
specification. For example, a custom datatype can be defined for
the taxon identifier used in the ``tid`` field of the T and M records:
accordingly the taxon identifier shall be only either
in the form ``taxon:<n>``, where ``<n>`` is a positive integer,
or consist of letters, numbers and underscores only
(without ``:``).

To define the datatype, a class is written, which contains the following
functions:

* ``validate_encoded(string)``: validates the content of the field,
  if this is a string (e.g., the name of the T line)
* ``validate_decoded(object)``: validates the content of the field,
  if this is not a string (e.g., a reference to a T line)
* ``decode(string)``: validates the content of the field (a string)
  and returns the decoded content; note that references must not be resolved
  (there is no access to the Gfa instance here), thus the name of the
  T line will be returned unchanged
* ``encode(string)``: validates the content of the field (not in string
  form) and returns the string which codes it in the GFA file (also here
  references are validated but not converted into strings)

Finally the datatype is registered calling
:func:`~gfapy.field.field.Field.register_datatype`. The code for
the taxon ID extension is the following:

.. code:: python

  import re

  class TaxonID:

    def validate_encoded(string):
      if not re.match(r"^taxon:(\d+)$",string) and \
          not re.match(r"^[a-zA-Z0-9_]+$", string):
        raise gfapy.ValueError("Invalid taxon ID: {}".format(string))

    def decode(string):
      TaxonID.validate_encoded(string)
      return string

    def validate_decoded(obj):
      if isinstance(obj,Taxon):
        TaxonID.validate_encoded(obj.name)
      else:
        raise gfapy.TypeError(
          "Invalid type for taxon ID: "+"{}".format(repr(obj)))

    def encode(obj):
      TaxonID.validate_decoded(obj)
      return obj

  gfapy.Field.register_datatype("taxon_id", TaxonID)

To use the new datatype in the T and M lines defined above (:ref:`extensions`),
the definition of the two subclasses can be changed:
in ``POSFIELDS`` the value ``taxon_id`` shall be assigned to the key ``tid``.
