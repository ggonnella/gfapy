## Extending RGFA

The RGFA library is designed to be easily extended, although its extensions
requires more knowledge of the Ruby languange, than what is necessary for
merely using the library.

The GFA2 format can be extended by defining new line types.  These are handled
using the custom records functionality, but the support is limited: e.g.
validation, parsing of the field content, references to other lines and access
to fields by name are not possible. All this is made possible by extensions.

### An example of user-specific record types

This chapter gives an example on how to extend the
library to define an user-specific record type and custom field datatypes.
As an example, we will define a record type for metagenomics applications
with code M. This will have the role to define taxon-specific subgraphs,
by putting segments in relation with a taxon. The taxa themselves
will be declared in lines with code T:

Each T line will contain:
- tid: a taxon ID
- name: an organism name (text field)
- the tags may contain an URL tag, which will point to a website,
  describing the organism (UL tag, string)

Each M line will contain:
- mid: an optional assignment ID
- tid: a taxon ID
- sid: a reference to a segment
- score: an optional Phred-style integer score, which will define an error
         probability of the assignment of the segment to a taxon

Here is an example of GFA containing the new line types:
```
S A 1000 *
T B12_c
M 1 taxon:123 A 40 xx:Z:cjaks536
M 2 taxon:123 B * xx:Z:cga5r5cs
S B 1000 *
M * B12_c B 20
T taxon:123 UL:http://www.taxon123.com
```

### Subclassing RGFA::Line

Defining a new record type for RGFA requires to create a new subclass of
the RGFA::Line class.
Thereby some constants must be defined:

- ```RECORD_TYPE``` must contain the record type as symbol.
- ```POSFIELDS``` is an array of symbols, indicating the sequence
 of positional fields in the record
- ```PREDEFINED_TAGS``` contain an array of predefined optional
  tag names.
- ```DATATYPE``` is an hash. Each key is a symbol, either contained in
  POSFIELDS or in PREDEFINED_TAGS. The value is a datatype symbol:
  see the RGFA::Field module for a list of possible datatypes.
  - ```FIELD_ALIAS``` ia an hash which contain aliases to field names;
it may be empty
- ```REFERENCE_FIELDS``` is a list of fields which contain references
  (or arrays of references) to other lines. The references may contain
  an orientation.
- ```BACKREFERENCE_RELATED_FIELDS``` is a list of fields which shall
  not be changed in a connected line without potentially invaliding
  backreferences to the line. In the predefined line types, these are
  the fields containing match coordinates in GFA2 edges (as they change their
  nature as internal, dovetails or containments) and the orientation and overlap
  fields in GFA1 links.
- ```DEPENDENT_LINES``` and ```OTHER_REFERENCES``` are lists
  of names of references collections, which will
  contain backreferences to other line types (which refer the line type in their
  fields). E.g. for a segment, the list contain the ```:fragments``` symbol,
  indicating that a collection
  shall be initialized, which will contain backreferences to the fragments
  which reference the segment.
  Disconnection is cascaded to lines in the collections named in
  DEPENDENT_LINES but not to those named in OTHER_REFERENCES.

For our example, we will define the subclasses for record types T and M.

```ruby
class RGFA::Line::Taxon < RGFA::Line

  RECORD_TYPE = :T
  POSFIELDS = [:tid, :desc]
  PREDEFINED_TAGS = [:UL]
  DATATYPE = {
    :tid => :identifier_gfa2,
    :desc => :Z,
    :UL => :Z,
  }
  FIELD_ALIAS = {:name => :tid}
  REFERENCE_FIELDS = []
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = [:metagenomic_assignments]
  OTHER_REFERENCES = []

  apply_definitions

end

class RGFA::Line::MetagenomicAssignment < RGFA::Line

  RECORD_TYPE = :M
  POSFIELDS = [:mid, :tid, :sid, :score]
  PREDEFINED_TAGS = []
  DATATYPE = {
    :mid => :optional_identifier_gfa2,
    :tid => :identifier_gfa2,
    :sid => :identifier_gfa2,
    :score => :optional_integer,
  }
  FIELD_ALIAS = {:name => :mid}
  REFERENCE_FIELDS = [:tid, :sid]
  BACKREFERENCE_RELATED_FIELDS = []
  DEPENDENT_LINES = []
  OTHER_REFERENCES = []

  apply_definitions

end
```

### Enabling the references

If reference fields have been defined (as in the previous example of M, where
tid is a reference to a taxon line and sid is a reference to a segment line),
a private ```initialize_references```
method shall be provided, which is called when a line of the type is connected
to a RGFA instance.

In particular, the method shall change all identifiers in the reference
fields into references to lines in the GFA (either existing lines or
virtual lines, which is the way RGFA handles forward-pointing references).

If the referenced line is not yet available, but it may be defined by
the GFA at a later time, the method will create a virtual line.
In our example, we know that the reference is to a segment or a taxon line.
If we would not know that we would instantiate RGFA::Line::Unknown.

When the field content itself is a reference, the content cannot be
changed directly (using set would raise an exception, as the line is
already connected when the initialize_referneces method is called).
Therefore, the private line method set_existing_field shall be used,
with ```set_reference: true```. If the reference field contains
an oriented line or an array instead, references can be edited directly.

