require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "line"

#
# Methods to convert ruby objects to the GFA string representations
# @api private
#
# The default conversion is implemented in this module, which is included in
# Object; single classes may overwrite the following methods, if necessary:
# - {#default_gfa_datatype}, which returns the symbol of the optional
#   field GFA datatype to use, if none is specified
#   (See RGFA::Line::FIELD_DATATYPE); the default is :Z
# - {#to_gfa_field} should return a GFA string representation,
#   eventually depending on the specified datatype; no validation is done;
#   the default is #to_s
#
module RGFA::FieldWriter

  # @!macro [new] to_gfa_field
  #   Representation of the data for GFA fields; this method
  #   does not (in general) validate the string. The method
  #   can be overwritten for a given class, and may take
  #   the {#default_gfa_datatype} into consideration.
  #   @return [String]
  #   @api private
  def to_gfa_field(datatype: nil); to_s; end

  # Representation of the data as an optional field
  # @param fieldname [Symbol] the tag name
  # @param datatype [RGFA::Line::OPTFIELD_DATATYPE] (<i>defaults to: the value
  #  returned by {#default_gfa_datatype}</i>)
  # @api private
  def to_gfa_optfield(fieldname, datatype: default_gfa_datatype)
    return "#{fieldname}:#{datatype}:#{to_gfa_field(datatype: datatype)}"
  end

  # @!macro [new] gfa_datatype
  #   Optional field GFA datatype to use, if none is provided
  #   @return [RGFA::Line::FIELD_DATATYPE]
  #   @api private
  def default_gfa_datatype; :Z; end
end

class Object
  include RGFA::FieldWriter
end

class Fixnum
  # @!macro gfa_datatype
  def default_gfa_datatype; :i; end
end

class Float
  # @!macro gfa_datatype
  def default_gfa_datatype; :f; end
end

class Hash
  # @!macro to_gfa_field
  def to_gfa_field(datatype: nil); to_json; end

  # @!macro gfa_datatype
  def default_gfa_datatype; :J; end
end

class Array
  # @!macro to_gfa_field
  def to_gfa_field(datatype: default_gfa_datatype)
    case datatype
    when :B
      to_numeric_array.to_s
    when :J
      to_json
    when :cig
      to_cigar.to_s
    when :cgs
      map{|cig|cig.to_cigar.to_s}.join(",")
    when :lbs
      map{|os|os.to_oriented_segment.to_s}.join(",")
    when :H
      to_byte_array.to_s
    else
      map(&:to_s).join(",")
    end
  end

  # @!macro gfa_datatype
  def default_gfa_datatype
    (all?{|i|i.kind_of?(Integer)} or all?{|i|i.kind_of?(Float)}) ? :B : :J
  end
end

class RGFA::ByteArray
  # @!macro gfa_datatype
  def default_gfa_datatype; :H; end
end

class RGFA::NumericArray
  # @!macro gfa_datatype
  def default_gfa_datatype; :B; end
end

class RGFA::Line::Segment
  # @!macro to_gfa_field
  def to_gfa_field(datatype: nil); to_sym.to_s; end
end
