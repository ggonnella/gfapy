require "json"
require_relative "alignment"
require_relative "byte_array"
require_relative "error"
require_relative "field_array"
require_relative "line"
require_relative "numeric_array"

RGFA::Field = Module.new

require_relative "field/alignment_gfa1.rb"
require_relative "field/alignment_gfa2.rb"
require_relative "field/alignment_list_gfa1.rb"
require_relative "field/byte_array.rb"
require_relative "field/char.rb"
require_relative "field/comment.rb"
require_relative "field/custom_record_type.rb"
require_relative "field/float.rb"
require_relative "field/generic.rb"
require_relative "field/identifier_gfa2.rb"
require_relative "field/identifier_list_gfa2.rb"
require_relative "field/oriented_identifier_list_gfa1.rb"
require_relative "field/oriented_identifier_list_gfa2.rb"
require_relative "field/integer.rb"
require_relative "field/json.rb"
require_relative "field/numeric_array.rb"
require_relative "field/optional_identifier_gfa2.rb"
require_relative "field/optional_integer.rb"
require_relative "field/orientation.rb"
require_relative "field/oriented_identifier_gfa2.rb"
require_relative "field/path_name_gfa1.rb"
require_relative "field/position_gfa1.rb"
require_relative "field/position_gfa2.rb"
require_relative "field/segment_name_gfa1.rb"
require_relative "field/sequence_gfa1.rb"
require_relative "field/sequence_gfa2.rb"
require_relative "field/string.rb"

