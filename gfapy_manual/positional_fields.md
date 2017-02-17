## Positional fields

Most lines in GFA have positional fields (Headers are an exception).
During parsing, if a line is encountered, which has too less or too many
positional fields, an exception will be thrown.
The correct number of positional fields is record type-specific.

Positional fields are recognized by its position in the line.
Each positional field has an implicit field name and datatype associated
with it.

### Field names

The field names are derived from the specification. Lower case versions
of the field names are used and spaces are subsituted with underscores.
In some cases, the field names were changed, as they represent keywords
in common programming languages (```from```, ```send```).

The following tables shows the field names used in gfapy, for each kind of line.
Headers have no positional fields. Comments and custom lines follow particular
rules, see the respective chapters.

#### GFA1 field names

| Record Type | Field 1            | Field 2             | Field 3          | Field 4         | Field 5       | Field 6       |
|-------------|--------------------|---------------------|------------------|-----------------|---------------|---------------|
| Segment     | ```name```         | ```sequence```      |                  |                 |               |               |
| Link        | ```from_segment``` | ```from_orient```   | ```to_segment``` | ```to_orient``` | ```overlap``` |               |
| Containment | ```from_segment``` | ```from_orient```   | ```to_segment``` | ```to_orient``` | ```pos```     | ```overlap``` |
| Path        | ```path_name```    | ```segment_names``` | ```overlaps```   |                 |               |               |

#### GFA2 field names

| Record Type | Field 1   | Field 2        | Field 3        | Field 4     | Field 5     | Field 6     | Field 7         | Field 8         |
|-------------|-----------|----------------|----------------|-------------|-------------|-------------|-----------------|-----------------|
| Segment     | ```sid``` | ```slen    ``` | ```sequence``` |             |             |             |                 |                 |
| Edge        | ```eid``` | ```sid1    ``` | ```sid2    ``` | ```beg1 ``` | ```end1 ``` | ```beg2 ``` | ```end2 ```     | ```alignment``` |
| Fragment    | ```sid``` | ```external``` | ```s_beg   ``` | ```s_end``` | ```f_beg``` | ```f_end``` | ```alignment``` |                 |
| Gap         | ```gid``` | ```sid1    ``` | ```d1      ``` | ```d2   ``` | ```sid2 ``` | ```disp ``` | ```var  ```     |                 |
| Set         | ```pid``` | ```items   ``` |                |             |             |             |                 |                 |
| Path        | ```pid``` | ```items   ``` |                |             |             |             |                 |                 |

### Datatypes

The datatype of each positional field is described in the specification and
cannot be changed (differently from tags).  Here is a short description of the
Python classes used to represent data for different datatypes. For some
complex cases, more details are found in the following chapters.

#### Placeholders

The positional fields in GFA can never be empty. However, there are some
fields with optional values. If a value is not specified, a placeholder
character is used instead (```*```). Such undefined values are represented
in gfapy by the gfapy.Placeholder class, which is described more in detail in the
Placeholders chapter.

#### Arrays

The ```items``` field in unordered and ordered groups
and the ```segment_names``` and ```overlaps``` fields in paths are
lists of objects and are represented by list instances.

```python
type(set.items) # => "list"
type(gfa2_path.items) # => "list"
type(gfa1_path.segment_names) # => "list"
type(gfa1_path.overlaps) # => "list"
```

#### Orientations

Orientations are represented by strings. The ```gfapy.invert``` method
applied to an orientation string returns the other orientation.
```python
gfapy.invert("+") # => "-"
gfapy.invert("-") # => "+"
```

#### Identifiers

The identifier of the line itself (available for S, P, E, G, U, O lines)
can always be accessed in gfapy using the ```name``` alias and is represented
in gfapy by a Symbol. If it is optional (E, G, U, O lines)
and not specified, it is represented by a Placeholder instance.
The fragment identifier is also a Symbol.

Identifiers which refer to other lines are also present in some line types
(L, C, E, G, U, O, F). These are never placeholders and in stand-alone lines
are represented by strings. In connected lines they are references to the Line
instances to which they refer to (see the References chapter).

#### Oriented identifiers

Oriented identifiers (e.g. ```segment_names``` in GFA1 paths)
are represented by elements of the class
```gfapy::OrientedLine```. The ```segment``` method of the oriented
segments returns the segment identifier (or segment reference in connected
path lines) and the ```orient``` method returns the orientation string.
The ```name``` method returns the string of the segment, even if this is
a reference to a segment.
A new oriented line can be created using the ```OL[line, orientation]``` method.

Calling ```invert``` returns an oriented segment, with inverted orientation.
To set the two attributes the methods ```segment=``` and ```orient=```
are available.

Examples:
```python
p = "P\tP1\ta+,b-\t*".to_rgfa_line
p.segment_names # => [OrientedLine(:a,:+),OrientedLine(:b,:-)]
p[0].segment # => :a
p[0].name # => :a
p[0].orient # => :+
p[0].invert # => OrientedLine(:a,:-)
p[0].orient = :-
p[0].segment = "S\tX\t*".to_rgfa_line
p[0] # => OrientedLine(gfapy::Line("S\tX\t*"), :-)
p[0].name # => :X
p[0] = OL[gfapy::Line("S\tY\t*"), :+]
```

#### Sequences

Sequences (S field sequence) are represented by strings in gfapy.
Depending on the GFA version, the alphabet definition is more or less
restrictive. The definitions are correctly applied by the validation methods.

