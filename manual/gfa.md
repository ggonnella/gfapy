## The Gfa object

The main class of the library is ```gfapy.Gfa```. An object of this class
represents the content of a GFA file.
An instance can be created directly (using the ```gfapy.Gfa()``` constructor)
or the method ```gfapy.Gfa.from_file(filename)``` can be used to parse a
GFA file and create an instance from it.

The ```str()``` method converts the Gfa instance into its textual
representation. Writing all information to a GFA file can be done directly
using the ```to_file(filename)``` method.

```python
g1 = gfapy.Gfa()
g1.append("H\tVN:i:1.0")
g1.append("S\ta\t*")
g1.to_file("my.gfa")
g2 = gfapy.from_file("my.gfa")
g2 == g1 # => True
str(g1) # => "H\tVN:i:1.0\nS\ta\t*"
```

### Retrieving the lines

For many line times, iterating between all lines of the type can be done
using a property which is named after the record type, in plural
(```segments```, ```paths```, ```edges```, ```links```, ```containments```,
```groups```, ```fragments```, ```comments```, ```custom_lines```).
The access to the header is done using a single line, which is retrieved using
the ```header``` property.

Some lines use identifiers: segments, gaps, edges, paths and sets. Given an
identifier, the line can be retrieved using the ```line(id)```
method. Note that identifier are represented in Gfapy by Python strings.

The list of all identifier can be retrieved using the ```names``` property;
for the identifiers of a single line type, use ```segment_names```,
 ```edges_names```, ```gap_names```, ```path_names``` and ```set_names```.
The identifiers of external sequences in fragments are not part of the
same namespace and can be retrieved using the ```external_names``` property.

### Segments

Segment lines are available in both GFA1 and GFA2. They
they represent the pieces of molecules, whose relations to other
segments are coded by other line types.

In GFA1 a segment contains a segment name and a sequence (and, eventually,
optional tags). In GFA2 the syntax is slightly different,
as the segment contain an additional segment length field, which
represent an eventually approximate length, which can be taken as a
drawing indication for segments in graphical programs.

### Relationships between segments

Segments are put in relation to each other by edges lines (E lines in GFA2,
L and C Lines in GFA1), as well as gaps. Gfapy allows to convert edges
lines from one spefication version to the other (subject to limitations,
see the Versions chapter). Gap lines cannot be converted, as no GFA1
specification exist for them.

### Relationships to external sequences

Fragments represent relationships of segments to external sequences,
i.e. sequences which are not represented in the GFA file itself.
The typical application is to put contigs in relationship with the
reads from which they are constructed.

The set of IDs of the external sequences may overlap the IDs of the
GFA file itself (ie. the namespaces are separated). The list of
external IDs referenced to by fragment lines can be retrieved
using the ```external_names``` property of the
```gfapy.Gfa``` instances.

To find all fragments which refer to an external ID,
the ```fragments_for_external(ID)``` method is used. As an external sequence
can refer to different segments in different F lines, the result is always
an array of F lines.

Conversely, to find all fragments for a particular segment, you may use the
```fragments``` property of the segment instance (see the References chapter).

### Groups

Groups are lines which combine different other lines in an ordered (paths)
or unordered (sets) way. Gfapy supports both GFA1 paths and GFA2 paths and sets.
Paths have a different syntax in the two specification versions.
Methods are provided to edit the group components also without disconnecting
the line instance (see the "References" chapter).

### Other line types

The header contain metadata in a single or multiple lines. For ease of access
to the header information, all its tags are summarized in a single line
instance. See the "Header" chapter for more information.
All lines which start by the string ```#``` are comments; they are
handled in the "Comments" chapter.
Custom lines are lines of GFA2 files which start with a non-standard
record type. Gfapy provides basic built-in support for accessing the information
in custom lines, and allows to define extensions for own record types for
defining more advanced functionality.

### Adding new lines

New lines can be added to a Gfa instance using the ```add_line(line)``` method
or its alias ```append(line)```. The argument may be a string describing a line
with valid GFA syntax, or an instance of the class ```gfapy.Line``` -
if a string is added, a line instance is created and then added.
A line instance can be created manually before adding it, using
the ```gfa.Line.from_string(s)``` method.

### Editing the lines

Accessing the information stored in the fields of a line instance
is described in the "Positional fields" and "Tags"
chapters.

Once a line instance has been added to a ```gfapy.Gfa``` instance, either directly, or using its
string representation, the line is said to be _connected_ to the Gfa.
Reading the information in fields is always allowed, while changing the content
of some fields (fields which refer to other lines) is only possible for
instances which are not connected.

In some cases, methods are provided
to modify the content of reference fields of connected line
(see the "References" chapter).

### Removing lines

Removing a line can be done using the ```rm(line)``` method. The argument
can be a line instance or a string (in which case the line is searched
using the ```line(name)``` method, then eliminated).
A line instance can also be disconnected using the ```disconnect()``` method
on it. Disconnecting a line may trigger other operations, such as the
disconnection of other lines (see the "References" chapter).

### Renaming lines

Lines with an identifier can be renamed. This is done simply by editing the
corresponding field (such as ```name``` or ```sid``` for a segment).
This field is not a reference
to another line and can be freely edited also in line instances connected
to a Gfa. All references to the line from other lines will still be up to
date, as they will refer to the same instance (whose name has been changed)
and their string representation will use the new name.
