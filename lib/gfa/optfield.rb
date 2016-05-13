class GFA::Optfield

  attr_reader :tag, :type, :value

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

  def initialize(tag, type, value)
    @tag = tag
    @type = type
    @value = value
    validate!
  end

  def to_s
    "#@tag#{GFA::Optfield::Separator}#@type#{GFA::Optfield::Separator}#@value"
  end

  def value=(v)
    @value = v
    validate_value!
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

  def to_gfa_optfield
    components = split(GFA::Optfield::Separator)
    if components.size != 3
      raise TypeError, "String does not represent a "+
        "GFA optional field: '#{self}'"
    end
    GFA::Optfield.new(*components)
  end

end
