## References

Some fields in GFA lines contain identifiers or lists of identifiers
(sometimes followed by orientation symbols), which reference
other lines of the GFA file.

### Connecting a line to a RGFA object

In stand-alone line instances, the identifiers which reference
other lines are symbols (or, if they are oriented identifiers,
then instances of RGFA::OrientedLine containing a symbol).
Lists of identifiers are represented by arrays of symbols and oriented
segment instances.

When a line is connected to a RGFA object (adding the line using
```RGFA#<<(line)``` or calling ```RGFA::Line#connect(rgfa)```),
the symbols in the fields (and in arrays and oriented line instances)
are changed into references to the corresponding lines in the RGFA object.

The method ```RGFA::Line#connected?``` allows to determine if
a line is connected to an RGFA instance. The method ```RGFA::Line#rgfa```
returns the RGFA instance to which the line is connected.

### References for each record type

The following tables list the references for each record type.
```[]``` represent arrays.

#### GFA1

| Record type | Fields         | Type of reference       |
|-------------|----------------|-------------------------|
| Link        | from, to       | Segment                 |
| Containment | from, to       | Segment                 |
| Path        | segment_names, | [OrientedLine(Segment)] |
|             | links (1)      | [Link]                  |

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

| Record type | Backreferences                |
|-------------|-------------------------------|
| Segment     | dovetails_L (type: L)         |
|             | dovetails_R (type: L)         |
|             | edges_to_contained (type: C)  |
|             | edges_to_containers (type: C) |
|             | paths                         |
| Link        | paths                         |

#### GFA2

| Record type | Backreferences                |
|-------------|-------------------------------|
| Segment     | dovetails_L (type: E)         |
|             | dovetails_R (type: E)         |
|             | edges_to_contained (type: E)  |
|             | edges_to_containers (type: E) |
|             | internals (type: E)           |
|             | gaps_L (type: G)              |
|             | gaps_R (type: G)              |
|             | fragments                     |
|             | ordered_groups                |
|             | unordered_groups              |
| Edge        | ordered_groups                |
|             | unordered_groups              |
| O Group     | ordered_groups                |
|             | unordered_groups              |
| U Group     | unordered_groups              |

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

### Induced sets

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

The method ```induced_set``` computes the set of segments and edges
induced by the group. Thereby all references to subgroups are resolved.
The method can only be applied to connected lines.
If the group is ordered, then the method returns an ordered list of
RGFA::OrientedLine instances, starting and
ending with a segment, and containing edges between pair of segments.
If the group is unordered, the method returns an array of
RGFA::Line instances, first all segments, then all edges between those
segments.

The methods ``induced_segments_set``` and ```induced_edges_set``` return,
respectively, the list of segments and edges. The elements of the list
are RGFA::Line instances for unordered groups, and RGFA::OrientedLine instances
for ordered groups.

### Disconnecting a line from a RGFA object

Lines can be disconnected using ```RGFA#rm(line)``` or
```RGFA::Line#disconnect```.

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

#### GFA2

| Record type | Dependent lines                            |
|-------------|--------------------------------------------|
| Segment     | edges, gaps, fragments, u-groups, o-groups |
| Edge        | u-groups, o-groups                         |
| U-Group     | groups                                     |

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
```RGFA::Line::Group::Unordered#add_item(item)``` and
```RGFA::Line::Group::Unordered#rm_item(item)```, which take as argument either
a symbol (identifier) or a line instance.

To append or prepend an item to an ordered group, use the methods
```RGFA::Line::Group::Ordered#append_item(item)``` and
```RGFA::Line::Group::Ordered#prepend_item(item)```.  To remove the first or
the last item of an ordered group use the methods
```RGFA::Line::Group::Ordered#rm_first_item``` and
```RGFA::Line::Group::Ordered#rm_last_item```.

#### Editing read-only fields of connected lines

Editing the read-only information of edges, gaps, links, containments,
fragments and paths is more complicated.  These lines shall be disconnected
before the edit and connected again to the RGFA object after it. Before
disconnecting a line, you should check if there are other lines dependent on it
(see tables above). If so, you will have to disconnect these lines first,
eventually update their fields and reconnect them at the end of the operation.

### Virtual lines

The order of the lines in GFA is not prescribed. Therefore, during parsing,
or constructing a RGFA in memory, it is possible that a line is referenced to,
before it is added to the RGFA instance.
Whenever this happens, RGFA creates a "virtual" line instance.

Users do not have to handle with virtual lines, if they work with
complete and valid GFA files.

Virtual lines are similar to normal line instances, with some limitations
(they contain only limited information and it is not allowed to add tags to
them). To check if a line is a virtual line, one can use the
```RGFA::Line#virtual?``` method.

As soon as the parser founds the real line corresponding to a previously
introduced virtual line, the virtual line is exchanged with the real line
and all references are corrected to point to the real line.

### Summary of references-related API methods

```
RGFA#<<(line)/rm(line)
RGFA::Line#connect(rgfa)/disconnect
RGFA::Line#connected?/rgfa
RGFA::Line#virtual?
RGFA::Line::Segment::GFA1/GFA2#dovetails[_L|_R]/contain(ed|ers)/neighbours
RGFA::Line::Segment::GFA1#paths
RGFA::Line::Segment::GFA2#gaps[_L|_R]/fragments/[un]ordered_groups/internals
RGFA::Line::Fragment#sid
RGFA::Line::Edge::Containment/Link#from/to
RGFA::Line::Gap/Edge::GFA2#sid1/sid2
RGFA::Line::Gap/Edge::GFA2#unordered_groups/ordered_groups
RGFA::Line::Group::Path#segment_names
RGFA::Line::Group::Path#links
RGFA::Line::Group::Unordered#items
RGFA::Line::Group::Unordered#ordered_groups
RGFA::Line::Group::Unordered#add_item(item)/rm_item(item)
RGFA::Line::Group::Ordered#items
RGFA::Line::Group::Ordered#ordered_groups
RGFA::Line::Group::Ordered#append_item(item)/prepend_item(item)
RGFA::Line::Group::Ordered#rm_first_item/rm_last_item
```
