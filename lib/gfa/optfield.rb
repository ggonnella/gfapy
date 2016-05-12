class GFA::Optfield

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

  def initialize(tag, type, value)
    @tag = tag
    @type = type
    @value = value
    validate!
  end

  def to_s
    "#@tag:#@type:#@value"
  end

  private

  def validate!
    if @tag !~ TagRegexp
      raise GFA::Optfield::TagError, "Tag name invalid: '#@tag'"
    end
    if !TypeRegexp.keys.include?(@type)
      raise GFA::Optfield::TypeError, "Type unknown: '#@type'"
    end
    if @value !~ TypeRegexp[@type]
      raise GFA::Optfield::ValueError,
        "Value invalid for type #@type: '#@value'"
    end
  end

end

require "./gfa/optfield/tag_error.rb"
require "./gfa/optfield/type_error.rb"
require "./gfa/optfield/value_error.rb"
