## Placeholders

Some positional fields may contain an undefined value S: sequence; L/C:
overlap; P: overlaps; E: eid, alignment; F: alignment; G: gid, var; U/O: pid.
In GFA this value is represented by a ```*```.

In RGFA instances of the class RGFA::Placeholder (and its subclasses) represent
the undefined value.

### Distinguishing placeholders

The method #placeholder? is defined for placeholders and all classes whose
instances can be used as a value for fields where a placeholder is allowed.  It
allows to check if a value is a placeholder instance or an equivalent value
(such as an empty array, or the string representation of the placeholder).

### Compatibility methods

Some methods are defined for placeholders, which allow them to respond to the
same methods as defined values. For example, for all placeholders, #empty?
returns true; #validate does nothing; #length returns 0; #[] returns self; #+
returns self. Thus in many cases the code can be written in a generic way,
without explicitely handling the different cases where a value is a placeholder
or not.

### Summary of API methods related to placeholders

```ruby
RGFA::Placeholder#to_s
RGFA::Placeholder#placeholder?
String/Symbol/Array/(other classes)#placeholder? # XXX
RGFA::Placeholder#empty?
RGFA::Placeholder#validate
RGFA::Placeholder#length
RGFA::Placeholder#[]
RGFA::Placeholder#+
```