# Decoding, validation and encoding of GFA fields.
#
# For each datatype a module under field/ exists, which defines
# the following methods as module functions:
#
# unsafe_decode => parses an ASSUMED VALID string representation to
#                  an appropriate Ruby object
#                  - faster or as fast as decode()
#                  - if the assumption is not met, sometimes it will
#                  raise an exception, sometimes it will return an
#                  invalid object
#
# decode => parses a string representation to an appropriate Ruby object
#           - if the string is invalid, an exception is raised
#           - the returned object is guaranteed to be valid
#
# validate_encoded => validates a string representation
#                     - raises RGFA::FormatError if invalid
#
# validate_decoded => validates a non-string field content
#                     - raises exception if its state is invalid
#
# unsafe_encode => encodes an ASSUMED VALID field to the string representation;
#                  - faster or as fast as encode()
#                  - if the assumption is not met, sometimes it will
#                  raise an exception, sometimes it will return an
#                  invalid string representation
#
# encode => encodes a field to its string representation;
#           - raises an exception if the field content is invalid
#           - the string representation is guaranteed to be valid;
#
# Everything in the RGFA::Field module is API private. The user will not call
# these methods directly, and use instead methods of RGFA::Line.
# Also: code in line.rb should not call the functions of the submodules
# defined in the field/* files directly, but rather call the functions of
# the submodules defined in this file, ie RGFA::Field::Parser,
# RGFA::Field::Validator, RGFA::Field::Writer.
#
# @api private
module RGFA::Field

  # Symbol representing a GFA1-specific datatype for positional fields
  GFA1_POSFIELD_DATATYPE = [
                             :alignment_gfa1,
                             :alignment_list_gfa1,
                             :oriented_identifier_list_gfa1,
                             :position_gfa1,
                             :segment_name_gfa1,
                             :sequence_gfa1,
                             :path_name_gfa1,
                           ]

  # Symbol representing a GFA2-specific datatype for positional fields
  GFA2_POSFIELD_DATATYPE = [
                             :alignment_gfa2,
                             :generic,
                             :identifier_gfa2,
                             :oriented_identifier_gfa2,
                             :identifier_list_gfa2,
                             :oriented_identifier_list_gfa2,
                             :optional_identifier_gfa2,
                             :position_gfa2,
                             :custom_record_type,
                             :sequence_gfa2,
                             :optional_integer,
                           ]

  # Symbol representing a datatype for positional fields common to GFA1 and GFA2
  GFAX_POSFIELD_DATATYPE = [:comment, :orientation]

  # Symbol representing a datatype for positional fields
  POSFIELD_DATATYPE = GFA1_POSFIELD_DATATYPE +
                      GFA2_POSFIELD_DATATYPE +
                      GFAX_POSFIELD_DATATYPE

  # A symbol representing a datatype for tags
  TAG_DATATYPE = [:A, :i, :f, :Z, :J, :H, :B]

  # A symbol representing a valid datatype
  FIELD_DATATYPE = TAG_DATATYPE + POSFIELD_DATATYPE

  FIELD_MODULE = {
    :alignment_gfa1                => RGFA::Field::AlignmentGFA1,
    :alignment_gfa2                => RGFA::Field::AlignmentGFA2,
    :alignment_list_gfa1           => RGFA::Field::AlignmentListGFA1,
    :comment                       => RGFA::Field::Comment,
    :custom_record_type            => RGFA::Field::CustomRecordType,
    :generic                       => RGFA::Field::Generic,
    :identifier_gfa2               => RGFA::Field::IdentifierGFA2,
    :identifier_list_gfa2          => RGFA::Field::IdentifierListGFA2,
    :oriented_identifier_list_gfa1 => RGFA::Field::OrientedIdentifierListGFA1,
    :oriented_identifier_list_gfa2 => RGFA::Field::OrientedIdentifierListGFA2,
    :optional_identifier_gfa2      => RGFA::Field::OptionalIdentifierGFA2,
    :oriented_identifier_gfa2      => RGFA::Field::OrientedIdentifierGFA2,
    :optional_integer              => RGFA::Field::OptionalInteger,
    :orientation                   => RGFA::Field::Orientation,
    :path_name_gfa1                => RGFA::Field::PathNameGFA1,
    :position_gfa1                 => RGFA::Field::PositionGFA1,
    :position_gfa2                 => RGFA::Field::PositionGFA2,
    :segment_name_gfa1             => RGFA::Field::SegmentNameGFA1,
    :sequence_gfa1                 => RGFA::Field::SequenceGFA1,
    :sequence_gfa2                 => RGFA::Field::SequenceGFA2,
    :H    => RGFA::Field::ByteArray,
    :A    => RGFA::Field::Char,
    :f    => RGFA::Field::Float,
    :i    => RGFA::Field::Integer,
    :J    => RGFA::Field::JSON,
    :B    => RGFA::Field::NumericArray,
    :Z    => RGFA::Field::String,
  }

  # Encoding of Ruby objects to GFA string representation
  # @api private
  module Writer

    # Encode a Ruby object into a GFA field. The ruby object can be
    # either an encoded GFA field (in which case, at most it is validated,
    # see +safe+, but not encoded) or an object of a class compatible
    # with the specified datatype, if a datatype is specified (see +datatype+),
    # e.g. Integer # for i fields.
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
    # @param line [#to_s] line content, for error messages (optional)
    # @raise [RGFA::TypeError] if the specified datatype is unknown
    # @raise [RGFA::FormatError] if the string syntax is not valid
    # @raise [RGFA::ValueError] if the decoded value is not valid
    def parse_gfa_field(datatype,
                        safe: true,
                        fieldname: nil,
                        line: nil)
      mod = RGFA::Field::FIELD_MODULE[datatype]
      if mod.nil?
        begin
          linemsg = line ? "Line content: #{line.to_s}\n" : ""
        rescue
          linemsg = ""
        end
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self}\n"
        raise RGFA::TypeError,
          linemsg +
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
        begin
          linemsg = line ? "Line content: #{line.to_s}\n" : ""
        rescue
          linemsg = ""
        end
        fieldnamemsg = fieldname ? "Field: #{fieldname}\n" : ""
        contentmsg = "Content: #{self}\n"
        datatypemsg = "Datatype: #{datatype}\n"
        raise err.class,
              linemsg +
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
    # @api private
    module Encoded
      def validate_gfa_field(datatype, fieldname=nil)
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
    # @api private
    module Decoded
      def validate_gfa_field(datatype, fieldname=nil)
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
# @api private
module RGFA::DefaultDatatypes

  module Object
    # @!macro [new] gfa_datatype
    #   GFA tag datatype to use, if none is provided
    #   @return [RGFA::Field::TAG_DATATYPE]
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
