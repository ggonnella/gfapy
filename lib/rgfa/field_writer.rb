require "json"
require_relative "byte_array"
require_relative "numeric_array"

#
# Methods to convert ruby objects to the GFA string representations
#
# The default conversion is implemented in this module, which is included in
# Object; single classes may overwrite the following methods, if necessary:
# - #gfa_datatype, which returns the symbol of the optional field GFA datatype
#   to use, if none is specified (See RGFA::Line::FIELD_DATATYPE);
#   the default is :Z
# - #to_gfa_datastring(datatype) should return a GFA string representation,
#   eventually depending on the specified datatype; no validation is done;
#   the default is #to_s
#
module RGFA::FieldWriter
  # Representation of an object as GFA field
  # @return [String] the GFA field content
  # @param datatype [RGFA::Line::FIELD_DATATYPE, nil] <i>(default: +nil+)
  #   one of the provided GFA datatypes;
  #   if +nil+, it is determined using the #gfa_datatype method
  # @param validate [Boolean] <i>(default: +true+)</i>
  #   validate the data string using the predefined regular
  #   expression, depending on the datatype
  #   (RGFA::FieldValidator::DATASTRING_VALIDATION_REGEXP)
  # @param fieldname [Symbol, nil] <i>(default: +nil+)</i>
  #   fieldname to use for error messages and for the
  #   output if +optfield+ is true
  # @param optfield [Boolean] <i>(default: +false+)</i>
  #   if true, the output will contain
  #   field name, datatype symbol and datastring joined by +:+;
  #   otherwise only the datastring is returned
  def to_gfa_field(datatype: nil, validate: true,
                  fieldname: nil, optfield: false)
    datatype ||= self.gfa_datatype
    s = to_gfa_datastring(datatype)
    s.validate_datastring(datatype, fieldname: fieldname) if validate
    return optfield ? "#{fieldname}:#{datatype}:#{s}" : s
  end

  # @!macro [new] to_gfa_datastring
  #   Representation of the data for GFA fields; this method
  #   does not automatically validate the string.
  #   @return [String]
  #   @param datatype [RGFA::Line::FIELD_DATATYPE]
  def to_gfa_datastring(datatype)
    to_s
  end

  # @!macro [new] gfa_datatype
  #   Optional field GFA datatype to use, if none is provided
  #   @return [RGFA::Line::FIELD_DATATYPE]
  def gfa_datatype; :Z; end
end

class Object
  include RGFA::FieldWriter
end

#
# Support of the conversion to GFA datastrings for Integer
#
class Integer
  #!macro gfa_datatype
  def gfa_datatype; :i; end
end

#
# Support of the conversion to GFA datastrings for Float
#
class Float
  #!macro gfa_datatype
  def gfa_datatype; :f; end
end

#
# Support of the conversion to GFA datastrings for Hash
#
class Hash
  # @!macro to_gfa_datastring
  def to_gfa_datastring(datatype); to_json; end

  #!macro gfa_datatype
  def gfa_datatype; :J; end
end

#
# Support of the conversion to GFA datastrings for Array
#
class Array
  # @!macro to_gfa_datastring
  def to_gfa_datastring(datatype)
    case datatype
    when :B
      to_numeric_array.to_s
    when :J
      to_json
    when :cig
      flatten.join
    when :cgs
      map{|cig|cig.to_gfa_datastring(:cig)}.join(",")
    when :lbs
      map{|os|os.to_oriented_segment.join}.join(",")
    when :H
      to_byte_array.to_s
    else
      map(&:to_s).join(",")
    end
  end

  #!macro gfa_datatype
  def gfa_datatype
    (all?{|i|i.kind_of?(Integer)} or all?{|i|i.kind_of?(Float)}) ? :B : :J
  end
end

#
# Support of the conversion to GFA datastrings of type H
#
class RGFA::ByteArray
  #!macro gfa_datatype
  def gfa_datatype; :H; end
end

#
# Support of the conversion to GFA datastrings of type B
#
class RGFA::NumericArray
  #!macro gfa_datatype
  def gfa_datatype; :B; end
end
