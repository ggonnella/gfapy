require_relative "field_parser"
require_relative "line"

class Object
  # @!macro [new] validate_gfa_field
  #   Validates the object according to the provided datatype
  #   @param datatype [RGFA::Line::FIELD_DATATYPE]
  #   @param fieldname [#to_s] Fieldname to use in the error msg
  #   @raise [RGFA::FormatError] if the object type or content
  #     is not compatible to the provided datatype
  #   @return [void]
  #   @api private
  def validate_gfa_field!(datatype, fieldname=nil)
    mod = RGFA::Field::FIELD_MODULE[datatype]
    if mod.nil?
      raise RGFA::TypeError,
        "Datatype unknown: #{datatype.inspect}"
    end
    mod::validate(self)
  end
end

#
# Methods to validate the string representations of the GFA fields data
# @api private
#
module RGFA::FieldValidator

  # Validates the string according to the provided datatype
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  # @param fieldname [#to_s] Fieldname to use in the error msg
  # @raise [RGFA::FormatError] if the string does not match
  #   the regexp for the provided datatype
  # @return [void]
  # @api private
  def validate_gfa_field!(datatype, fieldname=nil)
    mod = RGFA::Field::FIELD_MODULE[datatype]
    if mod.nil?
      raise RGFA::TypeError,
        "Datatype unknown: #{datatype.inspect}"
    end
    mod::validate_encoded(self)
  end

end

class String
  include RGFA::FieldValidator
end
