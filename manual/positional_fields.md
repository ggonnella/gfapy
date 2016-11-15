## Positional fields

Most lines in GFA have positional fields (Headers are an exception).
During parsing, if a line is encountered, which has too less or too many
positional fields, an exception will be thrown.
The correct number of positional fields is record type-specific.

Positional fields are recognized by its position in the line.
Each positional field has an implicit field name and datatype associated
with it. The datatype of a positional field cannot be changed.

### Field names

The field names are derived from the specification. Lower case versions
of the field names are used and spaces are subsituted with underscores.

The following tables shows the field names used in RGFA, for each kind of line.
Headers have no positional fields. Comments and custom lines follow particular
rules, see the respective chapters.

#### GFA1 field names

| Record Type     | Field 1   | Field 2       | Field 3  | Field 4    | Field 5 | Field 6 | Field 7 | Field 8   | Field 9   |
|-----------------|-----------|---------------|----------|------------|---------|---------|---------|-----------|-----------|
| Segment         | name      | sequence      |          |            |         |         |         |           |           |
| Link            | from      | from_orient   | to       | to_orient  | overlap |         |         |           |           |
| Containment     | from      | from_orient   | to       | to_orient  | pos     | overlap |         |           |           |
| Path            | path_name | segment_names | overlaps |            |         |         |         |           |           |
|-----------------|-----------|---------------|----------|------------|---------|---------|---------|-----------|-----------|

#### GFA2 field names

| Record Type     | Field 1   | Field 2       | Field 3  | Field 4    | Field 5 | Field 6 | Field 7 | Field 8   | Field 9   |
|-----------------|-----------|---------------|----------|------------|---------|---------|---------|-----------|-----------|
| Segment         | sid       | slen          | sequence |            |         |         |         |           |           |
| Edge            | eid       | sid1          | or2      | sid2       | beg1    | end1    | beg2    | end2      | alignment |
| Fragment        | sid       | or            | external | s_beg      | s_end   | f_beg   | f_end   | alignment |           |
| Gap             | gid       | sid1          | d1       | d2         | sid2    | disp    | var     |           |           |
| Unordered group | pid       | items         |          |            |         |         |         |           |           |
| Ordered group   | pid       | items         |          |            |         |         |         |           |           |
|-----------------|-----------|---------------|----------|------------|---------|---------|---------|-----------|-----------|

### Reading and writing positional fields

The ```RGFA::Line#positional_fieldnames``` method returns the list of the names
(as symbols) of the positional fields of a line.

The positional fields can be read using a method on the RGFA line object, which
is called as the field name.  Setting the value is done with an equal sign
version of the field name method (e.g. segment.slen = 120).  In alternative,
the ```set(fieldname, value)``` and ```get(fieldname)``` methods can also be
used.

When a field is read, the value is converted into an appropriate object.  The
string representation of a field can be read using the
```field_to_s(fieldname)``` method.

When setting a value, the user can specify the value of a tag either as a Ruby
object, or as the string representation of the value.

### Validation

The content of all positional fields must be a correctly formatted
string according to the rules given in the GFA specifications (or a Ruby object
whose string representation is a correctly formatted string).

Depending on the validation level, more or less checks are done automatically
(see validation chapter).  Not regarding which validation level is selected,
the user can trigger a manual validation using the
```validate_field(fieldname)``` method for a single field, or using
```validate!```, which does a full validation on the whole line, including all
positional fields.

### Aliases

For some fields, aliases are defined, which can be used in all contexts
where the original field name is used (i.e. as parameter of a method, and
the same setter and getter methods defined for the original field name are
also defined for each alias, see below).

#### Name

Different record types have an identifier field:
segments (name in GFA1, sid in GFA2), paths (path_name), edge (eid),
fragment (sid), gap (gid), groups (pid).

All these fields are aliased to ```name```. This allows the user
for example to set the identifier of a line using the
```name=(value)``` method using the same syntax for different record
types (segments, edges, paths, fragments, gaps and groups).

#### Version-specific field names

For segments the GFA1 name and the GFA2 sid are equivalent
fields. For this reason an alias ```sid``` is defined for GFA1 segments
and ```name``` for GFA2 segments.

#### Crypical field names

The definition of from and to for containments is somewhat cryptical.
Therefore following aliases have been defined for containments:
container[_orient] for from[_orient]; contained[_orient] for to[_orient]

### Summary of positional fields-related API methods

```
RGFA::Line#<fieldname>/<fieldname>=
RGFA::Line#get/set
RGFA::Line#validate_field/validate!
```
