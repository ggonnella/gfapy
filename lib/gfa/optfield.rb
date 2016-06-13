#
# A representation of optional fields (also called tags) of GFA files.
#
# An optional field is a field in the form "XX:Y:Z+" where
# XX is the two-letter tag name, Y the type, and Z+ the value.
#
# Example usage:
# o = GFA::Optfield.new("AA","Z","xxxx")
# o.tag # => "AA"
# o.type # => "Z"
# o.value # => "xxxx"
#
# Automatic casting is done for numeric and array types:
# GFA::Optfield.new("AA","i","12").value # => 12
# GFA::Optfield.new("AA","f","1.2").value # => 1.2
# GFA::Optfield.new("AA","B","c,12,12,12").value # => [12,12,12]
#
# Type and tag name are fixed, but values can be edited:
# o = GFA::Optfield.new("AA","Z","xxxx")
# o.value = "yyyy"
#
# The values are validated according to predefined regular expressions:
# GFA::Optfield.new("AA","i","1A") # => raises GFA::Optfield::ValueError
#
class GFA::Optfield

  require "json"

  # @return [String] Tag name
  attr_reader :tag

  # @return [String] Tag type
  attr_reader :type

  # https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md#optional-fields
  TagRegexp = /[A-Za-z][A-Za-z0-9]/
  TypeRegexp =
    { "A" => /[!-~]/,        # Printable character
      "i" => /[-+]?[0-9]+/,  # Signed integer
      "f" => /[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/,
                             # Single-precision floating number
      "Z" => /[ !-~]+/,      # Printable string, including space
      "J" => /[ !-~]+/,      # JSON, excluding new-line and tab characters
      "H" => /[0-9A-F]+/,    # Byte array in the Hex format
      "B" => /[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+/
                             # Integer or numeric array
    }
  Separator = ":"

  # Creates a +GFA::Optfield+ instance.
  #
  # @param tag [String, length 2] tag name
  # @param type [A|i|f|Z|H|B|J] type
  # @param value [String|Integer|Float|Hash|Array]
  #   Either a string which
  #   specifies the value in accordance to the +type+, or an instance of a
  #   compatible Ruby class (Integer for "i" and "H", Float for "f", Array of
  #   Integer or Float values for "B", String for "Z" and "A", Array or
  #   Hash for "J").
  # @param [boolean] validate <i>(defaults to: +true+)</i>
  #    if false, skip validations
  #
  # @return [GFA::Optfield]
  # @raise [GFA::Optfield::TagError] if the tag name is not two letters or
  #   one letter and one number
  # @raise [GFA::Optfield::TypeError] if the type is not one of +AifZHBJ+
  # @raise [GFA::Optfield::ValueError] if the value is not in accordance to the
  #   specified type
  def initialize(tag, type, value, validate: true)
    @tag = tag.to_s
    @type = type.to_s
    @value = value_to_optfield_s(@type, value)
    @validate = validate
    validate! if @validate
  end

  # String representation of the optional field.
  # @return [String] "NN:T:VALUE" wheren NN is the tag name, T is the type
  #   and VALUE a string representing the value.
  def to_s
    "#@tag#{GFA::Optfield::Separator}#@type#{GFA::Optfield::Separator}#@value"
  end

  # Creates a +GFA::Optfield+ instance without specificing the type,
  # i.e. selecting the type to use from the class of +value+:
  # - Integer: "i"
  # - Float: "f"
  # - Array, with elements:
  #   - Integer: "B" with subtype "i"
  #   - Float: "B" with subtype "f"
  #   - #to_json: "J"
  # - Hash: "J"
  # - other (#to_s): "Z"
  #
  # @return [GFA::Optfield]
  #
  # @param tag [String, length 2] tag name
  # @param value [String|Integer|Float|Hash|Array|#to_s] value
  # @param [boolean] validate <i>(defaults to: +true+)</i>
  #    if false, skip validations
  def self.new_autotype(tag, value, validate: true)
    self.new(tag, guess_type(value), value, validate: validate)
  end

  # Sets the +value+ of the GFA::Optfield.
  #
  # @param value [String|Integer|Float|Hash|Array]
  #   Either a string which
  #   specifies the value in accordance to the +type+, or an instance of a
  #   compatible Ruby class (Integer for "i" and "H", Float for "f", Array of
  #   Integer or Float values for "B", String for "Z" and "A", Array or
  #   Hash for "J").
  #
  def value=(v)
    @value = value_to_optfield_s(@type, v)
    validate_value! if @validate
  end

  # Get the +value+ of the GFA::Optfield.
  #
  # @param [boolean] cast if true, values are casted according to
  #             their type: "i" and "H" to Integer, "f" to Float,
  #             "B" to an Array of Integer or Float elements,
  #             "Z" and "A" to strings, "J" are interpreted by JSON.parse()
  def value(cast = true)
    cast ? value_from_optfield_s(@type, @value) : @value
  end

  # @param validate ignored (compatibility reasons)
  # @return [GFA::Optfield] self
  def to_gfa_optfield(validate: true)
    self
  end

  # Creates a copy of an instance.
  # @return [GFA::Optfield]
  def clone
    self.class.new(@tag.clone, @type.clone, @value.clone)
  end

  private

  def self.guess_type(value)
    type = "Z"
    if value.kind_of? Integer
      type = "i"
    elsif value.kind_of? Float
      type = "f"
    elsif value.kind_of? String or value.kind_of? Symbol
      type = "Z"
    elsif value.kind_of? Array and value.all?{|i|i.kind_of? Integer}
      type = "B"
      value.unshift("i")
    elsif value.kind_of? Array and value.all?{|i|i.kind_of? Float}
      type = "B"
      value.unshift("f")
    elsif value.kind_of? Array or value.kind_of? Hash
      type = "J"
    end
    return type
  end

  def value_to_optfield_s(type, v)
    if type == "J" and v.kind_of?(Hash)
      return v.to_json
    elsif type == "J" and v.kind_of?(Array)
      return v.to_json
    elsif type == "H" and v.kind_of?(Integer)
      return v.to_s(16).upcase
    elsif type == "B" and v.kind_of?(Array)
      if v.all?{|i|i.kind_of?(Integer)}
        v.unshift("i")
      elsif v.all?{|i|i.kind_of?(Float)}
        v.unshift("f")
      end
      return v.join(",")
    else
      if v.kind_of?(Array)
        return v.map(&:to_s).join(",")
      else
        return v.to_s
      end
    end
  end

  def value_from_optfield_s(type, v)
    case type
    when "i"
      return v.to_i
    when "f"
      return v.to_f
    when "H"
      return v.to_i(16)
    when "J"
      return JSON.parse(v)
    when "B"
      elems = v.split(",")
      etype = elems.shift
      if etype == "f"
        return elems.map{|e|e.to_f}
      else
        return elems.map{|e|e.to_i}
      end
    else
      return v
    end
  end

  def validate!
    if @tag !~ /^#{TagRegexp}$/
      raise GFA::Optfield::TagError, "Tag name invalid: '#@tag'"
    end
    if !TypeRegexp.keys.include?(@type)
      raise GFA::Optfield::TypeError, "Type unknown: '#@type'"
    end
    validate_value!
  end

  def validate_value!
    if @value !~ /^#{TypeRegexp[@type]}$/
      raise GFA::Optfield::ValueError,
        "Value invalid for type #@type: '#@value'"
    end
    validate_B_values_range! if @type == "B"
    validate_json! if @type == "J"
  end

  def validate_B_values_range!
    values = @value.split(",")
    subtype = values.shift
    if subtype == "f"
      values.each {|v| Float(v) }
    else
      b_value_bits = {"c" => 8, "s" => 16, "i" => 32}
      if subtype == subtype.upcase
        min = 0
        max = (2**b_value_bits[subtype])-1
      else
        min = -(2**(b_value_bits[subtype]-1))
        max = (2**(b_value_bits[subtype]-1))-1
      end
      values.each do |v|
        v = Integer(v)
        if v > max or v < min
          raise "B type #{subtype} values must be in the range #{min}..#{max}"
        end
      end
    end
  end

  def validate_json!
    JSON.parse(@value)
  end

end

class GFA::Optfield::TagError < ArgumentError; end
class GFA::Optfield::TypeError < ArgumentError; end
class GFA::Optfield::ValueError < ArgumentError; end

class String

  # Creates a GFA::Optfield instance from a String
  #
  # @return [GFA::Optfield]
  # @raise [TypeError] if the string does not contain 3 elements,
  #   separated by GFA::Optfield::Separator
  # @param [boolean] validate <i>(defaults to: +true+)</i>
  #    if false, skip validations
  def to_gfa_optfield(validate: true)
    components = split(GFA::Optfield::Separator)
    if components.size != 3
      raise TypeError, "String does not represent a "+
        "GFA optional field: '#{self}'"
    end
    GFA::Optfield.new(*components, validate: validate)
  end

end
