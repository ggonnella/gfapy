# A representation of optional fields (also called tags) of RGFA files.
# An optional field is a string in the form +NN:T:VALUE+ where
# +NN+ is the two-letter tag name, +T+ the type, and +VALUE+ the value.
# Automatic casting to/from Ruby types is done whenever possible.
# The values are validated according to predefined regular expressions,
# derived from the RGFA specification.
#
# @example Initialization:
#   RGFA::Optfield.new("AA","Z","xxxx")    # => Optfield: "AA", "Z", "xxxx"
#   RGFA::Optfield.new("AA","i","1A")      # (raises RGFA::Optfield::ValueError)
#   RGFA::Optfield.new("AA","i","1A",
#                       validate: false)  # validation off, nothing raised
#
# @example Parsing string representation:
#   "AA:Z:xxxxx".to_rgfa_optfield # => Optfield: "AA", "Z", "xxxxx"
#   "AA:xxxxxxx".to_rgfa_optfield # (raises TypeError)
#   "AA:Z:x:x:x".to_rgfa_optfield # => Optfield: "AA", "Z", "x:x:x"
#
# @example Reading the field content:
#   o.tag             # => "AA"
#   o.type            # => "Z"
#   o.value           # => "xxxx"
#
# @example Type and tag name are fixed, but values can be edited:
#   o.tag = "BB"      # (raises NoMethodError)
#   o.type = "i"      # (raises NoMethodError)
#   o.value = "yyyy"
#   o.value = 1       # (raises RGFA::Optfield::ValueError if type is not "i")
#
# @example Autotype:
#   RGFA::Optfield.new_autotype("AA",100)       # => "AA:i:100"
#   RGFA::Optfield.new_autotype("AA",1.0)       # => "AA:f:1.0"
#   RGFA::Optfield.new_autotype("AA",{"a"=>1})  # => "AA:J:{\"a\":1}"
#   RGFA::Optfield.new_autotype("AA",[1,1])     # => "AA:B:i,1,1"
#   RGFA::Optfield.new_autotype("AA",[1.0,1.0]) # => "AA:B:f,1.0,1.0"
#   RGFA::Optfield.new_autotype("AA",[1,1.0])   # => "AA:J:[1,1.0]"
#   RGFA::Optfield.new_autotype("AA",["A",1])   # => "AA:J:[\"A\",1]"
#
# @example Value casting:
#   "AA:i:12".to_rgfa_optfield.value          # => 12
#   "AA:f:1.2".to_rgfa_optfield.value         # => 1.2
#   "AA:B:c,12,12,12".to_rgfa_optfield.value  # => [12,12,12]
#   "AA:J:{\"a\":12}".to_rgfa_optfield.value  # => {"a" => 12}
#
class RGFA::Optfield

  require "json"

  # @return [String] Tag name
  attr_reader :tag

  # @return [String] Tag type
  attr_reader :type

  # Regular expression for the validation of the tag name;
  # derived from the RGFA specification at
  # https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#optional-fields
  TAG_REGEXP = /[A-Za-z][A-Za-z0-9]/

  # The possible types of optional field
  TAG_TYPE = [ CHAR_TAG_TYPE     = "A",
               INTEGER_TAG_TYPE  = "i",
               FLOAT_TAG_TYPE    = "f",
               STRING_TAG_TYPE   = "Z",
               JSON_TAG_TYPE     = "J",
               HEX_TAG_TYPE      = "H",
               NUMARRAY_TAG_TYPE = "B" ]

  # Regular expressions for the validation of the value, depending on tag type;
  # derived from the RGFA specification at
  # https://github.com/pmelsted/RGFA-spec/blob/master/RGFA-spec.md#optional-fields
  VALUE_REGEXP =
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

  # Delimiter in the string representation of the tag
  Separator = ":"

  # Creates a +RGFA::Optfield+ instance.
  #
  # @param tag [String] tag name, must have lenght 2 and match
  #    {RGFA::Optfield::TAG_REGEXP}
  # @param type [RGFA::Optfield::TAG_TYPE] type
  # @param value [String, Integer, Float, Hash, Array]
  #   Either a string which
  #   specifies the value in accordance to the +type+, or an instance of a
  #   compatible Ruby class (Integer for "i" and "H", Float for "f", Array of
  #   Integer or Float values for "B", String for "Z" and "A", Array or
  #   Hash for "J").
  # @param [Boolean] validate <i>(defaults to: +true+)</i>
  #    if false, skip validations; this can lead to invalid fields
  #
  # @return [RGFA::Optfield]
  # @raise [RGFA::Optfield::TagNameError] if the tag name does not respect
  #   {RGFA::Optfield::TAG_REGEXP}
  # @raise [RGFA::Optfield::TypeError] if the type is not one of
  #   {RGFA::Optfield::TAG_TYPE}
  # @raise [RGFA::Optfield::ValueError] if the value does not respect
  #   {RGFA::Optfield::VALUE_REGEXP}
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
    "#@tag#{RGFA::Optfield::Separator}#@type#{RGFA::Optfield::Separator}#@value"
  end

  # Creates a +RGFA::Optfield+ instance without specificing the type,
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
  # @return [RGFA::Optfield]
  #
  # @param tag [String] tag name
  # @param value [String, Integer, Float, Hash, Array, #to_s]
  # @param validate [Boolean] <i>(defaults to: +true+)</i>
  #    if false, skip validations
  def self.new_autotype(tag, value, validate: true)
    self.new(tag, guess_type(value), value, validate: validate)
  end

  # Sets the +value+ of the RGFA::Optfield.
  # @return [String] the string representation of the value
  # @raise [RGFA::Optfield::ValueError] if the value is not compatible with the
  #   optional field type
  #
  # @overload value=(ruby_value)
  #   @param value [String, Integer, Float, Hash, Array]
  #     an instance of a Ruby class compatible to the field type
  #     (Integer for "i" and "H", Float for "f", Array of
  #     Integer or Float values for "B", String for "Z" and "A", Array or
  #     Hash for "J")
  # @overload value=(value_string)
  #   @param value [String]
  #     a string representation of a value of the correct field type
  #
  def value=(value)
    @value = value_to_optfield_s(@type, value)
    validate_value! if @validate
    @value
  end

  # Get the +value+ of the RGFA::Optfield.
  #
  # @param cast [Boolean]
  #    if true, values are casted according to
  #    appropriate Ruby types: "i" and "H" to Integer, "f" to Float,
  #    "B" to an Array of Integer or Float elements,
  #    "Z" and "A" to strings, "J" are interpreted by JSON.parse()
  def value(cast = true)
    cast ? value_from_optfield_s(@type, @value) : @value
  end

  # @param [void] validate ignored (compatibility reasons)
  # @return [RGFA::Optfield] self
  def to_rgfa_optfield(validate: nil)
    self
  end

  # @return [RGFA::Optfield] deep copy of a RGFA::Optfield instance.
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
    if @tag !~ /^#{TAG_REGEXP}$/
      raise RGFA::Optfield::TagNameError,
        "String is not a valid tag name: '#@tag'"
    end
    if !TAG_TYPE.include?(@type)
      raise RGFA::Optfield::TypeError,
        "Optional field #@tag; type unknown: '#@type'"
    end
    validate_value!
  end

  def validate_value!
    if @value !~ /^#{VALUE_REGEXP[@type]}$/
      raise RGFA::Optfield::ValueError,
        "Optional field #{@tag}; value invalid for type #@type: '#@value'"
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

# Error raised if the tag name does not respect the specification
class RGFA::Optfield::TagNameError < ArgumentError; end

# Error raised if the type is not one of the predefined types
class RGFA::Optfield::TypeError < ArgumentError; end

# Error raised if the value does not respect the specified type
class RGFA::Optfield::ValueError < ArgumentError; end

class String

  # Creates a RGFA::Optfield instance from a String
  #
  # @return [RGFA::Optfield]
  # @raise [TypeError] if the string does not contain at least
  #   two {RGFA::Optfield::Separator}
  # @param validate [Boolean] validate <i>(defaults to: +true+)</i>
  #    if false, skip validations
  def to_rgfa_optfield(validate: true)
    components = split(RGFA::Optfield::Separator)
    if components.size < 3
      raise TypeError, "String does not represent a "+
        "RGFA optional field: '#{self}'"
    elsif components.size > 3
      components = [components[0], components[1],
                    components[2..-1].join(RGFA::Optfield::Separator)]
    end
    RGFA::Optfield.new(*components, validate: validate)
  end

end
