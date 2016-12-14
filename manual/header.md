## The Header

GFA files may contain one or multiple header lines (record type: H).  These
lines may be present in any part of the file, not necessarily at the beginning.

Although the header may consist of multiple lines, its content refers to the
whole file. Therefore in RGFA the header is accessed using a single line
instance (accessible by the ```header``` method).  Header lines contain only
tags. If not header line is present in the GFA, then the header line object
will be empty (i.e. contain no tags).

Header lines cannot be connected to the RGFA as other lines (i.e. calling
```connect``` on them raises an exception). Instead they are merged to the
existing header, when the ```add_line(line)``` method is called on the RGFA.

### Multiple definitions of the predefined header tags

For the predefined tags (```VN``` and ```TS```), the presence of multiple
values in different lines is an error, unless the value is the same in each
instance (in which case the repeated definitions are ignored).

```
H VN:Z:1.0
# other lines
# ...
# the following raises an exception:
H VN:Z:2.0
```

### Multiple definitions of custom header tags

If the tags are present only once in the header in its entirety, the access to
the tags is the same as for any other line (see Tags chapter).

However, the specification does not forbid custom tags to be defined with
different values in different header lines (which we name
"multi-definition tags"). This particular case is handled in the next
sections.

### Reading multi-definitions tags

Reading, validating and setting the datatype of multi-definition tags is
done using the same methods as for all other lines (see Tags chapter).
However, if a tag is defined multiple times on multiple H lines, reading
the tag will return an array of the values on the lines. This array is an
instance of the subclass ```RGFA::FieldArray``` of Array.

```
H xx:i:1
H xx:i:2
H xx:i:3
# => gfa.header.xx value is RGFA::FieldArray[1,2,3]
```

### Setting a tag

Calling set, if a tag was already defined, overwrites its value.
For this reason, another method is defined, for supporting multi-definition
tags: ```add```. When ```add(tagname, value)``` is called on the RGFA header,
if the tag does not exist, add will be a synonymous of set and simply create
it.  If it exists, it creates a field array (if a single value was present)
or adds the new value to the existing field array (if multiple values were
present).

```ruby
# header.xx is not set
gfa.header.add(:xx, 1)
# header.xx is 1
gfa.header.add(:xx, 2)
# header.xx is a field array [1,2]
```

### Modifying field array values

Field arrays can be modified directly (e.g. adding new values or removing some
values). However, if this is done, some additional work is sometimes needed.

First, if values are added to the array, or its values
are modified, the user is responsible to check that the array values
remain compatible with the datatype of the tag (which can be checked
by calling ```validate_field(tagname)``` on the header).

```ruby
gfa.header.xx # => RGFAFieldArray[1,2,3]
gfa.header.xx << 4
gfa.header.xx << 5
gfa.validate_field(:xx)
```

Second, if the field array is modified using array methods (such as ```map```)
which return an Array class instance, this must be transformed back into a field
array calling ```to_rgfa_field_array(datatype)``` method; thereby datatype
can be set to the value returned by calling ```get_datatype(tagname)```
on the header.

```ruby
gfa.header.map = gfa.header.map {|elem| elem + 1}.
                   to_rgfa_field_array(gfa.header.get_datatype(:xx))
```

### String representation of the header

Note that when converting the header line to string, a single-line string is
returned, eventually with multiple instances of the tag (in which case it is
not standard-compliant).  Similarly when calling #field_to_s on a field array
tag, the output string will contain the instances of the tag, separated by
tabs. However, when the RGFA is output to file or string, the header is
splitted into multiple H lines with single tags, so that standard-compliant GFA
is output. These can be retrieved using the ```headers``` method on the RGFA:

```ruby
gfa.header.to_s # H VN:Z:1.0 xx:i:1 xx:i:2 (compact, but invalid GFA)
gfa.header.field_to_s(:xx) # => xx:i:1 xx:i:2
gfa.headers # => [] of three Header instances, with a single tag each
gfa.to_s # => (valid GFA)
         # H VN:Z:1.0
         # H xx:i:1
         # H xx:i:2
```
