require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "cigar"
require_relative "error"
require_relative "field_array"

#
# Methods to parse the string representations of the GFA fields
# @api private
#
module RGFA::FieldParser

  # Parse a string representation of a GFA field value
  # @raise [RGFA::Error] if the value is not valid
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  def parse_gfa_field(datatype: nil,
                      validate_strings: true,
                      fieldname: nil,
                      frozen: false)
    case datatype
    when :A, :Z, :seq
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      self.freeze if frozen
      return self
    when :lbl, :orn
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      return to_sym.freeze
    when :i
      return Integer(self)
    when :pos
      value = Integer(self)
      raise RGFA::FieldParser::FormatError if value < 0
      return value
    when :f
      return Float(self)
    when :H
      value = to_byte_array
      value.freeze if frozen
      return value
    when :B
      value = to_numeric_array
      value.freeze if frozen
      return value
    when :J
      value = JSON.parse(self)
      # RGFA convention for array of fields
      if value.kind_of?(Array) and value.rgfa_field_array?
        value = value.to_rgfa_field_array
      end
      # no need to freeze, as any Hash or Array will be valid
      return value
    when :cig
      value = to_cigar
      value.freeze if frozen
      return value
    when :cgs
      value = split(",").map do |c|
        c = c.to_cigar
        c.freeze if frozen
        c
      end
      value.freeze if frozen
      return value
    when :lbs
      value = split(",").map do |l|
        o = l[-1].to_sym
        l = l[0..-2]
        if validate_strings
          l.validate_gfa_field!(:lbl, fieldname: "#{fieldname} "+
                               "(entire field content: #{self})" )
        end
        os = [l.to_sym, o].to_oriented_segment
        os.freeze if frozen
        os
      end
      value.freeze if frozen
      return value
    else
      raise RGFA::FieldParser::UnknownDatatypeError,
        "Datatype unknown: #{datatype.inspect}"
    end
  end

  # Parses an optional field in the form tagname:datatype:value
  # and parses the value according to the datatype
  # @raise [RGFA::FieldParser::FormatError] if the string does not represent
  #   an optional field
  # @return [Array(Symbol, RGFA::Line::FIELD_DATATYPE, String)]
  #   the parsed content of the field
  def parse_gfa_optfield
    if self =~ /^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$/
      return $1.to_sym, $2.to_sym, $3
    else
      raise RGFA::FieldParser::FormatError,
        "Expected optional field, found: #{self.inspect}"
    end
  end
end

# Error raised if the field content has an invalid format
class RGFA::FieldParser::FormatError < RGFA::Error; end

# Error raised if an unknown datatype symbol is used
class RGFA::FieldParser::UnknownDatatypeError < RGFA::Error; end

class String
  include RGFA::FieldParser
end
