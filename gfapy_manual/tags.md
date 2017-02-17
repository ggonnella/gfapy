## Tags

Each record in GFA can contain tags. Tags are fields which consist in a tag
name, a datatype and data.  The format is ```NN:T:DATA``` where ``NN`` is a
two-letter tag name, ```T``` is an one-letter datatype string and ```DATA``` is
a string representing the data according to the specified datatype.  Tag names
must be unique for each line, i.e. each line may only contain a tag once.

```
# Examples of GFA tags of different datatypes:
aa:i:-12
bb:f:1.23
cc:Z:this is a string
dd:A:X
ee:B:c,12,3,2
ff:H:122FA0
gg:J:["A","B"]
```

### Custom tags

Some tags are explicitely defined in the specification (these are named
_predefined tags_ in gfapy), and the user or an application can define its own
custom tags.

Custom tags are user or program specific and may of course collide with the
tags used by other users or programs. For this reasons, if you write scripts
which employ custom tags, you should always check that the values are
of the correct datatype and plausible.

```python
if line.get_datatype(:xx) != :i
  raise "I expected the tag xx to contain an integer!"
end
myvalue = line.xx
if (myvalue > 120) or (myvalue % 2 == 1)
  raise "The value in the xx tag is not an even value <= 120"
end
# ... do something with myvalue
```

Also it is good practice to allow the user of the script to change the name of
the custom tags. For example, gfapyTools employs the +or+ custom tag to track
the original segment from which a segment in the final graph is derived. All
methods which read or write the +or+ tag allow to specify an alternative tag
name to use instead of +or+, for the case that this name collides with the
custom tag of another program.

```python
# E.g. a method which does something with myvalue, usually stored in tag xx
# allows the user to specify an alternative name for the tag
# @param mytag [Symbol] <i>(defaults to: +:xx+)</i> tag where value is stored
def mymethod(line, mytag: :xx)
  myvalue = line.xx
  # .... do something with myvalue
end
```

### Tag names in GFA1

According to the GFA1 specification, custom tags are lower case, while
predefined tags are upper case (in both cases the second character in the name
can be a number).  There is a number of predefined tags in the specification,
different for each kind of line.

```
VN:Z:1.0 # VN is upcase => predefined tag
z5:Z:1.0 # z5 first char is downcase => custom tag

# not forbidden, but not reccomended:
zZ:Z:1.0 # => mixed case, first char downcase => custom tag
Zz:Z:1.0 # => mixed case, first char upcase => custom tag
vn:Z:1.0 # => same name as predefined tag, but downcase => custom tag
```

Besides the tags described in the specification, in GFA1 headers, the TS tag is
allowed, in order to simplify the translation of GFA2 files.

### Tag names in GFA2

The GFA2 specification is currently not as strict regarding tags: anyone can
use both upper and lower case tags, and no tags are predefined except for VN
and TS.

However, gfapy follows the same conventions as for GFA1: i.e. it allows the tags
specified as predefined tags in GFA1 to be used also in GFA2. No other upper
case tag is allowed in GFA2.

### Datatypes

The following table summarizes the datatypes available for tags:

| Symbol | Datatype      | Example                 | Python class         |
|--------|---------------|-------------------------|--------------------|
| Z      | string        | This is a string        | String             |
| i      | integer       | -12                     | Fixnum             |
| f      | float         | 1.2E-5                  | Float              |
| A      | char          | X                       | String             |
| J      | JSON          | [1,{"k1":1,"k2":2},"a"] | Array/Hash         |
| B      | numeric array | f,1.2,13E-2,0           | gfapy::NumericArray |
| H      | byte array    | FFAA01                  | gfapy::ByteArray    |

### Validation

The tag name is validated according the the rules described above: except
for the upper case tags indicated in the GFA1 specification, and the TS header
tag, all other tags must contain at least one lower case letter.

```
VN # => in header: allowed, elsewhere: error
TS # => allowed in headers and GFA2 Edges
KC # => allowed in links, containments, GFA1/GFA2 segments
xx # => custom tag, always allowed
xxx # => error: name is too long
x # => error: name is too short
11 # => error: at least one letter must be present
```

The datatype must be one of the datatypes specified above.  For predefined
tags, gfapy also checks that the datatype given in the specification is used.

```
xx:X # => error: datatype X is unknown
VN:i # => error: VN must be of type Z
```

The data must be a correctly formatted string for the specified datatype or a
Python object whose string representation is a correctly formatted string.

```python
# current value: xx:i:2
line.xx = 1   # OK
line.xx = "1" # OK, value is set to 1
line.xx = "A" # error
```

Depending on the validation level, more or less checks are done automatically
(see validation chapter). Per default - validation level (1) - validation
is performed only during parsing or accessing values the first time, therefore
the user must perform a manual validation if he changes values to something
which is not guaranteed to be correct. To trigger a manual validation, the
user can call the method ```validate_field(fieldname)``` to validate a
single tag, or ```validate``` to validate the whole line, including all
tags.

```python
line.xx = "A"
line.validate_field(:xx) # validates xx
# or, to validate the whole line, including tags:
line.validate
```

### Reading and writing tags

Tags can be read using a method on the gfapy line object, which is called as the
tag (e.g. line.xx). A banged version of the method raises an error if the
tag was not available (e.g. line.LN!), which the normal method returns
```nil``` in this case. Setting the value is done with an equal sign version of
the tag name method (e.g. line.TS = 120).  In alternative, the
```set(fieldname, value)```, ```get(fieldname)``` and ```get!(fieldname)```
methods can also be used.  To remove a tag from a line, use the
```delete(fieldname)``` method, or set its value to ```nil```.