```ruby
class RGFA::Line::MetagenomicAssignment

  def initialize_references
    s = @rgfa.segment(sid)
    if s.nil?
      s = RGFA::Line::Segment::GFA2.new([sid.to_s, "1", "*"],
                                        virtual: true, version: :gfa2)
      s.connect(@rgfa)
    end
    set_existing_field(:sid, s, set_reference: true)
    s.add_reference(self, :metagenomic_assignments)

    t = @rgfa.search_by_name(tid)
    if t.nil?
      t = RGFA::Line::Taxon.new([tid.to_s, ""],
                                virtual: true, version: :gfa2)
      t.connect(@rgfa)
    end
    set_existing_field(:tid, t, set_reference: true)
    t.add_reference(self, :metagenomic_assignments)
  end
  private :initialize_references

end
```

The method defined backreferences to the new line in the
segment and taxon instances, using :metagenomic_assignments as name for the collection
of backreferences in S or T lines to lines of type M. For taxa, this collection
has been defined in the class definition above. For segments, we will need to
add this collection to the segment definition and redefine the reference getters
methods. As lines of type M will be dependent on S lines
(ie they shall be deleted if the referred segment line is deleted), we will
add it to the DEPENDENT_LINES list. In case of no dependency, we would use the
OTHER_REFERENCES list instead.

```ruby
class RGFA::Line::Segment::GFA2
  DEPENDENT_LINES << :metagenomic_assignments
  define_reference_getters
end
```

### Recognizing the record type code

When parsing lines starting with the code for the new record type,
we want RGFA to return an instance of the correct subclass of Line.

To obtain this, the ```subclass``` class Method of ```RGFA::Line``` must
be extended to handle the new record_type symbol, for GFA2 or
unknown version records. It must return a class (the new subclass of RGFA::Line).
The new record symbols must also be added to the gfa2 specific
symbols list in ```RECORD_TYPE_VERSIONS[:specific][:gfa2]```.

In our example the method ```subclass``` will be patched as follows:

```ruby
class RGFA::Line
  class << self
    alias_method :orig_subclass, :subclass
    def subclass_GFA2(record_type, version: nil)
      if version.nil? or version == :gfa2
        case record_type.to_sym
        when :M then return RGFA::Line::MetagenomicAssignment
        when :T then return RGFA::Line::Taxon
        end
      end
      orig_subclass(record_type, version: version)
    end
  end
  RECORD_TYPE_VERSIONS[:specific][:gfa2] << :M
  RECORD_TYPE_VERSIONS[:specific][:gfa2] << :T
end
```

### Allowing to find records

Both record types T and M define a name field.
This allows to find record of the types using the ```search_by_name```
method, as well as allowing to replace virtual T lines created
while parsing M lines, with real T lines, when these are found.
For this to work, the codes must be added to the list
```RECORDS_WITH_NAME``` of the ```RGFA``` class:

```ruby
RGFA::RECORDS_WITH_NAME << :T
RGFA::RECORDS_WITH_NAME << :M
```

### Defining a field datatype

When new subclasses of line are created, it may be necessary or useful to
create new datatypes for its fields. For example, we used :identifier_gfa2 for
the tid field in the M and T records. However, we could made the field syntax
stricter, and require that the content of the field must be either a reference
to the NCBI taxonomy database or a custom identifier.  In the first case, it
will need to be in the form ```taxon:<n>```, where ```<n>``` is a positive
integer. In the second case, it will need to be a combination of letters,
numbers and underscores (thereby ```:``` will not be allowed).

A module must be created, which handles the parsing and writing of fields with
the new datatype.
The module shall define six module functions
(see the API documentation of the RGFA::Field module for more detail).
Decode and unsafe_decode take a string as
argument and return an appropriate Ruby object.  Encode and unsafe_encode take
a string representation or another ruby object and converts it into the correct
string representation.  Validate_encoded validates the string representation.
Validate_decoded validates a non-string content of the field.  The unsafe
version of the decode and encode methods may provide faster results and are
used if the parameters are guaranteed to be valid. The safe version must check
the validity of the provided data.

```ruby
module RGFA::Field::TaxonID

  def validate_encoded(string)
    if string !~ /^taxon:(\d+)$/ and string !~ /^[a-zA-Z0-9_]+$/
      raise RGFA::ValueError, "Invalid taxon ID: #{string}"
    end
  end
  module_function :validate_encoded

  def unsafe_decode(string)
    string.to_sym
  end
  module_function :unsafe_decode

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end
  module_function :decode

  def validate_decoded(object)
    case object
    when RGFA::Line::Taxon
      validate_encoded(object.name.to_s)
    when Symbol
      validate_encoded(object.to_s)
    else
      raise RGFA::TypeError,
        "Invalid type for taxon ID: #{object.inspect}"
    end
  end
  module_function :validate_decoded

  def unsafe_encode(object)
    object = object.name if object.kind_of?(RGFA::Line::Taxon)
    object.to_s
  end
  module_function :unsafe_encode

  def encode(object)
    validate_decoded(object)
    unsafe_encode(object)
  end
  module_function :encode

end
```

The new datatype must have a symbol which identifies it.  The symbol must be
added to the ```GFA2_POSFIELD_DATATYPE``` list of the ```RGFA::Field``` module.
An entry must be added to the ```RGFA::Field::FIELD_MODULE```
hash, where the symbol of the new datatype is the key and the value is the
module.

```ruby
RGFA::Field::GFA2_POSFIELD_DATATYPE << :taxon_id
RGFA::Field::FIELD_MODULE[:taxon_id] = RGFA::Field::TaxonID
```

Now the new datatype can be put into use by changing the datatype for the tid
fields of the M and T lines:

```ruby
RGFA::Line::Taxon::DATATYPE[:tid] = :taxon_id
RGFA::Line::MetagenomicAssignment::DATATYPE[:tid] = :taxon_id
```
