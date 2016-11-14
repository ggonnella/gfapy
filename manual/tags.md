## Tags

Each record in GFA can contain tagged fields. These consist
in data for which a field name and a datatype are explicitely specified.
The format is ```NN:T:DATA``` where ``NN`` is a two-letter tag name,
```T``` is an one-letter datatype symbol and ```DATA``` is a string
representing the data according to the specified datatype.
Tag names must be unique for each line, i.e. each line may only
contain a tag once.

Some tags are explicitely defined in the specification (these are
named _predefined tags_ in RGFA), and the user or an application
can define its own custom tags.

### Tags and GFA version

According to the GFA1 specification, custom tags are lower case,
while predefined tags
are upper case (in both cases the second character in the name can be a number).
There is a number of predefined tags in the specification, different for
each kind of line.

The GFA2 specification is currently not as strict regarding tags:
anyone can use both upper and lower case tags, and no tags are
predefined except for VN and TS.

### Validation

Currently only lower case custom tags are allowed, without regard to the
GFA version. This may change in a future version of the library.

For all kind of tags, the name must follow the correct format, the
datatype must be one of the known datatypes and the data must be
a correctly formatted string for the specified datatype.
For predefined tags, RGFA also checks that the datatype given
in the specification is used.

Depending on the validation level, more or less checks are done
automatically (see validation chapter).
Not regarding which validation level is selected, the user
can trigger a manual validation using the ```validate_field(fieldname)```
method for a single tag, or using ```validate!```,
which does a full validation on the
whole line, including all tags.

### Custom tags in RGFATools

Both versions of GFA allow to define custom tags.
E.g. RGFATools defines custom tags to store information needed
for its graph operations. Custom tags may of course collide with
custom tags defined by other tools or users. For this reason, the methods
in RGFATools allow to change the tag name for the custom tags it uses.

### Datatypes

The following table summarizes the datatypes available for tags:

| Symbol | Datatype      | Example                 | Ruby class         |
|--------|---------------|-------------------------|--------------------|
| Z      | string        | This is a string        | String             |
| i      | integer       | -12                     | Fixnum             |
| f      | float         | 1.2E-5                  | Float              |
| A      | char          | X                       | String             |
| J      | JSON          | [1,{"k1":1,"k2":2},"a"] | Array/Hash         |
| B      | numeric array | f,1.2,13E-2,0           | RGFA::NumericArray |
| H      | byte array    | FFAA01                  | RGFA::ByteArray    |
|--------|---------------|-------------------------|--------------------|

### Reading and writing tags

Tags can be read using a method on the RGFA line object, which is called
as the datatype (e.g. line.xx). A banged version of the method raises
an error if the tag was not available (e.g. line.LN!), which the normal
method returns ```nil``` in this case. Setting the value is done with an
equal sign version of the tag name method (e.g. line.TS = 120).
In alternative, the ```set(fieldname, value)```, ```get(fieldname)```
and ```get!(fieldname)``` methods can also be used.
To remove a tag from a line, use the ```delete(fieldname)``` method,
or set its value to ```nil```.

The ```RGFA::Line#tagnames``` method, returns
the list of the names (as symbols) of all defined tags for a line.
Alternatively, to test if a line contains a tag, it is possible to use the
not-banged get method (e.g. line.VN), as this returns nil if the tag is not
defined, and a non-nil value if the tag is defined.

When a tag is read, the value is converted into an appropriate
object (see Ruby classes in the datatype table above). When setting a value,
the user can specify the value of a tag either as a Ruby object, or as the
string representation of the value.

The string representation of a tag can be read using the
```field_to_s(fieldname)``` method. The default is to only output
the content of the field. By setting ``tag: true```, the entire
tag is output (name, datatype, content, separated by colons).
An exception is raised if the field does not exist.

### Datatype of custom tags

The datatype of an existing custom field
 (but not of predefined fields) can
be changed using the ```set_datatype(fieldname, datatype)``` method.
The current datatype specification can be read using
```get_datatype(fieldname)```. Thereby the fieldname and datatype
arguments are Ruby symbols.

If a new custom tag is specified, RGFA selects the correct datatype for it:
i/f for numeric values, J/B for arrays, J for hashes and
Z for strings and symbols.
If the user wants to specify a different datatype, he may do so by setting
it with ```set_datatype``` (this can be done also before assigning a value,
which is necessary if full validation is active).

### Arrays of numerical values

B and H tags represent array with particular constraints (e.g. they can
only contain numeric values, and in some cases the values must be
in predefined ranges).
In order to represent them correctly and allow for validation, Ruby
classes have been defined for both kind of tags: RGFA::ByteArray for H
and RGFA::NumericArray for B fields.

Both are subclasses of Array.
Object of the two classes can be created by converting the string
representation (using #to_byte_array and #to_numeric_array). The same
two methods can be applied also to existing Array instances
containing numerical values.

Instances of the classes behave as normal arrays, except that they
provide a #validate! method, which checks the constraints, and that
their #to_s method computes the GFA string representation of the
field value.

For numeric values, the ```#compute_subtype``` method allows to
compute the subtype which will be used for the string representation.
Unsigned subtypes are used if all values are positive.
The smallest possible subtype range is selected.
The subtype may change when the range of the elements changes.

### Special cases: custom records, headers, comments and virtual lines.

GFA2 allows custom records, introduced by record type symbols other than
the predefined ones. RGFA uses a pragmatical approach for identifying tags
in custom records,
and tries to interpret the rightmost fields as tags, until the first
field from the right raises an error; all remaining fields are treated as
positional fields.

For easier access, the entire header of the GFA is summarized in a single
line instance. Different GFA header lines can contain the same tag (this was a
discussed topic, it is not forbidden by the current specifications, but this
may change). A class (RGFA::FieldArray) has been defined to handle
this special case (see Header chapter for details).

Comment lines are represented by a subclass of the same class (RGFA::Line) as
the records. However, they cannot contain tags: the entire line is taken as
content of the comment.

Virtual RGFA::Line instances (e.g. Segment instances automatically created
because of not yet resolved references found in edges) cannot be modified
by the user, and tags cannot be specified for them. This includes
all instances of the RGFA::Line::Unknown class.

### Summary of tags-related API methods

```
RGFA::Line#tn/tn!/tn= # tn = tag name
RGFA::Line#get/set
RGFA::Line#delete
RGFA::Line#get_datatype/set_datatype
RGFA::Line#validate_field/validate!
String#to_byte_array/to_numeric_array
Array#to_byte_array/to_numeric_array
RGFA::NumericArray/RGFA::ByteArray#to_s
RGFA::NumericArray/RGFA::ByteArray#validate!
RGFA::NumericArray#compute_subtype
```