```python
# line is "H xx:i:12"
line.xx  # => 1
line.xy  # => nil
line.xx! # => 1
line.xy! # => error: xy is not defined
line.get(:xx)  # => 1
line.get!(:xy) # => error, xy is not defined
line.xx = 2    # => value of xx is changed to 2
line.xx = "a"  # => error: not compatible with existing type (i)
line.xy = 2    # => xy is created and set to 2, type is auto-set to i
line.set(:xy, 2) # => sets xy to 2
line.delete(:xy) # => tag is eliminated
line.xx = nil    # => tag is eliminated
```

The ```gfapy::Line#tagnames``` method, returns the list of the names (as
strings) of all defined tags for a line.  Alternatively, to test if a line
contains a tag, it is possible to use the not-banged get method (e.g. line.VN),
as this returns nil if the tag is not defined, and a non-nil value if the tag
is defined.

```python
puts "Line contains the following tags:"
line.tagnames.each do |tagname|
  puts tagname
end
if line.VN
  # do something with line.VN value
end
```

When a tag is read, the value is converted into an appropriate object (see Python
classes in the datatype table above). When setting a value, the user can
specify the value of a tag either as a Python object, or as the string
representation of the value.

```python
# line is: H xx:i:1 xy:Z:TEXT xz:J:["a","b"]
line.xx # => 1 (Integer)
line.xy # => "TEXT" (String)
line.xz # => ["a", "b"] (Array)
```

The string representation of a tag can be read using the
```field_to_s(fieldname)``` method. The default is to only output the content
of the field. By setting ``tag: true```, the entire tag is output (name,
datatype, content, separated by colons).  An exception is raised if the field
does not exist.

```python
# line is: H xx:i:1
line.xx # => 1 (Integer)
line.field_to_s(:xx) # => "1" (String)
line.field_to_s(:xx, tag: true) # => "xx:i:1"
```

### Datatype of custom tags

The datatype of an existing custom field (but not of predefined fields) can be
changed using the ```set_datatype(fieldname, datatype)``` method.  The current
datatype specification can be read using ```get_datatype(fieldname)```. Thereby
the fieldname and datatype arguments are Python strings.

```python
# line is: H xx:i:1
line.get_datatype(:xx) # => :i
line.set_datatype(:xx, :Z)
```

If a new custom tag is specified, gfapy selects the correct datatype for it: i/f
for numeric values, J/B for arrays, J for hashes and Z for strings and strings.
If the user wants to specify a different datatype, he may do so by setting it
with ```set_datatype``` (this can be done also before assigning a value, which
is necessary if full validation is active).

```python
# line has not tags
line.xx = "1" # => "xx:Z:1" created
line.xx # => "1"
line.set_datatype(:xy, :i)
line.xy = "1" # => "xy:i:1" created
line.xy # => 1
```

### Arrays of numerical values

```B``` and ```H``` tags represent array with particular constraints (e.g. they
can only contain numeric values, and in some cases the values must be in
predefined ranges).  In order to represent them correctly and allow for
validation, Python classes have been defined for both kind of tags:
```gfapy::ByteArray``` for ```H``` and ```RGFA::NumericArray``` for ```B```
fields.

Both are subclasses of Array.  Object of the two classes can be created by
converting the string representation (using ```to_byte_array``` and
```to_numeric_array```). The same two methods can be applied also to existing
Array instances containing numerical values.

```python
# create a byte array instance
[12,3,14].to_byte_array
"A012FF".to_byte_array
# create a numeric array instance
"c,12,3,14".to_numeric_array
[12,3,14].to_numeric_array
```

Instances of the classes behave as normal arrays, except that they provide a
#validate method, which checks the constraints, and that their #to_s method
computes the GFA string representation of the field value.

```python
[12,1,"1x"].to_byte_array.validate # => error: 1x is not a valid value
[12,3,14].to_numeric_array.to_s # => "c,12,3,14"
```

For numeric values, the ```compute_subtype``` method allows to compute the
subtype which will be used for the string representation.  Unsigned subtypes
are used if all values are positive.  The smallest possible subtype range is
selected.  The subtype may change when the range of the elements changes.

```python
[12,13,14].to_numeric_value.compute_subtype # => "C"
```

### Special cases: custom records, headers, comments and virtual lines.

GFA2 allows custom records, introduced by record type strings other than the
predefined ones. gfapy uses a pragmatical approach for identifying tags in
custom records, and tries to interpret the rightmost fields as tags, until the
first field from the right raises an error; all remaining fields are treated as
positional fields.

```
X a b c xx:i:12 # => xx is tag, a, b, c are positional fields
Y a b xx:i:12 c # => all positional fields, as c is not a valid tag
```

For easier access, the entire header of the GFA is summarized in a single line
instance. Different GFA header lines can contain the same tag (this was a
discussed topic, it is not forbidden by the current specifications, but this
may change). A class (```gfapy::FieldArray```) has been defined to handle this
special case (see Header chapter for details).

Comment lines are represented by a subclass of the same class (```gfapy::Line```)
as the records. However, they cannot contain tags: the entire line is taken as
content of the comment.

```
# this is not a tag: xx:i:1 # => not a tag, xx:i:1 is part of the string content
```

Virtual ```gfapy::Line``` instances (e.g. Segment instances automatically created
because of not yet resolved references found in edges) cannot be modified by
the user, and tags cannot be specified for them. This includes all instances of
the ```gfapy::Line::Unknown``` class.
