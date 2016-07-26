require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "cigar"
require_relative "error"

#
# Methods to parse the string representations of the GFA fields
#
module RGFA::FieldParser

  # Parse a string representation of a GFA field value;
  # it is assumed that the string is valid with respect to the
  # specified +datatype+.
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  def parse_datastring(datatype)
    case datatype
    when :A, :Z, :seq
      return self
    when :lbl, :orn
      return to_sym
    when :i, :pos
      return Integer(self)
    when :f
      return Float(self)
    when :H
      return to_byte_array
    when :B
      return to_numeric_array
    when :J
      return JSON.parse(self)
    when :cig
      return to_cigar
    when :cgs
      return split(",").map{|c|c.to_cigar}
    when :lbs
      return split(",").map{|l| [l[0..-2].to_sym,
                                 l[-1].to_sym].to_oriented_segment}
    else
      raise RGFA::FieldParser::UnknownDatatypeError,
        "Datatype unknown: #{datatype}"
    end
  end

  # Parses an optional field in the form tagname:datatype:value
  # and parses the value according to the datatype
  # @raise [RGFA::FieldParser::FormatError] if the string does not represent
  #   an optional field
  # @return [Array(Symbol, RGFA::Line::FIELD_DATATYPE, String)]
  #   the parsed content of the field
  def parse_optfield
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
