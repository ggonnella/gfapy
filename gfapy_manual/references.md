## References

Some fields in GFA lines contain identifiers or lists of identifiers
(sometimes followed by orientation strings), which reference
other lines of the GFA file.

### Connecting a line to a gfapy object

In stand-alone line instances, the identifiers which reference
other lines are strings (or, if they are oriented identifiers,
then instances of gfapy::OrientedLine containing a string).
Lists of identifiers are represented by arrays of strings and oriented
segment instances.

When a line is connected to a gfapy object (adding the line using
```gfapy#<<(line)``` or calling ```RGFA::Line#connect(rgfa)```),
the strings in the fields (and in arrays and oriented line instances)
are changed into references to the corresponding lines in the gfapy object.

The method ```gfapy::Line#connected?``` allows to determine if
a line is connected to an gfapy instance. The method ```RGFA::Line#rgfa```
returns the gfapy instance to which the line is connected.

### References for each record type

The following tables list the references for each record type.
```[]``` represent arrays.

#### GFA1

| Record type | Fields         | Type of reference       |
|-------------|----------------|-------------------------|
| Link        | from, to       | Segment                 |
| Containment | from, to       | Segment                 |
| Path        | segment_names, | [OrientedLine(Segment)] |
|             | links (1)      | [OrientedLine(Link)]    |

(1): paths contain information in the fields segment_names and overlaps,
which allow to find the identify from which they depend; these links can be
retrieved using ```links``` (which is not a field).

#### GFA2

| Record type | Fields        | Type of reference                    |
|-------------|---------------|--------------------------------------|
| Edge        | sid1, sid2    | Segment                              |
| Gap         | sid1, sid2    | Segment                              |
| Fragment    | sid           | Segment                              |
| U Group     | items         | [Edge/O-Group/U-Group/Segment]       |
| O Group     | items         | [OrientedLine(Edge/O-Group/Segment)] |

### Backreferences for each record type

When a line containing a reference to another line is connected to a gfapy
object, backreferences to it are created in the targeted line.

For each backreference collection a getter method exist, which is named
as the collection (e.g. ```gfapy::Line::Segment#dovetails_L```).
The methods return frozen arrays (as changing the content of
the array directly would invalid other related references in the graph object).
To change the reference which generated the backreference, see the section
"Editing reference fields" below.

The following tables list the backreferences collections for each record type.

#### GFA1

| Record type | Backreferences      | Type |
|-------------|-----------------------------
| Segment     | dovetails_L         | L    |
|             | dovetails_R         | L    |
|             | edges_to_contained  | C    |
|             | edges_to_containers | C    |
|             | paths               | P    |
| Link        | paths               | P    |

#### GFA2

| Record type | Backreferences      | Type |
|-------------|---------------------|-------
| Segment     | dovetails_L         | E    |
|             | dovetails_R         | E    |
|             | edges_to_contained  | E    |
|             | edges_to_containers | E    |
|             | internals           | E    |
|             | gaps_L              | G    |
|             | gaps_R              | G    |
|             | fragments           | F    |
|             | paths               | O    |
|             | sets                | U    |
| Edge        | paths               | O    |
|             | sets                | U    |
| O Group     | paths               | O    |
|             | sets                | U    |
| U Group     | sets                | U    |

#### Backreference convenience methods

In some cases, additional methods are available which combine in different way
the backreferences information.

The segment ```dovetails``` and ```gaps```
methods take an optional argument. Without argument all dovetail overlaps
(references to links or dovetail edges) or gaps are returned.  If :L or :R is
provided as argument, the dovetails overlaps (or gaps) of the left or,
respectively, right end of the segment sequence are returned (equivalent to
dovetails_L/dovetails_R and gaps_L/gaps_R).
The segment ```containments``` methods returns both containments
where the segment is the container or the contained segment.
The segment ```edges``` method returns all edges (dovetails, containments
and internals) with a reference to the segment.

