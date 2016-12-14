## Alignments

Some fields contain alignments and lists of alignments (L/C: overlap; P:
overlaps; E/F: alignment). If an alignment is not given, the placeholder symbol
```*``` is used instead.  In GFA1 the alignments can be given as CIGAR strings,
in GFA2 also as Dazzler traces.

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
variable which can contain a string or an alignment instance:
```ruby
RGFA::Alignment::Placeholder.new.to_alignment
RGFA::Alignment::Trace.new([12,13,0]).to_alignment
```

### Recognizing undefined alignments

The ```placeholder?``` method is available for strings and
alignment instances and is the correct way to understand if an alignment
field contains a defined value (cigar, trace) or not (placeholder).

```ruby
"30M".to_alignment.placeholder? # => false
"10,10,10".to_alignment.placeholder? # => false
"*".to_alignment.placeholder? # => true
"*".placeholder? # => true
RGFA::Alignment::CIGAR.new([]).placeholder? # => true
RGFA::Alignment::Trace.new([]).placeholder? # => true
RGFA::Alignment::Placeholder.new.placeholder? # => true
```

### Reading and editing CIGARs

CIGARs are represented by arrays of cigar operation objects.
Each cigar operation provides the methods ```len```/```len=``` and
```code```/```code=```. Len is the length of the operation (Integer).

```ruby
cigar = "30M".to_alignment
cigar.kind_of?(Array) # => true
operation = cigar[0]
operation.class # => RGFA::Alignment::CIGAR::Operation
operation.code # => :M
operation.len # => 30
operation.to_s # => "30M"
operation.code = :D
operation.len = 10
operation.to_s # => "10D"
```

CIGAR values can be edited using the methods ```len=``` and ```code=```
of the single operations or editing the array itself (which allows e.g.
to add or remove operations). If the array is emptied, its
string representation will be ```*```.

```ruby
cigar = "30M".to_alignment
cigar << RGFA::Alignment::CIGAR::Operation.new(12, :D)
cigar.to_s # "30M12D"
cigar.delete(cigar[1])
cigar.to_s # "30M"
cigar.delete(cigar[0])
cigar.to_s # "*"
```

CIGARs consider one sequence as reference and another sequence
as query. The ```length_on_reference``` and ```length_on_query``` methods
compute the length of the alignment on the two sequences.
These methods are used by the library e.g. to convert GFA1 L lines to GFA2
E lines (which is only possible if CIGARs are provided).

```ruby
cigar = "30M10D20M5I10M".to_alignment
cigar.length_on_reference # => 70
cigar.length_on_query # => 65
```

#### Validation

The ```validate``` method checks if all operations in a cigar use
valid codes and length values (which must be non-negative)
The codes can be M, I, D or P. For GFA1 the other codes are formally accepted
(no exception is raised), but their use is discouraged.
An error is raised in GFA2 on validation, if the other codes are used.

```ruby
cigar = "30M10D20M5I10M".to_alignment
cigar.validate # no exception raised
cigar = "-30M".to_alignment
cigar.validate # raises an exception
cigar = "30X".to_alignment
cigar.validate # raises an exception
cigar = "10=".to_alignment(version: :gfa1)
cigar.validate # no exception raised
cigar = "10=".to_alignment(version: :gfa2)
cigar.validate # raises an exception
```

### Reading and editing traces

Traces are arrays of non-negative integers. The values are interpreted
using a trace spacing value. If traces are used, a trace spacing value must be
defined in a TS integer tag, either in the header, or in the single lines
which contain traces.

```ruby
gfa.header.TS    # => the global TS value
gfa.edges(:x).TS # => an edge''s own TS tag
```

### Complement alignment

CIGARs are dependent on which sequence is taken as reference and which is
taken as query. For each alignment, a complement CIGAR can be computed
(using the method ```complement```), which is the CIGAR obtained when the
two sequences are switched. This method is used by the library
e.g. to compare links, as they can be expressed in different ways, by
switching the two sequences.

```ruby
cigar = "2M1D3M".to_alignment
cigar.complement.to_s # => "3M1I2M"
```

The current version of RGFA does not provide a way to compute the alignment in
RGFA, thus the trace information can be accessed and edited, but not used for
this purpose.  Because of this there is currently no way in RGFA to compute a
complement trace (trace obtained when the sequences are switched).

```ruby
trace = "1,2,3".to_alignment
trace.complement.to_s # => "*"
```

The complement of a placeholder is a placeholder:

```ruby
"*".to_alignment.complement.to_s # => "*"
```
