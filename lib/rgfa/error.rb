# Parent class for library-specific errors
class RGFA::Error < StandardError; end

# unknown/wrong version of the specification
class RGFA::VersionError < RGFA::Error; end

# the user tried to do something not allowed
class RGFA::RuntimeError < RGFA::Error; end

# an object has the right type/form, but an invalid content
# e.g. number out-of-range; string/array too big/small;
#      enum-like symbol not in allowed values list
class RGFA::ValueError < RGFA::Error; end

# the format of an object is invalid
# e.g. a line contains too many/few fields;
#      a tagname has the wrong format
class RGFA::FormatError < RGFA::Error; end

# a wrong type has been used or specified;
# e.g. a field contains an array instead of an integer;
#      an invalid record type or datatype is found by parsing
class RGFA::TypeError < RGFA::Error; end

# the argument of a method has the wrong type
class RGFA::ArgumentError < RGFA::Error; end

# an element which should have been unique is not unique
# e.g. a tag name is duplicated in a line;
#      a duplicated record ID is found
class RGFA::NotUniqueError < RGFA::Error; end

# contradictory information has been provided;
# e.g. GFA1 segment LN and sequence length differ;
#      a GFA2-only record is added to a GFA1 file
class RGFA::InconsistencyError < RGFA::Error; end

# an element which has been required is not found
# e.g. a tag! method has been used and the tag is not set;
#      a record finder ! method does not find the record
class RGFA::NotFoundError < RGFA::Error; end
