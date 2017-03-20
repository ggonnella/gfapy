Custom records
--------------

According to the GFA2 specification, each line which starts with a
non-standard record type shall be considered an user- or
program-specific record.

Gfapy allows to retrieve custom records and access their data using a
similar interface to that for the predefined record types. It assumes
that custom records consist of tab-separated fields and that the first
field is the record type.

Validation of custom records is very limited; therefore, if you work
with custom records, you may define your own validation method and call
it when you read or write custom record contents.

Retrieving, adding and deleting custom records
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The custom records of a Gfa instance can be retrieved using its
``custom_records`` property. This returns a list of all custom records,
regardless of the record type.

To retrieve only the custom records of a given type use the method
``custom_records_of_type(record_type)``.

.. code:: python

    gfa.custom_records
    gfa.custom_records_of_type("X")

Adding custom records to and removing them from a Gfa instance is
similar to any other line. So to delete a custom record,
``disconnect()`` is called on the instance. To add a custom record line,
the instance or its string representation is added using ``add_line`` on
the Gfa instance.

.. code:: python

    gfa.add_line("X\ta\tb")
    gfa.custom_records("X")[-1].disconnect()

Tags
~~~~

As Gfapy cannot know how many positional fields are present when parsing
custom records, an heuristic approach is followed, to identify tags. A
field resembles a tag if it starts with ``tn:d:`` where ``tn`` is a
valid tag name and ``d`` a valid tag datatype (see Tags chapter). The
fields are parsed from the last to the first. As soon as a field is
found which does not resemble a tag, all remaining fields are considered
positionals (even if another field parsed later resembles a tag).

.. code:: python

    gfa.add_line("X\ta\tb\tcc:i:10\tdd:i:100")
    x1 = gfa.custom_records("X")[-1]
    x1.cc # => 10
    x1.dd # => 100
    gfa.add_line("X\ta\tb\tcc:i:10\tdd:i:100\te")
    x2 = gfa.custom_records("X")[-1]
    x1.cc # => None
    x1.dd # => None

This parsing heuristics has some consequences on validations. Tags with
an invalid tag name (such as starting with a number, or with a wrong
number of letters), or an invalid tag datatype (wrong letter, or wrong
number of letters) are considered positional fields. The only validation
available for custom records tags is thus the validation of the content
of the tag, which must be valid according to the datatype.

.. code:: python

    gfa.add_line("X\ta\tb\tcc:i:10\tddd:i:100")
    x = gfa.custom_records("X")[-1]
    x.cc # => None
    # (as ddd:i:100) is considered a positional field

Positional fields
~~~~~~~~~~~~~~~~~

The positional fields in a custom record are called
``"field1", "field2", ...``. The user can iterate over the positional
field names using the array obtained by calling
``positional_fieldnames`` on the line.

Positional fields are allowed to contain any character (including
non-printable characters and spacing characters), except tabs and
newlines (as they are structural elements of the line).

Due to the parsing heuristics mentioned in the Tags section above,
invalid tags are sometimes wrongly taken as positional fields.
Therefore, the user is responsible of validating the number of
positional fields.

.. code:: python

    gfa.add_line("X\ta\tb\tcc:i:10\tdd:i:100")
    x = gfa.custom_records("X")[-1]
    len(x.positional_fieldnames) # => 2
    x.positional_fieldnames # => ["a", "b"]

Extensions
~~~~~~~~~~

The support for custom fields is limited, as Gfapy does not know which
and how many fields are there and how shall they be validated. It is
possible to create an extension of Gfapy, which defines new record
types: this will allow to use these record types in a similar way to the
built-in types. However, extending the library requires sligthly more
advanced programming than just using the predefined record types.

The manual for writing extensions is provided as Supplementary
Information to the manuscript describing Gfapy.
