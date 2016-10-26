require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "cigar"
require_relative "trace"
require_relative "error"
require_relative "field"
require_relative "field_array"
require_relative "alignment"

#
# Methods to parse the string representations of the GFA fields
# @api private
#
module RGFA::FieldParser

  # Parses a tag in the form tagname:datatype:value
  # and parses the value according to the datatype
  # @raise [RGFA::FormatError] if the string does not represent
  #   a tag
  # @return [Array(Symbol, RGFA::Line::FIELD_DATATYPE, String)]
  #   the parsed content of the field
  def parse_gfa_tag
    if self =~ /^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$/
      return $1.to_sym, $2.to_sym, $3
    else
      raise RGFA::FormatError,
        "Expected GFA tag, found: #{self.inspect}"
    end
  end

  # Parse a string representation of a GFA field value
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  # @param safe [Boolean] use safe_decode or decode?
  # @param fieldname [String] fieldname, for error messages
  # @raise [RGFA::TypeError] if the specified datatype is unknown
  # @raise [RGFA::FormatError] if the string syntax is not valid
  # @raise [RGFA::ValueError] if the decoded value is not valid
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

end

class String
  include RGFA::FieldParser
end
