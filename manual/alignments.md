## Alignments

Some positional fields (GFA1: in P/C/L lines; GFA2: in E/F lines)
describe alignments of sequences. If an alignment is not given, the
placeholder symbol ```*``` is used instead. In GFA1 the alignments
can be given as CIGAR strings, in GFA2 also as Dazzler traces.

RGFA uses different classes (in module RGFA::Alignment) for representing the two
possible alignment styles (cigar strings and traces) and undefined alignments
(placeholders).

### Creating an alignment

An alignment instance is usually created from its GFA string representation
by using the ```String#to_alignment``` method:
```ruby
"*".to_alignment        # => RGFA::Alignment::Placeholder
"10,10,10".to_alignment # => RGFA::Alignment::Trace
"30M2I30M".to_alignment # => RGFA::Alignment::CIGAR
```

The alignment classes also provide a ```to_alignment```
method (returning self), so that is always safe to call the method on a
variable which can contain a string or an alignment instance.

### Reading and editing CIGARs

CIGARs are represented by arrays of cigar operation objects.
Each cigar operation provides the methods ```len```/```len=``` and
```code```/```code=```. Len is the length of the operation (Integer).

CIGAR values can be edited using the methods ```len=``` and ```code=```
of the single operations or editing the array itself (which allows e.g.
to add or remove operations). If the array is emptied, its
string representation will be ```*```.

CIGARs consider one sequence as reference and another sequence
as query. The ```length_on_reference``` and ```length_on_query``` methods
compute the length of the alignment on the two sequences.
These methods are used by the library e.g. to convert GFA1 L lines to GFA2
E lines (which is only possible if CIGARs are provided).

#### Complement CIGARs

CIGARs are dependent on which sequence is taken as reference and which is
taken as query. For each alignment, a complement CIGAR can be computed
(using the method ```complement```), which is the CIGAR obtained when the
two sequences are switched. This method is used by the library
e.g. to compare links, as they can be expressed in different ways, by
switching the two sequences.

#### Validation

The ```validate``` method checks if all operations in a cigar use
valid codes and length values (which must be non-negative)
The codes can be M, I, D or P. For GFA1 the other codes are formally accepted
(no exception is raised), but their use is discouraged.
An error is raised in GFA2 on validation, if the other codes are used.

#### Special case: link overlaps as identifiers

In GFA1 the overlap field of links is sometimes used
(combined with other fields) as a link identifier in path lines.
Therefore if a link is referred to from paths, and the CIGAR
is listed in the path (which is sometimes necessary when multiple link combine
the same segments), changing the value of the overlap field will result
in an invalid graph, unless the change is manually replicated in all
lines referring to the link.
This situation is currently not catched by validating the
line or the graph. Future versions of the library may forbid editing in these
cases, or propagate the editing to all lines referring to the link.

### Reading and editing traces

Traces are arrays of non-negative integers. The values are interpreted
using a trace spacing value. If traces are used, a trace spacing value must be
defined in a TS integer tag, either in the header, or in the single lines
which contain traces.

### Computing the alignment and complement traces

Currently there is way to compute the alignment in RGFA, thus the trace
information can be accessed and edited, but not used for this purpose.
Future versions may provide this functionality. Because of this there
is currently no way in RGFA to compute a complement trace (trace obtained
when the sequences are switched).

### Recognizing undefined alignments

The ```placeholder?``` method is available for strings and
alignment instances and is the correct way to understand if an alignment
field contains a defined value (cigar, trace) or not (placeholder).

### Summary of the API public methods for alignments

```
(String, RGFA::Alignment::*)#to_s
(String, RGFA::Alignment::*)#to_alignment
(String, RGFA::Alignment::*)#placeholder?
RGFA::Alignment::*#validate
RGFA::Alignment::(Trace|CIGAR)#(array methods; each,map,reverse,...)
RGFA::Alignment::CIGAR::Operation#(len|len=|code|code=)
RGFA::Alignment::CIGAR#complement
RGFA::Alignment::CIGAR#(length_on_reference,length_on_query)
```
