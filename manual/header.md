## The header

GFA files may contain one or multiple header lines (record type: H).  These
lines may be present in any part of the file, not necessarily at the beginning.

Although the header may consist of multiple lines, its content refers to the
whole file. Therefore in RGFA the header is accessed using a single line
instance (accessible by the RGFA#header method).  Header lines contain only
tags. If not header line is present in the GFA, then the header line object
will be empty (i.e. contain no tags).

Header lines cannot be connected to the RGFA (i.e. calling RGFA::Line#connect
raises an exception). Instead they are merged to the existing header of the
RGFA object, using the ```RGFA#<<(line)``` method.

### Accessing the header tags

The specification does not explicitely forbid to have the same tag on different
lines. However, some users prefer to have unique tags in the whole header.
Therefore there are two flavours of headers: headers for which the same tag
cannot be present even in different lines ("unique tags" headers), and headers
for which this is possible ("duplicated tags" headers).

For unique tags headers, the access to the tags is the same as for any other
line (see Tags chapter).  For duplicated tags headers, see the next section.

### Duplicated tags headers

Tags of duplicated tags headers are read, validated and their datatypes
set, using the same methods as for all other lines (see Tags chapter).
However, if a tag is defined multiple times on multiple H lines, reading
the tag will return an array of the values on the lines.  This array is an
instance of the subclass ```RGFA::FieldArray``` of Array.

The field array of a tag can be modified directly (e.g. adding new values
or removing some values).
If you edit the array, make sure that all elements of the array are compatible
with the datatype of the tag (calling validate_field will check this condition).
Note that some array methods will return an object of the class Array.
These must be transformed back to a field array using the
```Array#to_rgfa_field_array(datatype)``` method; thereby you will usually
use the datatype returned by ```RGFA::Line#get_datatype(tagname)```.

Another difference from unique tags headers is how to set values. Calling set,
if a tag was already defined, overwrites its value. Therefore, adding a new tag
to a duplicated tags headers can be done using the
```RGFA::Line::Header#add(fieldname, value)``` method.  If the tag does not
exist, add will be a synonymous of set and simply create it.  If it exists, it
creates a field array (if a single value was present) or adds the new value to
the existing field array (if multiple values were present).

Note that when calling the #to_s method on the header line directly, a single
non GFA-standard string is output, eventually with multiple instances of the
tag. Similarly when calling #field_to_s on a field array tag, the output
string will contain the instances of the tag, separated by tabs.
However, when the graph is output to string (using RGFA#to_s), the header
is split into multiple H lines with single tags, so that standard-compliant GFA
is output.

### Summary of headers-related API methods

```
RGFA#header
RGFA::Line::Header#add
RGFA::FieldArray#(array methods)
Array#to_rgfa_array(tagname)
```
