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
    @value = v.to_s
    validate_value!
  end

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
