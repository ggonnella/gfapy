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
      "H" => /[0-9A-F]+/,    # Byte array in the Hex format
      "B" => /[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+/
                             # Integer or numeric array
    }
  Separator = ":"

  # Creates a GFA::Optfield instance.
  #
  # *Raises*:
  # - +GFA::Optfield::TagError+ if the tag name is not two letters or
  #                             one letter and one number
  # - +GFA::Optfield::TypeError+ if the type is not one of "AifZHB"
  # - +GFA::Optfield::ValueError+ if the value is not in accordance to the
  #                                specified type
  def initialize(tag, type, value)
    @tag = tag
    @type = type
    @value = value
    validate!
  end

  def to_s
    "#@tag#{GFA::Optfield::Separator}#@type#{GFA::Optfield::Separator}#@value"
  end

  # Sets the +value+ of the GFA::Optfield.
  #
  # *Arguments*:
  #   - +v-: the value to set; the value must be a string which specifies the
  #   value in accordance to the +type+; for "i" and "F" values, v may be,
  #   respectively, an Integer or Float
  # *Note*: for "H" and "B" no automatic back-conversion of +v+ to string is
  #  done, thus +gfa.value=gfa.value+ will generally fail in these cases
  #  (while +gfa.value=gfa.value(false)+ will not)
  def value=(v)
    @value = v.to_s
    validate_value!
  end

  # Get the +value+ of the GFA::Optfield.
  #
  # *Arguments*:
  #   - +cast+, if true, non "Z" and "A" values are casted according to
  #             their type: "i" and "H" to Integer, "f" to Float and
  #             "B" to an Array of Integer or Float elements
  def value(cast = true)
    return @value if !cast
    case @type
    when "i"
      return @value.to_i
    when "f"
      return @value.to_f
    when "H"
      return @value.to_i(16)
    when "B"
      elems = @value.split(",")
      etype = elems.shift
      if etype == "f"
        return elems.map{|e|e.to_f}
      else
        return elems.map{|e|e.to_i}
      end
    else
      return @value
    end
  end

  def to_gfa_optfield
    self
  end

  def clone
    self.class.new(@tag.clone, @type.clone, @value.clone)
  end

  private

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
