## Position fields

The only position field in GFA1 is the ```pos``` field in the
C lines. This represents the starting position of the contained segment
in the container segment and is 0-based.

Some fields in GFA2 E lines (```beg1, beg2, end1, end2```) and
F lines (```s_beg, s_end, f_beg, f_end```) are positions.
According to the specification, they are 0-based and represent
virtual ticks before and after each symbol in the sequence.
Thus ranges are represented similarly to the Python range conventions:
e.g. a 1-character prefix of a sequence will have begin 0 and end 1.

### GFA2 last position symbol

The GFA2 positions must contain an additional symbol (```$```) appended to the
integer, if (and only if) they are the last position in the segment sequence.
These particular positions are represented in RGFA as instances of the class
RGFA::LastPos.

To create a lastpos instance, ```to_lastpos``` can be called on
an integer, or ```to_pos``` can be called on the string representation:
```ruby
12.to_lastpos # => RGFA::LastPos with value 12
"12".to_pos   # => 12
"12$".to_pos  # => RGFA::LastPos with value 12
```

Subtracting an integer from a lastpos returns a lastpos if 0 subtracted,
an integer otherwise. This allows to do some arithmetic on positions
without making them invalid.
```ruby
12.to_lastpos - 0 # => RGFA::LastPos(value: 12)
12.to_lastpos - 1 # 11
```

The methods first? and last? allow to determine if a position value
is 0 (first?), or if it is a last position (last?), using the
same syntax fo lastpos and integer instances.
```ruby
0.first?  # true
0.last?   # false
12.first? # false
12.last?  # false
"12".to_pos.first? # false
"12$".to_pos.last? # true
```
### Summary of position-related API methods

```
String#to_pos
Integer#to_lastpos
Integer/RGFA::LastPos#first?
Integer/RGFA::LastPos#last?
RGFA::LastPos.-
```