Other methods
directly compute list of segments from the edges lists mentioned above.
In particular,
the segment ```neighbours``` method computes the set of segment
instances which are connected by dovetails to the segment.
The segment ```containers``` and ```contained``` methods similarly
compute the set of segment instances which, respectively, contains
the segment, or are contained in the segment.

### Multiline group definitions

Groups can be defined on multiple lines, by using the same ID
for each line defining the group. If multiple gfapy::Line::Group
instances with the same ID are connected to the gfapy, the final
gfapy will only contain the last instance: all previous one are
disconnected and their items list prepended to the last instance.
All tags will be copied to the last instance added.

The tags of multiple line defining a group
may not contradict each other. Either are the tag names on different
lines defining the group all different, or, if the same tag is present
on different lines, the value and datatype must be the same.

### Induced set and captured path

The item list in GFA2 sets and paths may not contain elements
which are implicitly involved.
For example a path may contain segments, without specifying the
edges connecting them, if there is only one such edge. Alternatively
a path may contain edges, without explitely indicating the segments.
Similarly a set may contain edges, but not the segments refered to
in them, or contain segments which are connected by edges, without
the edges themselves.
Furthermore groups may refer to other groups (set to sets or paths,
paths to paths only), which then indirectly contain references to
segments and edges.

gfapy provides methods for the computation of the sets of segments
and edges which are implied by an ordered or unordered group.
Thereby all references to subgroups are resolved and implicit
elements are added, as described in the specification.
The computation can, therefore, only be applied to connected lines.
For unordered groups, this computation is provided by the method
```induced_set```, which returns an array of segment and edge instances.
For ordered group, the computation is provided by the method
```captured_path```, whcih returns a list of gfapy::OrientedLine instances,
alternating segment and edge instances (and starting and ending in
segments).

The methods ```induced_segments_set```, ```induced_edges_set```,
```captured_segments``` and ```captured_edges``` return, respectively,
the list of only segments or edges, in ordered or unordered groups.

### Disconnecting a line from a gfapy object

Lines can be disconnected using ```gfapy#rm(line)``` or
```gfapy::Line#disconnect```.

Disconnecting a line affects other lines as well. Lines which are dependent
on the disconnected line are disconnected as well. Any other reference to
disconnected lines is removed as well. In the disconnected line, references
to lines are transformed back to strings and backreferences are deleted.

The following tables show which dependent lines are disconnected if they
refer to a line which is being disconnected.

#### GFA1

| Record type | Dependent lines                |
|-------------|--------------------------------|
| Segment     | links (+ paths), containments  |
| Link        | paths                          |

#### GFA2

| Record type | Dependent lines                            |
|-------------|--------------------------------------------|
| Segment     | edges, gaps, fragments, u-groups, o-groups |
| Edge        | u-groups, o-groups                         |
| U-Group     | groups                                     |

### Editing reference fields

In connected line instances, it is not allowed to directly change the content
of fields containing references to other lines, as this would make the state of
the gfapy object invalid.

Besides the fields containing references, some other fields are read-only in
connected lines. Changing some of the fields would require moving the
backreferences to other collections (position fields of edges and gaps,
from_orient and to_orient of links). The overlaps field of connected links is
readonly as it may be necessary to identify the link in paths.

#### Renaming an element

The name field of a line (e.g. segment name/sid) is not a reference and thus
can be edited also in connected lines.  When the name of the line is changed,
no manual editing of references (e.g. from/to fields in links) is necessary, as
all lines which refer to the line will still refer to the same instance.
The references to the instance in the gfapy lines collections will be
automatically updated. Also, the new name will be correctly used when
converting to string, such as when the gfapy is written to a GFA file.

Renaming a line to a name which already exists has the same effect of adding
a line with that name. That is, in most cases, ```gfapy::NotUniqueError``` is
raised. An exception are GFA2 groups: in this case
the line will be appended to the existing line with the same name.

