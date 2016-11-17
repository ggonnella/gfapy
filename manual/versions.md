## GFA versions

There are some differences between the two versions of GFA.
The header lines and comments are the same in both versions.
Segments only have some minor versions (a length field in GFA2).
The two edges types of GFA1 (links and containments) are generalized into
the E lines of GFA2. Paths have a different syntax and are called ordered
groups in GFA2. Unordered groups have been introduced to represent
generic subgraphs. Some other new line types have been introduced for
documenting read-to-contig alignments (fragments) and for scaffolding (gaps).

### Version auto-detection (process_line_queue method) # XXX

### Version of a RGFA object or RGFA::Line (version method) # XXX

### Conversion of RGFA or RGFA::Line instances # XXX

### Segments

GFA2 segments contain an additional field (slen: length of the sequence),
compared to GFA1.

Conversion from GFA2 to GFA1 is possible, unless unsupported
characters are used in the sequence (which is usually not the case) or
the identifier is incompatible with GFA1 (ie it ends with + or - followed
by a comma).

Conversion from GFA1 to GFA2 is possible, unless no sequence
and no LN tag are present.

### Edges

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

### Groups

GFA1 defines only paths, while GFA2 has ordered groups (equivalent to paths)
and unordered groups.

Conversion from GFA1 to GFA2 is possible by storing
an identifier for each link in the id tag.

Conversion from GFA2 to GFA1 is possible for O groups, if they contain
only segments and/or edges representing dovetail overlaps. Subgroups
are also allowed, but only if they are also composed only of segments
and/or edges and/or subgroups with the same limitations.

### GFA2-only

GFA2 edges representing internal overlaps, as well as relationships
other than edges (ie. gaps and fragments) cannot be converted to GFA1.

Unordered groups cannot be converted to GFA1.

Custom records (i.e. lines with user defined record types)
are not supported in GFA1.

### Requirements for version convertion

The following tables summarize the requirements for each kind of record,
so that a convertion to the other GFA version is possible.

#### GFA1 to GFA2

| Record type | Requirements                                     |
|-------------|--------------------------------------------------|
| Comment     | None                                             |
| Header      | None                                             |
| Segment     | Sequence or LN tag available                     |
| Link        | CIGAR and segment lengths available              |
| Containment | CIGAR and segment lengths available              |
| Path        | Links must have an id tag                        |

#### GFA2 to GFA1

| Record type | Requirements                                     |
|-------------|--------------------------------------------------|
| Comment     | None                                             |
| Header      | None                                             |
| Segment     | Sequence alphabet compatible with GFA1           |
|             | Identifier compatible with GFA1 name             |
| Edge        | Dovetail overlap or containment                  |
| O Group     | Items are dovetails/segments (also in subgroups) |
| U Group     | Cannot be converted!                             |
| Gap         | Cannot be converted!                             |
| Fragment    | Cannot be converted!                             |
| Custom      | Cannot be converted!                             |

## Summary of API methods related to GFA versions