The method ```rc``` is provided to compute the reverse complement of a nucleotidic
sequence. The extended IUPAC alphabet is understood by the method. Applied to
non nucleotidic sequences, the results will be meaningless:
```python
"gcat".rc # => "atgc"
"*".rc # => "*" (placeholder)
"yatc".rc # => "gatr" (wildcards)
"gCat".rc # => "atGc" (case remains)
"ctg".rc(rna: true) # => "cug"
```

#### Integers and positions

The C lines ```pos``` field and the G lines ```disp``` and ```var``` fields
are represented by integers. The ```var``` field is optional,
and thus can be also a placeholder. Positions are 0-based coordinates.

The position fields of GFA2 E lines (```beg1, beg2, end1, end2```) and
F lines (```s_beg, s_end, f_beg, f_end```) contain a dollar string as suffix
if the position is equal to the segment length. For more information,
see the Positions chapter.

#### Alignments

Alignments are always optional, ie they can be placeholders. If they are
specified they are CIGAR alignments or, only in GFA2, trace alignments.
For more details, see the Alignments chapter.

#### GFA1 datatypes

| Datatype                 | Record Type | Fields                          |
|--------------------------|-------------|---------------------------------|
| Identifier               | Segment     | ```name                     ``` |
|                          | Path        | ```path_name                ``` |
|                          | Link        | ```from_segment, to_segment ``` |
|                          | Containment | ```from_segment, to_segment ``` |
| [OrientedIdentifier]     | Path        | ```segment_names            ``` |
| Orientation              | Link        | ```from_orient, to_orient   ``` |
|                          | Containment | ```from_orient, to_orient   ``` |
| Sequence                 | Segment     | ```sequence                 ``` |
| Alignment                | Link        | ```overlap                  ``` |
|                          | Containment | ```overlap                  ``` |
| [Alignment]              | Path        | ```overlaps                 ``` |
| Position                 | Containment | ```pos                      ``` |

#### GFA2 datatypes

| Datatype                 | Record Type | Fields                           |
|--------------------------|-------------|----------------------------------|
| Itentifier               | Segment     | ```sid                       ``` |
|                          | Fragment    | ```sid                       ``` |
| OrientedIdentifier       | Edge        | ```sid1, sid2                ``` |
|                          | Gap         | ```sid1, sid2                ``` |
|                          | Fragment    | ```external                  ``` |
| OptionalIdentifier       | Edge        | ```eid                       ``` |
|                          | Gap         | ```gid                       ``` |
|                          | U Group     | ```oid                       ``` |
|                          | O Group     | ```uid                       ``` |
| [Identifier]             | U Group     | ```items                     ``` |
| [OrientedIdentifier]     | O Group     | ```items                     ``` |
| Sequence                 | Segment     | ```sequence                  ``` |
| Alignment                | Edge        | ```alignment                 ``` |
|                          | Fragment    | ```alignment                 ``` |
| Position                 | Edge        | ```beg1, end1, beg2, end2    ``` |
|                          | Fragment    | ```s_beg, s_end, f_beg, f_end``` |
| Integer                  | Gap         | ```disp, var                 ``` |

### Reading and writing positional fields

The ```positional_fieldnames``` method returns the list of the names
(as strings) of the positional fields of a line.
The positional fields can be read using a method on the gfapy line object, which
is called as the field name.  Setting the value is done with an equal sign
version of the field name method (e.g. segment.slen = 120).  In alternative,
the ```set(fieldname, value)``` and ```get(fieldname)``` methods can also be
used.

```python
s_gfa1.positional_fieldnames # => ["name", "sequence"]
s_gfa1.name # => "segment1"
s_gfa1.get("name") # => "segment3"
s_gfa1.name = "segment2"
s_gfa1.name # => "segment2"
s_gfa1.set("name", "segment3")
s_gfa1.name = "segment3"

```

When a field is read, the value is converted into an appropriate object.  The
string representation of a field can be read using the
```field_to_s(fieldname)``` method.

```python
link.from_segment # => gfapy.line.segment.GFA1("S\ts1\t*")
link.field_to_s(from_segment) # => ("s1")
```

When setting a non-string field, the user can specify the value of a tag
either as a Python non-string object, or as the string representation of the
value.

```python
c.pos = 1
c.pos = "1"
c.pos # => 1
c.field_to_s("pos") # => "1"
```

Note that setting the value of reference and backreferences-related
fields is generally not allowed, when a line instance is connected to a
gfapy object (see the References chapter).

```python
s = gfa.Line.from_string("L\ts1\t+\ts2\t-\t*")
s.from_segment = "s3"
gfa.add_line(s)
s.from_segment = "s4" # raises an exception
```

### Validation

The content of all positional fields must be a correctly formatted
string according to the rules given in the GFA specifications (or a Python object
whose string representation is a correctly formatted string).

Depending on the validation level, more or less checks are done automatically
(see the Validation chapter).  Not regarding which validation level is selected,
the user can trigger a manual validation using the
```validate_field(fieldname)``` method for a single field, or using
```validate```, which does a full validation on the whole line, including all
positional fields.

```python
line.validate_field("xx")
line.validate()
```

### Aliases

For some fields, aliases are defined, which can be used in all contexts
where the original field name is used (i.e. as parameter of a method, and
the same setter and getter methods defined for the original field name are
also defined for each alias, see below).

```python
gfa1_path.name == gfa1_path.path_name # True
edge.eid == edge.name # True
segment.sid == segment.name # True
containment.from_segment == containment.container # True

s = gfapy.Line.from_string("S\t1\t*")
s.sid # => "1"
s.name = "a"
s.sid # => "a"
```

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
container[_orient] for from[_|segment|orient]; contained[_orient]
for to[_segment|orient].

