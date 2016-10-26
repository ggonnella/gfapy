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
# - {#default_gfa_tag_datatype}, which returns the symbol of the tag
#   datatype to use, if none is specified
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
  #   the {#default_gfa_tag_datatype} into consideration.
  #   @param datatype [RGFA::Line::FIELD_DATATYPE]
  #   @param fieldname [String] fieldname, for error messages
  #   @raise [RGFA::TypeError] if the specified datatype is unknown
  #   @raise [RGFA::TypeError]
  #      if the object class is not compatible with datatype
  #   @raise [RGFA::FormatError] if the object is a string with an
  #     invalid syntax
  #   @raise [RGFA::ValueError] if the object value is not valid
  #   @return [String]
  #   @api private
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

  # Representation of the data as a tag
  # @param fieldname [Symbol] the tag name
  # @param datatype [RGFA::Line::TAG_DATATYPE] (<i>defaults to: the value
  #  returned by {#default_gfa_tag_datatype}</i>)
  # @api private
  def to_gfa_tag(fieldname, datatype: default_gfa_tag_datatype)
    return "#{fieldname}:#{datatype}:"+
      "#{to_gfa_field(datatype: datatype, fieldname: fieldname)}"
  end

  # @!macro [new] gfa_datatype
  #   GFA tag datatype to use, if none is provided
  #   @return [RGFA::Line::TAG_DATATYPE]
  #   @api private
  def default_gfa_tag_datatype; :Z; end
end

class Object
  include RGFA::FieldWriter
end

class Fixnum
  # @!macro gfa_datatype
  def default_gfa_tag_datatype; :i; end
end

class Float
  # @!macro gfa_datatype
  def default_gfa_tag_datatype; :f; end
end

class Hash
  # @!macro gfa_datatype
  def default_gfa_tag_datatype; :J; end
end

class Array
  # @!macro gfa_datatype
  def default_gfa_tag_datatype
    (all?{|i|i.kind_of?(Integer)} or all?{|i|i.kind_of?(Float)}) ? :B : :J
  end
end
