require "json"
require_relative "alignment"
require_relative "byte_array"
require_relative "cigar"
require_relative "error"
require_relative "field_array"
require_relative "line"
require_relative "numeric_array"
require_relative "trace"

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
require_relative "field/path_name.rb"
require_relative "field/position_gfa1.rb"
require_relative "field/position_gfa2.rb"
require_relative "field/record_type.rb"
require_relative "field/segment_name.rb"
require_relative "field/sequence_gfa1.rb"
require_relative "field/sequence_gfa2.rb"
require_relative "field/string.rb"

# Decoding, validation and encoding of GFA fields.
# @api private
#
# For each datatype a module under field/ exists, which defines
# the following methods as module functions:
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
# Everything in the RGFA::Field module is API private. The user will not call
# these methods directly, and use instead methods of RGFA::Line.
# Also: code in line.rb should not call the functions of the submodules
# defined in the field/* files directly, but rather call the functions of
# the submodules defined in this file, ie RGFA::Field::Parser,
# RGFA::Field::Validator, RGFA::Field::Writer.
#
module RGFA::Field

  # Symbol representing a GFA1-specific datatype for positional fields
  GFA1_POSFIELD_DATATYPE = [:cig, :cgs, :lbs, :pos, :lbl, :seq, :ptn]

  # Symbol representing a GFA2-specific datatype for positional fields
  GFA2_POSFIELD_DATATYPE = [:aln, :any, :idn, :oid, :psn, :crt, :sqn]

  # Symbol representing a datatype for positional fields common to GFA1 and GFA2
  GFAX_POSFIELD_DATATYPE = [:cmt, :orn]

  # Symbol representing a datatype for positional fields
  POSFIELD_DATATYPE = GFA1_POSFIELD_DATATYPE +
                      GFA2_POSFIELD_DATATYPE +
                      GFAX_POSFIELD_DATATYPE

  # A symbol representing a datatype for tags
  TAG_DATATYPE = [:A, :i, :f, :Z, :J, :H, :B]

  # A symbol representing a valid datatype
  FIELD_DATATYPE = TAG_DATATYPE + POSFIELD_DATATYPE

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
    :ptn => RGFA::Field::PathName,
    :pos => RGFA::Field::PositionGFA1,
    :psn => RGFA::Field::PositionGFA2,
    :crt => RGFA::Field::RecordType,
    :lbl => RGFA::Field::SegmentName,
    :seq => RGFA::Field::SequenceGFA1,
    :sqn => RGFA::Field::SequenceGFA2,
    :Z   => RGFA::Field::String,
  }

  # Encoding of Ruby objects to GFA string representation
  # @api private
  module Writer

    # Encode a Ruby object into a GFA field. The ruby object can be
    # either an encoded GFA field (in which case, at most it is validated,
    # see +safe+, but not encoded) or an object of a class compatible
    # with the specified datatype, if a datatype is specified (see +datatype+),
    # e.g. Integer # for i fields.
    # @api private
    # @param datatype [RGFA::Field::FIELD_DATATYPE] datatype to use. If no
    #   datatype is specified, any class will do and the default datatype
    #   will be chosen (see RGFA::DefaultDatatype module).
    # @param fieldname [String] fieldname, for error messages (optional)
    # @param safe [Boolean] <i>(defaults to: +true+)</i> if +true+, the safe
    #   version of the encode function is used, which guarantees that the
    #   resulting data is valid; if +false+, the unsafe version is used,
    #   which, for some datatypes, skips validations in order to be faster
    #   than the safe version
    # @raise [RGFA::TypeError] if an unknown datatype is specified
    # @raise [RGFA::ValueError] if the object value is invalid for the datatype
    # @raise [RGFA::FormatError] if the object syntax is invalid for the
    #   datatype (eg for invalid encoded strings, if +safe+ is set)
    # @raise [RGFA::TypeError] if the type of the object and the datatype
    #   are not compatible
    def to_gfa_field(datatype: nil, safe: true, fieldname: nil)
      datatype ||= default_gfa_tag_datatype
      mod = RGFA::Field::FIELD_MODULE[datatype]
      if mod.nil?
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self.inspect}\n"
        raise RGFA::TypeError,
          fieldnamemsg +
          contentmsg +
          "Datatype unknown: #{datatype.inspect}"
      end
      begin
        if safe
          mod.encode(self)
        else
          mod.unsafe_encode(self)
        end
      rescue => err
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self.inspect}\n"
        datatypemsg = "Datatype: #{datatype}\n"
        raise err.class,
              fieldnamemsg +
              datatypemsg +
              contentmsg +
              err.message
      end
    end

    # Representation of the data as a GFA tag +xx:d:content+, where +xx+ is
    # the tag name and +d+ is the datatype.
    # @param fieldname [Symbol] the tag name
    # @param datatype [RGFA::Field::TAG_DATATYPE] (<i>defaults to: the value
    #  returned by {#default_gfa_tag_datatype}</i>)
    # @api private
    def to_gfa_tag(fieldname, datatype: default_gfa_tag_datatype)
      return "#{fieldname}:#{datatype}:"+
      "#{to_gfa_field(datatype: datatype, fieldname: fieldname)}"
    end
  end

  # Decoding of the GFA string representations into Ruby objects
  # @api private
  module Parser

    # Parse a GFA string representation and decodes it into a Ruby object
    # @param datatype [RGFA::Field::FIELD_DATATYPE] the datatype to use
    # @param safe [Boolean] <i>(defaults to: +true+)</i> if +true+ the safe
    #   version of the decode function for the datatype is used, which
    #   validates the content of the string; if +false+, the string is
    #   assumed to be valid and decoded into a value accordingly, which may
    #   result in invalid values (but may be faster than the safe decoding)
    # @param fieldname [String] fieldname, for error messages (optional)
    # @raise [RGFA::TypeError] if the specified datatype is unknown
    # @raise [RGFA::FormatError] if the string syntax is not valid
    # @raise [RGFA::ValueError] if the decoded value is not valid
    # @api private
    def parse_gfa_field(datatype,
                        safe: true,
                        fieldname: nil)
      mod = RGFA::Field::FIELD_MODULE[datatype]
      if mod.nil?
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self}\n"
        raise RGFA::TypeError,
          fieldnamemsg +
          contentmsg +
          "Datatype unknown: #{datatype.inspect}"
      end
      begin
        if safe
          mod.decode(self)
        else
          mod.unsafe_decode(self)
        end
      rescue => err
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self}\n"
        datatypemsg = "Datatype: #{datatype}\n"
        raise err.class,
              fieldnamemsg +
              datatypemsg +
              contentmsg +
              err.message
      end
    end

    # Parses a GFA tag in the form +xx:d:content+ into its components.
    # The +content+ is not decoded (see #parse_gfa_field).
    # @raise [RGFA::FormatError] if the string does not represent
    #   a valid GFA tag
    # @return [Array(Symbol, RGFA::Field::FIELD_DATATYPE, String)]
    #   the parsed content of the field
    # @api private
    def parse_gfa_tag
      if self =~ /^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$/
        return $1.to_sym, $2.to_sym, $3
      else
        raise RGFA::FormatError,
          "Expected GFA tag, found: #{self.inspect}"
      end
    end

  end

  # Validates the content of a GFA field, which can be a GFA string
  # representation or a Ruby object, according to the field datatype.
  # @api private
  module Validator

    # Validates a GFA string representation according to the field datatype.
    # @!macro [new] validate_gfa_field
    #   @raise [RGFA::TypeError] if an unknown datatype is specified
    #   @param datatype [RGFA::Field::FIELD_DATATYPE] the datatype to use
    #   @param fieldname [String] fieldname, for error messages (optional)
    #   @raise [RGFA::FormatError] if the object type or content
    #     is not compatible to the provided datatype
    #   @return [void]
    #   @api private
    module Encoded
      def validate_gfa_field!(datatype, fieldname=nil)
        mod = RGFA::Field::FIELD_MODULE[datatype]
        if mod.nil?
          raise RGFA::TypeError,
            "Datatype unknown: #{datatype.inspect}"
        end
        mod::validate_encoded(self)
      end
    end

    # Validates a non-string Ruby object field content
    # according to the field datatype.
    # @!macro validate_gfa_field
    module Decoded
      def validate_gfa_field!(datatype, fieldname=nil)
        mod = RGFA::Field::FIELD_MODULE[datatype]
        if mod.nil?
          raise RGFA::TypeError,
            "Datatype unknown: #{datatype.inspect}"
        end
        mod::validate_decoded(self)
      end
    end

  end

