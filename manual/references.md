## References

Some fields in GFA lines contain identifiers or lists of identifiers
(sometimes followed by orientation symbols), which reference
other lines of the GFA file.

### Connecting a line to a RGFA object

In stand-alone line instances, the identifiers which reference
other lines are symbols (or instances of RGFA::OrientedSegment, consisting
of a symbol and an orientation, if they contain an orientation).
Lists of identifiers are represented by arrays of symbols and oriented
segment instances.

When a line is connected to a RGFA object (adding the line using
```RGFA#<<(line)``` or calling ```RGFA::Line#connect(rgfa)```),
the symbols in the fields (and in arrays and oriented segments) are changed into
references to the corresponding lines in the RGFA object.

### References

The following tables list the references for each record type.

#### GFA1

| Record type | Fields         | Type of reference        |
|-------------|----------------|--------------------------|
| Link        | from, to       | Segment                  |
| Containment | from, to       | Segment                  |
| Path        | segment_names, | Array of OrientedSegment |
|             | links (1)      | Array of Link            |
|-------------|----------------|--------------------------|

(1): paths contain information in the fields segment_names and overlaps,
which allow to find the identify from which they depend; these links can be
retrieved using ```links``` (which is not a field).

#### GFA2

| Record type | Fields        | Type of reference               |
|-------------|---------------|---------------------------------|
| Edge        | sid1, sid2    | Segment                         |
| Gap         | sid1, sid2    | Segment                         |
| Fragment    | sid           | Segment                         |
| U/O Group   | items         | Array of Edge/Gap/Group/Segment |
|-------------|---------------|---------------------------------|

### Backreferences

When a line containing a reference to another line is connected to a RGFA
object, backreferences to it are created in the targeted line.

For each backreference collection a getter method exist, which is named
as the collection (e.g. ```RGFA::Line::Segment#dovetails_L```).
The methods return frozen arrays (as changing the content of
the array directly would invalid other related references in the graph object).
To change the reference which generated the backreference, see the section
"Editing reference fields" below.

The following tables list the backreferences collections for each record type.

#### GFA1

| Record type | Backreferences        |
|-------------|-----------------------|
| Segment     | dovetails_L (type: L) |
|             | dovetails_R (type: L) |
|             | contained (type: C)   |
|             | containers (type: C)  |
|             | paths                 |
| Link        | paths                 |
|-------------|-----------------------|

#### GFA2

| Record type | Backreferences        |
|-------------|-----------------------|
| Segment     | dovetails_L (type: E) |
|             | dovetails_R (type: E) |
|             | contained (type: E)   |
|             | containers (type: E)  |
|             | internals (type: E)   |
|             | gaps_L (type: G)      |
|             | gaps_R (type: G)      |
|             | fragments             |
|             | ordered_groups        |
|             | unordered_groups      |
| Edge        | ordered_groups        |
|             | unordered_groups      |
| Gap         | ordered_groups        |
|             | unordered_groups      |
| U/O Group   | ordered_groups        |
|             | unordered_groups      |
|-------------|------------------------

#### Backreference convenience methods

In some cases, additional methods are available which combine in different way
the backreferences information.

The ```RGFA::Line::Segment#dovetails``` and ```RGFA::Line::Segment#gaps```
methods take an optional argument. Without argument all dovetail overlaps
(references to links or dovetail edges) or gaps are returned.  If :L or :R is
provided as argument, the dovetails overlaps (or gaps) of the left or,
respectively, right end of the segment sequence are returned (equivalent to
dovetails_L/dovetails_R and gaps_L/gaps_R).

The ```RGFA::Line::Segment#neighbours``` method computes the set of segment
instances which are connected by dovetails to the segment.

### Disconnecting a line from a RGFA object

Lines can be disconnected using ```RGFA#rm(line)``` or
```RGFA::Line#disconnect!```.

Disconnecting a line affects other lines as well. Lines which are dependent
on the disconnected line are disconnected as well. Any other reference to
disconnected lines is removed as well. In the disconnected line, references
to lines are transformed back to symbols and backreferences are deleted.

The following tables show which dependent lines are disconnected if they
refer to a line which is being disconnected.

#### GFA1

| Record type | Dependent lines                |
|-------------|--------------------------------|
| Segment     | links (+ paths), containments  |
| Link        | paths                          |
|-------------|--------------------------------|

#### GFA2

| Record type | Dependent lines                |
|-------------|--------------------------------|
| Segment     | edges, gaps, fragments, groups |
| Edge        | groups                         |
| Gap         | groups                         |
| Group       | groups                         |
|-------------|--------------------------------|

### Editing reference fields

In connected line instances, it is not allowed to directly change the content
of fields containing references to other lines, as this would make the state of
the RGFA object invalid.

Besides the fields containing references, some other fields are read-only in
connected lines. Changing some of the fields would require moving the
backreferences to other collections (position fields of edges and gaps,
from_orient and to_orient of links). The overlaps field of connected links is
readonly as it may be necessary to identify the link in paths.

#### Renaming an element

The name field of a line (e.g. segment name/sid) is not a reference and thus
can be edited also in connected lines.  When the name of the line is changed,
no manual editing of references (e.g. from/to fields in links) is necessary, as
all lines which refer to the line will still refer to the same instance.  The
new name will be automatically used when converting to string, such
as when the RGFA is written to a GFA file.

#### Adding and removing group elements

To add an item to or remove an item from an unordered group, use the methods
```RGFA::Line::Group#add_item(item)``` ```RGFA::Line::Group#rm_item(item)```,
which take as argument either a symbol (identifier) or a line instance.

To append or prepend an item to an ordered group, use the methods
```RGFA::Line::Group#append_item(item)``` and
```RGFA::Line::Group#prepend_item(item)```.  To remove the first or the last
item of an ordered group use the methods ```RGFA::Line::Group#rm_first_item```
and ```RGFA::Line::Group#rm_last_item```.

#### Editing read-only fields of connected lines

Editing the read-only information of edges, gaps, links, containments,
fragments and paths is more complicated.  These lines shall be disconnected
before the edit and connected again to the RGFA object after it. Before
disconnecting a line, you should check if there are other lines dependent on it
(see tables above). If so, you will have to disconnect these lines first,
eventually update their fields and reconnect them at the end of the operation.

### Virtual lines

The order of the lines in GFA is not prescribed. Therefore, during parsing,
it is possible that a line is referenced to, before it is found.
Whenever this happens, RGFA creates a "virtual" line instance.
Usually users do not have to handle with virtual lines, if they work with
complete and valid GFA files.

Virtual lines are similar to normal line instances, with some limitations
(they contain only limited information and it is not allowed to add tags to
them). To check if a line is a virtual line, one can use the
```RGFA::Line#virtual?``` method.

As soon as the parser founds the real line corresponding to a previously
introduced virtual line, the virtual line is exchanged with the real line
and all references are corrected to point to the real line.

### Summary of references-related API methods

#XXX
