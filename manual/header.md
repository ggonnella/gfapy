## The Header

GFA files may contain one or multiple header lines (record type: "H").  These
lines may be present in any part of the file, not necessarily at the beginning.

Although the header may consist of multiple lines, its content refers to the
whole file. Therefore in gfapy the header is accessed using a single line
instance (accessible by the ```header``` method).  Header lines contain only
tags. If not header line is present in the Gfa, then the header line object
will be empty (i.e. contain no tags).

Note that header lines cannot be connected to the gfapy as other lines
(i.e. calling ```connect``` on them raises an exception). Instead they
must be merged to the existing Gfa header, using
```add_line(line)``` on the gfa instance.

```python
gfapy.Line.from_string("H\tnn:f:1.0").connect(gfa) # exception
gfa.add_line("H\tnn:f:1.0") # this works!
gfa.header.nn # => 1.0
```

### Multiple definitions of the predefined header tags

For the predefined tags (```VN``` and ```TS```), the presence of multiple
values in different lines is an error, unless the value is the same in each
instance (in which case the repeated definitions are ignored).

```python
gfa.add_line("H\tVN:Z:1.0")
gfa.add_line("H\tVN:Z:1.0") # ignored
gfa.add_line("H\tVN:Z:2.0") # exception!
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
the tag will return a list of the values on the lines. This array is an
instance of the subclass ```gfapy.FieldArray``` of list.

```python
gfa.add_line("H\txx:i:1")
gfa.add_line("H\txx:i:2")
gfa.add_line("H\txx:i:3")
gfa.header.xx # => gfapy.FieldArray("i", [1,2,3])
```

### Setting tags

There are two possibilities to set a tag for the header. The first is the
normal tag interface (using ```set``` or the tag name property). The second
is to use ```add```. The latter supports multi-definition tags, i.e. it
adds the value to the previous ones (if any), instead of overwriting them.

```python
gfa.header.xx # => None
gfa.header.add("xx", 1)
gfa.header.xx # => 1
gfa.header.add("xx", 2)
gfa.header.xx # => gfapy.FieldArray("i", [1,2])
gfa.header.set("xx", 3)
gfa.header.xx # => 3
```

### Modifying field array values

Field arrays can be modified directly (e.g. adding new values or removing some
values). After modification, the user may check if the array values
remain compatible with the datatype of the tag using the ```validate_field```
method.

```python
gfa.header.xx # => gfapy.FieldArray([1,2,3])
gfa.header.validate_field("xx") # => True
gfa.header.xx.append("X")
gfa.header.validate_field("xx") # => False
```

If the field array is modified using array methods which return a list or data
of any other type, a field array must be constructed, setting its
datatype to the value returned by calling ```get_datatype(tagname)```
on the header.

```python
gfa.header.xx # => gfapy.FieldArray([1,2,3])
gfa.header.xx = gfa.FieldArray(gfa.header.get_datatype("xx"),
                               map(lambda x: x+1, gfa.header.xx))
gfa.header.xx # => gfapy.FieldArray([2,3,4])
```

### String representation of the header

For consinstency with other line types, the string representation of
the header is a single-line string, eventually non standard-compliant,
if it contains multiple instances of the tag.
(and when calling ```field_to_s(tag)``` for a tag present multiple
times, the output string will contain the instances of the tag, separated by
tabs).

However, when the gfapy is output to file or string, the header is
splitted into multiple H lines with single tags, so that standard-compliant GFA
is output. The splitted header can be retrieved using the ```headers``` method
on the Gfa instance.

```python
gfa.header.field_to_s("xx") # => "xx:i:1\txx:i:2"
str(gfa.header) # => "H\tVN:Z:1.0\txx:i:1\txx:i:2"
[str(h) for h in gfa.headers] # => ["H\tVN:Z:1.0", "H\txx:i:1", "H\txx:i:2"]
str(gfa) # => """
              H VN:Z:1.0
              H xx:i:1
              H xx:i:2
              """
```
