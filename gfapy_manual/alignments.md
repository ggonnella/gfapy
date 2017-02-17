## Alignments

Some fields contain alignments and lists of alignments (L/C: overlap; P:
overlaps; E/F: alignment). If an alignment is not given, the placeholder symbol
```*``` is used instead.  In GFA1 the alignments can be given as CIGAR strings,
in GFA2 also as Dazzler traces.

Gfapy uses different classes (in module gfapy::Alignment) for representing the two
possible alignment styles (cigar strings and traces) and undefined alignments
(placeholders).

### Creating an alignment

An alignment instance is usually created from its GFA string representation
or from a list by using the ```gfapy.Alignment``` constructor.
If the argument is an alignment object it will be returned,
so that is always safe to call the method on a
variable which can contain a string or an alignment instance:

```python
gfapy.Alignment("*")        # => gfapy.AlignmentPlaceholder
gfapy.Alignment("10,10,10") # => gfapy.Trace
gfapy.Alignment([10,10,10]) # => gfapy.Trace
gfapy.Alignment("30M2I30M") # => gfapy.CIGAR
gfapy.Alignment(gfapy.Alignment("*"))
gfapy.Alignment(gfapy.Alignment("10,10"))
```

### Recognizing undefined alignments

The ```gfapy.is_placeholder()``` method allows to understand if an alignment
field contains a defined value (cigar, trace) or not (placeholder).
The method works correctly with both alignment objects and their string
or list representation.

```python
gfapy.is_placeholder(gfapy.Alignment("30M"))   # => False
gfapy.is_placeholder(gfapy.Alignment("10,10")) # => False
gfapy.is_placeholder(gfapy.Alignment("*"))     # => True
gfapy.is_placeholder("*") # => True
gfapy.is_placeholder("30M") # => False
gfapy.is_placeholder("10,10") # => True
gfapy.is_placeholder([]) # => True
gfapy.is_placeholder([10,10]) # => False
```

Note that, as a placeholder is False in boolean context, just a
```if not aligment``` will also work, if alignment is an alignment object,
but not if it is a string representation.

### Reading and editing CIGARs

CIGARs are represented by arrays of cigar operation objects.
Each cigar operation provides the properties ```length``` and
```code```. Length is the length of the CIGAR operation (int).
Code is one of the codes allowed by the GFA specification.

```python
cigar = gfapy.Alignment("30M")
isinstance(cigar, list) # => True
operation = cigar[0]
type(operation) # => "gfapy.CIGAR.Operation"
operation.code # => "M"
operation.code = "D"
operation.length # => 30
len(operation) # => 30
str(operation) # => "30D"
```

The CIGAR object can be edited using the list methods.
If the array is emptied, its string representation will be ```*```.
```python
cigar = gfapy.Alignment("1I20M2D")
cigar[0].code = "M"
cigar.pop(1)
str(cigar) # => "1M2D"
cigar[:] = []
str(Cigar) # => "*"
```

CIGARs consider one sequence as reference and another sequence
as query. The ```length_on_reference``` and ```length_on_query``` methods
compute the length of the alignment on the two sequences.
These methods are used by the library e.g. to convert GFA1 L lines to GFA2
E lines (which is only possible if CIGARs are provided).

```python
cigar = gfapy.Alignment("30M10D20M5I10M")
cigar.length_on_reference() # => 70
cigar.length_on_query() # => 65
```

#### Validation

The ```validate``` method checks if all operations in a cigar use
valid codes and length values (which must be non-negative)
The codes can be M, I, D or P. For GFA1 the other codes are formally accepted
(no exception is raised), but their use is discouraged.
An error is raised in GFA2 on validation, if the other codes are used.

```python
cigar = gfapy.Alignment("30M10D20M5I10M")
cigar.validate() # no exception raised
cigar[1].code = "L"
cigar.validate # raises an exception
cigar = gfapy.Alignment("30M10D20M5I10M")
cigar[1].code = "X"
cigar.validate(version="gfa1") # no exception raised
cigar.validate(version="gfa2") # exception raised
```

### Reading and editing traces

Traces are arrays of non-negative integers. The values are interpreted
using a trace spacing value. If traces are used, a trace spacing value must be
defined in a TS integer tag, either in the header, or in the single lines
which contain traces.

```python
gfa.header.TS    # => the global TS value
gfa.line("x").TS # => an edge''s own TS tag
```

### Complement alignment

CIGARs are dependent on which sequence is taken as reference and which is
taken as query. For each alignment, a complement CIGAR can be computed
(using the method ```complement```), which is the CIGAR obtained when the
two sequences are switched. This method is used by the library
e.g. to compare links, as they can be expressed in different ways, by
switching the two sequences.

```python
cigar = gfapy.Alignment("2M1D3M")
str(cigar.complement()) # => "3M1I2M"
```

The current version of gfapy does not provide a way to compute the alignment in
gfapy, thus the trace information can be accessed and edited, but not used for
this purpose. Because of this there is currently no way in gfapy to compute a
complement trace (trace obtained when the sequences are switched).

```python
trace = gfapy.Alignment("1,2,3")
str(trace.complement()) # => "*"
```

The complement of a placeholder is a placeholder:

```python
str(gfapy.Alignment("*").complement()) # => "*"
```
