## Validation

Different validation levels are available. They represent different compromises
between speed and warrant of validity.  The validation level can be specified
when the gfapy.Gfa object is created, using the ```vlevel``` parameter of
the constructor and of the ```gfapy.Gfa.from_file()``` method.
Four levels of validation are defined
(0 = no validation, 1 = validation by reading, 2 = validation by reading and
writing, 3 = continuous validation). The default validation level value is 1.

### Manual validation

Independently from the validation level choosen, the user can
always check the value of a field calling ```validate_field(fieldname)```
on the line instance. If no exeption is raised, the field content
is valid.

To check if the entire content of the line is valid, the user can call
```validate``` on the line instance. This will check all fields and perform
cross-field validations, such as comparing the length of the sequence of a GFA1
segment, to the value of the LN tag (if present).

It is also possible to validate the structure of the GFA, for example
to check if there are unresolved references to lines. To do this,
use the ```validate()``` method of the ```gfapy.Gfa``` class.

### No validations

If the validation is set to 0, gfapy will try to accept any input
and never raise an exception. This is not always possible, and in
some cases, an exception will still be raised, if the data is invalid.

### Validation when reading

If the validation level is set to 1 or higher, basic validations
will be performed, such as checking the number of positional fields,
the presence of duplicated tags, the tag datatype of predefined tags.
Additionally, all tags will be validated, either
during parsing or on first access.
Record-type cross-field validations will also be performed.

In other words, a validation of 1 means that gfapy guarantees (as good as
it can) that the GFA content read from a file is valid, and will raise an
exception on accessing the data if not.

The user is supposed to run ```validate_field(fieldname)``` when changing
a field content to something which can be potentially invalid, or
```validate()``` if potentially cross-field validations could fail.

### Validation when writing

Setting the level to 2 will perform all validations described above,
plus validate the fields content when their value is written to string.

In other words, a validation of 2 means that gfapy guarantee (as good as
it can) that the GFA content read from a file and written to a file is valid
and will raise an exception on accessing the data or writing to file if not.

### Continuous validation

If the validation level is set to 3, all validations for lower levels
described above are run, plus a validation of fields contents each
time a setter method is used.

A validation of 3 means that gfapy guarantees (as good as it can)
that the GFA content is always valid.
