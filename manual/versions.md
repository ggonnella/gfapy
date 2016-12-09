## GFA versions

Two versions of GFA have been defined: GFA1 and GFA2.
The header lines and comments have the same syntax in both versions.  Segment
lines have a different syntax, as they have an additional positional field in
GFA2. Edges lines are version-specific: L and C are found only in GFA1,
and E only in GFA2. Group lines are also version-specific: P in GFA1, O and U
in GFA2. F and G lines are GFA2-specific. Furthermore, GFA2 allows to create
user-specific record types, by using non-standard codes.

### Version autodetection

RGFA tries to autodetect the version of a GFA file from its syntax.  The
version of a valid GFA can always be recognized, unless it contains only header
and comment lines, as any other line refer to segments, and segments are
version-specific.  If a GFA contains only header and commments, the version
does not matter.

The version is set as soon as a version-specific element is found.
Here is the list of such elements:
- segment lines (different number of positional fields in GFA1 and GFA2)
- version tag in header (VN:Z:1.0 or VN:Z:2.0)
- E/G/F/O/U lines (GFA2 specific)
- custom record-type lines (GFA2 specific)

If subsequent version-specific elements are found which contrast with the first
one, RGFA::VersionError is raised.

P/C/L lines are technically not GFA1-specific, as they could be custom records
in GFA2. However, their use in GFA2 is not supported by RGFA and an exception
is thrown if these records are found in that version.  Thus if these lines are
found, their processing is delayed until a version-specific signal is found.
If the version is GFA2, RGFA::VersionError is raised.

### Setting and reading the version

Besides relying on autodetection, it is possible to explicitely set the version
of the RGFA or line objects, if this is known.  Methods which create RGFA, i.e.
```new``` and ```from_file```, as well as methods which create RGFA lines, i.e.
```new``` and the string method ```to_rgfa_line```, all accept a version
parameter, which can be set to the symbols ```:gfa1``` or ```:gfa2```.

Both the RGFA and the RGFA Line instances respond to the method
```version``` which returns one of: ```:gfa1```, ```:gfa2``` or ```:unknown```.

### Line queue

The version autodetection feature is achieved by deferring the processing
of version-specific lines (ie everything besides headers and comments)
which are found before the version can be detected as explained above.
These lines are put on a line queue. Once the version is clear,
the method ```process_line_queue``` is called on the RGFA instance.

This method can also be called by the user, if e.g. an example GFA is
created programmatically, where the version is unclear. For the reasons
explained above, this will generally not be the case, as such a GFA file
would only contain headers and comments.

### Conversion of RGFA or RGFA::Line instances

The conversion of GFA lines between GFA version is possible in some
cases. When possible, this is achieved by using the ```to_gfa1```
and ```to_gfa2``` methods on the line instances. It is also possible
to directly output the line as a string in the other version
using the ```to_gfa1_s``` and ```to_gfa2_s``` methods.

Some lines do not require conversion (headers - except changing
the value of the VN tag, comments).
The conversions of GFA2-specific information (gaps, fragments, sets,
custom records) is not possible. The other lines (segments,
edges/links/containments, paths) can be converted if they
fulfill some requirements described below.

#### Segments

GFA2 segments contain an additional field (slen: length of the sequence),
compared to GFA1.

Conversion from GFA2 to GFA1 is possible, unless unsupported
characters are used in the sequence (which is usually not the case) or
the identifier is incompatible with GFA1 (ie it ends with + or - followed
by a comma).

Conversion from GFA1 to GFA2 is possible, unless no sequence
and no LN tag are present.

#### Edges

GFA2 generalizes the links and containments into edge lines, which can
represent also alignments which are not representable in GFA1.
This goes at the costs of some simplicity, as GFA2 needs to indicate
the coordinates of the alignment, while GFA1 is purely topology based.

Conversion from GFA1 to GFA2 requires CIGARs, so that the alignment coordinates
can be computed. This is only possible if the sequence lengths are available,
which is anyway required for converting segments.

Conversion from GFA2 to GFA1 is possible if the edge represents
a dovetail overlap or an alignment. Also trace alignments are not supported
in GFA1, so the overlap will be set to *. Edge identifiers are stored
in id:Z: tags.

#### Paths

Conversion of paths from GFA1 to GFA2 is possible, if the links specified
in the path are the only between pairs of segments, or if the links contain
an ID optional tag.

Conversion of paths from GFA2 to GFA1 is possible, if they contain
only segments and/or edges representing dovetail overlaps. Child paths
are also allowed, but only if they are also composed only of segments
and/or edges and/or child paths with the same limitations.

#### Conversion from GFA1 to GFA2: requirements

| Record type | Requirements                                     |
|-------------|--------------------------------------------------|
| Comment     | None                                             |
| Header      | None                                             |
| Segment     | Sequence or LN tag available                     |
| Link        | CIGAR and segment lengths available              |
| Containment | CIGAR and segment lengths available              |
| Path        | Links must have an id tag                        |

#### Conversion from GFA2 to GFA1: requirements

| Record type | Requirements                                     |
|-------------|--------------------------------------------------|
| Comment     | None                                             |
| Header      | None                                             |
| Segment     | Sequence alphabet compatible with GFA1           |
|             | Identifier compatible with GFA1 name             |
| Edge        | Dovetail overlap or containment                  |
| Path        | All edges are dovetails                          |
| Sets        | Cannot be converted!                             |
| Gap         | Cannot be converted!                             |
| Fragment    | Cannot be converted!                             |
| Custom      | Cannot be converted!                             |

## Summary of API methods related to GFA versions

```ruby
RGFA.new(version:x)
RGFA.from_file(version:x)
RGFA::Line.new(version:x)
String.to_rgfa_line(version:x)
RGFA#version
RGFA#process_line_queue
RGFA::Line#version
RGFA::Line#to_gfa1
RGFA::Line#to_gfa2
RGFA::Line#to_gfa1_s
RGFA::Line#to_gfa2_s
```