end

class Object
  include RGFA::Field::Writer
  include RGFA::Field::Validator::Decoded
end

class String
  include RGFA::Field::Parser
  include RGFA::Field::Validator::Encoded
end

#
# This module specifies default datatypes for GFA tags
# for the core classes.
#
# Custom classes shall define the default_gfa_tag_datatype
# function in their class definition and not here.
#
module RGFA::DefaultDatatypes

  module Object
    # @!macro [new] gfa_datatype
    #   GFA tag datatype to use, if none is provided
    #   @return [RGFA::Field::TAG_DATATYPE]
    #   @api private
    def default_gfa_tag_datatype; :Z; end
  end

  module Fixnum
    # @!macro gfa_datatype
    def default_gfa_tag_datatype; :i; end
  end

  module Float
    # @!macro gfa_datatype
    def default_gfa_tag_datatype; :f; end
  end

  module Hash
    # @!macro gfa_datatype
    def default_gfa_tag_datatype; :J; end
  end

  module Array
    # @!macro gfa_datatype
    def default_gfa_tag_datatype
      (all?{|i|i.kind_of?(Integer)} or all?{|i|i.kind_of?(Float)}) ? :B : :J
    end
  end

end

class Object; include RGFA::DefaultDatatypes::Object; end
class Fixnum; include RGFA::DefaultDatatypes::Fixnum; end
class Float;  include RGFA::DefaultDatatypes::Float;  end
class Hash;   include RGFA::DefaultDatatypes::Hash;   end
class Array;  include RGFA::DefaultDatatypes::Array;  end