#### Adding and removing group elements

Elements of GFA2 groups can be added and removed from both connected and
non-connected lines, using the following methods.

To add an item to or remove an item from an unordered group, use the methods
```add_item(item)``` and ```rm_item(item)```, which take as argument either
a string (identifier) or a line instance.

To append or prepend an item to an ordered group, use the methods
```append_item(item)``` and ```prepend_item(item)```.  To remove the first or
the last item of an ordered group use the methods
```rm_first_item``` and
```rm_last_item```.

#### Editing read-only fields of connected lines

Editing the read-only information of edges, gaps, links, containments,
fragments and paths is more complicated.  These lines shall be disconnected
before the edit and connected again to the gfapy object after it. Before
disconnecting a line, you should check if there are other lines dependent on it
(see tables above). If so, you will have to disconnect these lines first,
eventually update their fields and reconnect them at the end of the operation.

### Virtual lines

The order of the lines in GFA is not prescribed. Therefore, during parsing,
or constructing a gfapy in memory, it is possible that a line is referenced to,
before it is added to the gfapy instance.
Whenever this happens, gfapy creates a "virtual" line instance.

Users do not have to handle with virtual lines, if they work with
complete and valid GFA files.

Virtual lines are similar to normal line instances, with some limitations
(they contain only limited information and it is not allowed to add tags to
them). To check if a line is a virtual line, one can use the
```gfapy::Line#virtual?``` method.

As soon as the parser founds the real line corresponding to a previously
introduced virtual line, the virtual line is exchanged with the real line
and all references are corrected to point to the real line.

### Summary of references-related API methods

```python
gfapy#<<(line)/rm(line)
gfapy::Line#connect(rgfa)
gfapy::Line#disconnect
gfapy::Line#connected?
gfapy::Line#rgfa
gfapy::Line#virtual?
gfapy::Line::Segment::GFA1/GFA2#dovetails(_L|_R)
gfapy::Line::Segment::GFA1/GFA2#dovetails
gfapy::Line::Segment::GFA1/GFA2#neighbours
gfapy::Line::Segment::GFA1/GFA2#contain(ed|ers)
gfapy::Line::Segment::GFA1/GFA2#edges_to_contain(ed|ers)
gfapy::Line::Segment::GFA1/GFA2#containments
gfapy::Line::Segment::GFA1/GFA2#internals
gfapy::Line::Segment::GFA1/GFA2#edges
gfapy::Line::Segment::GFA2#gaps(_L|_R)
gfapy::Line::Segment::GFA2#gaps
gfapy::Line::Segment::GFA2#fragments
gfapy::Line::Segment::GFA1/GFA2#paths
gfapy::Line::Segment::GFA2#sets
gfapy::Line::Fragment#sid
gfapy::Line::Edge::Containment/Link#from/to
gfapy::Line::Gap/Edge::GFA2#sid1/sid2
gfapy::Line::Gap/Edge::GFA2#sets/paths
gfapy::Line::Group::Path#segment_names
gfapy::Line::Group::Path#links
gfapy::Line::Group::Unordered#items
gfapy::Line::Group::Unordered#paths
gfapy::Line::Group::Unordered#add_item(item)
gfapy::Line::Group::Unordered#rm_item(item)
gfapy::Line::Group::Ordered#items
gfapy::Line::Group::Ordered#paths
gfapy::Line::Group::Ordered#append_item(item)
gfapy::Line::Group::Ordered#prepend_item(item)
gfapy::Line::Group::Ordered#rm_first_item
gfapy::Line::Group::Ordered#rm_last_item
gfapy::Line::Group::Ordered#captured_paths
gfapy::Line::Group::Ordered#captured_segments
gfapy::Line::Group::Ordered#captured_edges
gfapy::Line::Group::Unordered#induced_set
gfapy::Line::Group::Unordered#induced_segments_set
gfapy::Line::Group::Unordered#induced_edges_set
```
