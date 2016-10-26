RGFA::Field = Module.new

require_relative "field/alignment_gfa1.rb"
require_relative "field/alignment_gfa2.rb"
require_relative "field/byte_array.rb"
require_relative "field/char.rb"
require_relative "field/cigars_list.rb"
require_relative "field/comment.rb"
require_relative "field/float.rb"
require_relative "field/generic.rb"
require_relative "field/identifier.rb"
require_relative "field/integer.rb"
require_relative "field/json.rb"
require_relative "field/numeric_array.rb"
require_relative "field/optional_identifier.rb"
require_relative "field/orientation.rb"
require_relative "field/oriented_segments.rb"
require_relative "field/position_gfa1.rb"
require_relative "field/position_gfa2.rb"
require_relative "field/record_type.rb"
require_relative "field/segment_name.rb"
require_relative "field/sequence_gfa1.rb"
require_relative "field/sequence_gfa2.rb"
require_relative "field/string.rb"

# For each datatype the following methods are defined:
#
# unsafe_decode => parse the string representation, and return
#                  an appropriate Ruby object; it may raise an exception,
#                  if the content is not valid; however, it is not
#                  guaranteed that the content is valid;
#                  either it is faster than decode, or it is an alias for decode
#
# decode => parse the string representation, and return
#           an appropriate Ruby object; it raises an exception
#           if the content is not valid; it is guaranteed
#           that the content is valid
#
# validate_encoded => validates the string representation; raises
#                     RGFA::FormatError if invalid
#
# validate_decoded => validates the object, which the user guarantees
#                     to be of a Ruby type returned by decode
#                     for the field datatype (eg Integer for "i")
#
# validate => if the object is a string, it calls validate_encoded;
#             otherwise validates the object, eventually calling
#             encode internally, thus it is not meant to be called
#             immediately before encode (use safe_encode instead);
#             it raises RGFA::TypeError if the object is not of a compatible
#             class; it raises RGFA::FormatError or RGFA::ValueError
#             if the class is compatible with field, but the value is not
#             (wrong format or wrong value range)
#
# unsafe_encode => convert an object into the string representation;
#                  there is no guarantee that the conversion leads to
#                  a valid field; it may raise an exception if invalid;
#                  either it is faster than encode, or it is an alias for encode
#
# encode => convert an object into the string representation;
#           the string representation is guaranteed to be valid;
#           if raises an exception if the object is invalid
#

module RGFA::Field

  FIELD_MODULE = {
    :cig => RGFA::Field::AlignmentGFA1,
    :aln => RGFA::Field::AlignmentGFA2,
    :H   => RGFA::Field::ByteArray,
    :A   => RGFA::Field::Char,
    :cgs => RGFA::Field::CigarsList,
    :cmt => RGFA::Field::Comment,
    :f   => RGFA::Field::Float,
    :any => RGFA::Field::Generic,
    :idn => RGFA::Field::Identifier,
    :i   => RGFA::Field::Integer,
    :J   => RGFA::Field::JSON,
    :B   => RGFA::Field::NumericArray,
    :oid => RGFA::Field::OptionalIdentifier,
    :orn => RGFA::Field::Orientation,
    :lbs => RGFA::Field::OrientedSegments,
    :pos => RGFA::Field::PositionGFA1,
    :psn => RGFA::Field::PositionGFA2,
    :crt => RGFA::Field::RecordType,
    :lbl => RGFA::Field::SegmentName,
    :seq => RGFA::Field::SequenceGFA1,
    :sqn => RGFA::Field::SequenceGFA2,
    :Z   => RGFA::Field::String,
  }

end
