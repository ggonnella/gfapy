#
# A representation of an optional field of a GFA line.
# This is one of the fields in the form "XX:Y:Z+" where
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

  attr_reader :tag, :type

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
  # *Raises*:
  # - +GFA::Optfield::TagError+ if the tag name is not two letters or
  #                             one letter and one number
  # - +GFA::Optfield::TypeError+ if the type is not one of "AifZHB"
  # - +GFA::Optfield::ValueError+ if the value is not in accordance to the
  #                                specified type
  def initialize(tag, type, v)
    @tag = tag.to_s
    @type = type.to_s
    @value = value_to_optfield_s(@type, v)
    validate!
  end

  def to_s
    "#@tag#{GFA::Optfield::Separator}#@type#{GFA::Optfield::Separator}#@value"
  end

  # Creates a +GFA::Optfield+ instance, guessing the correct type to use
  # from the class of +value+.
  #
  # *Type of returned GFA::Optfield*:
  #   - Integer          => "i"
  #   - Float            => "f"
  #   - Array of Integer => "B"/"i,..."
  #   - Array of Float   => "B"/"f,..."
  #   - other            => "Z"
  #
  def self.new_autotype(tag, value)
    self.new(tag, guess_type(value), value)
  end

  # Sets the +value+ of the GFA::Optfield.
  #
  # *Arguments*:
  #   - +v-: the value to set; the value must be either a string which
  #   specifies the value in accordance to the +type+, or a value of a
  #   compatible type, e.g. Integer for "i" and "H", Float for "f", Array of
  #   Integer or Float values for "B", String for "Z" and "A"
  #
  def value=(v)
    @value = value_to_optfield_s(@type, v)
    validate_value!
  end

  # Get the +value+ of the GFA::Optfield.
  #
  # *Arguments*:
  #   - +cast+, if true, non "Z" and "A" values are casted according to
  #             their type: "i" and "H" to Integer, "f" to Float and
  #             "B" to an Array of Integer or Float elements
  def value(cast = true)
    cast ? value_from_optfield_s(@type, @value) : @value
  end

  def to_gfa_optfield
    self
  end

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
    elsif value.kind_of? Array
      type = "B"
      if value.all?{|i|i.kind_of? Integer}
        value.unshift("i")
      elsif value.all?{|i|i.kind_of? Float}
        value.unshift("f")
      else
        type = "Z"
      end
    end
    return type
  end

  def value_to_optfield_s(type, v)
    if type == "H" and v.kind_of?(Integer)
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

end

class GFA::Optfield::TagError < ArgumentError; end
class GFA::Optfield::TypeError < ArgumentError; end
class GFA::Optfield::ValueError < ArgumentError; end

class String

  # Creates a GFA::Optfield instance from a String
  #
  # *Raises*:
  #   - +TypeError+ if the String cannot be converted into an Optfield
  #   - see GFA::Optfield#new for other possible exceptions
  def to_gfa_optfield
    components = split(GFA::Optfield::Separator)
    if components.size != 3
      raise TypeError, "String does not represent a "+
        "GFA optional field: '#{self}'"
    end
    GFA::Optfield.new(*components)
  end

end
