## Custom records

According to the GFA2 specification, each line which starts with
a non-standard record type shall be considered an user- or
program-specific record.

RGFA allows to retrieve custom records and access their data using a similar
interface to that for the predefined record types. It assumes that
custom records consist of tab-separated fields and that the first field
is the record type.

Validation of custom records is very limited; therefore, if you work with custom
records, you may define your own validation method and call it when you read
or write custom record contents.

### Retrieving, adding and deleting custom records

The custom records contained in a RGFA object can be retrieved using its
```custom_records``` method. If no argument is provided, all custom
records are returned. If a record type symbol is provided (e.g.
```g.custom_records(:X)```), records of that type will be returned.

Adding custom records to and removing them from a RGFA instance
is similar to any other line. So to delete a custom record, ```disconnect```
is called on the instance, or ```rm(custom_record_line)``` on the RGFA object.
To add a custom record line, the instance or its string representation
is added using ```<<``` on the RGFA, e.g. ```g << "X\ta\tb"```.

### Tags

As RGFA cannot know how many positional fields are present when parsing custom
records, an heuristic approach is followed, to identify tags.

A field resembles a tag if it starts with ```tn:d:``` where ```tn``` is a valid
tag name and ```d``` a valid tag datatype (see Tags chapter).

The fields are parsed from the last to the first. As soon as a field is found
which does not resemble a tag, all remaining fields are considered positionals
(even if another field parsed later resembles a tag).

This parsing heuristics has some consequences on validations. Tags with an
invalid tag name (such as starting with a number, or with a wrong number of
letters), or an invalid tag datatype (wrong letter, or wrong number of letters)
are considered positional fields. The only validation available for custom
records tags is thus the validation of the content of the tag, which must
be valid according to the datatype.

### Positional fields

The positional fields in a custom record are called ```:field1, :field2, ...```.
The user can iterate over the positional field names using the array obtained
by calling ```positional_fieldnames``` on the line.

Positional fields are allowed to contain any character (including non-printable
characters and spacing characters), except tabs and newlines (as they are
structural elements of the line).

Due to the parsing heuristics mentioned in the Tags section above, invalid
tags are sometimes wrongly taken as positional fields. Therefore,
the user shall validate the number of positional fields
(```line.positional_fieldnames.size```).

### Extensions

The support for custom fields is limited, as RGFA does not know which and
how many fields are there and how shall they be validated.
It is possible to create an extension of RGFA, which defines new record
types: this will allow to use these record types in a similar way
to the built-in types. However, extending the library requires sligthly
more advanced programming than just using the predefined record types.
In the chapter Extending RGFA these extensions are discussed and an
example is made.

### Summary of custom-record related API methods
```
RGFA#custom_records
RGFA#custom_records(record_type)
RGFA#rm(custom_record_line)
RGFA#<<(custom_record_string)
RGFA::Line::CustomRecord#disconnect
RGFA::Line::CustomRecord#positional_fieldnames
RGFA::Line::CustomRecord#field1/field2/...
```
