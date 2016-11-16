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

The custom records contained in a RGFA object can be retrieved using the
```RGFA#custom_records``` method. If no argument is provided, all custom
records are returned. If a record type symbol is provided (e.g.
```g#custom_records(:X)```), records of that type will be returned.

To delete a custom record, retrieve its instance and either call
```RGFA::Line::CustomRecord#disconnect!``` or ```RGFA#rm(custom_record_line)```.

To add a new custom record line, you may add the GFA string defining the
record using ```RGFA#<<(string)```, e.g. ```g << "X\ta\tb"```.

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
by calling ```RGFA::Line::CustomRecord#positional_fieldnames```.

Due to the parsing heuristics mentioned in the Tags section above, invalid
tags are sometimes wrongly taken as positional fields. Therefore,
the user shall validate the number of positional fields
(using ```RGFA::Line::CustomRecord#positional_fieldnames.size```)

Positional fields are allowed to contain any character (including non-printable
characters and spacing characters), except tabs and newlines (as they are
structural elements of the line).
