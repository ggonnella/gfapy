require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "cigar"

#
# Methods to parse the string representations of the GFA fields
#
module RGFA::FieldParser

  # data types which are not parsed if lazy mode is used
  DELAYED_PARSING_DATATYPES = [:cig, :cgs, :lbs, :H, :J, :B]

  # Parse a string representation of a GFA field value
  def parse_datastring(datatype, validate: true, lazy: true, fieldname: nil)
    validate_datastring(datatype, fieldname: fieldname) if validate
    return self if lazy and DELAYED_PARSING_DATATYPES.include?(datatype)
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
      return cigar_operations
    when :cgs
      return split(",").map{|c|c.cigar_operations}
    when :lbs
      return split(",").map{|l| [l[0..-2].to_sym,
                                 l[-1].to_sym].to_oriented_segment}
    else
      raise "Datatype unknown: #{datatype}"
    end
  end

  # Parses an optional field in the form tagname:datatype:value
  # and parses the value according to the datatype
  # @param validate_datastring [Boolean] validate the format of the value
  #   datastring using regular expressions
  # @raise [RGFA::FieldParser::FormatError] if the string does not represent
  #   an optional field
  # @return [Array(Symbol, Symbol, Object)] the parsed content of the field
  def parse_optfield(parse_datastring: :lazy, validate_datastring: true)
    if self =~ /^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$/
      n = $1.to_sym
      t = $2.to_sym
      v = $3
      v.validate_datastring(t, fieldname: n) if validate_datastring
      v = v.parse_datastring(t, validate: false,
            lazy: parse_datastring == :lazy) if parse_datastring
      return n, t, v
    else
      raise RGFA::FieldParser::FormatError,
        "Expected optional field, found: #{self.inspect}"
    end
  end
end

# Error raised if the field content has an invalid format
class RGFA::FieldParser::FormatError < TypeError; end

class String
  include RGFA::FieldParser
end
