module RGFA::Field::PositionGFA2

  def unsafe_decode(string)
    string.to_position
  end

  def decode(string)
    position = unsafe_decode(string)
    if position.value < 0
      raise RGFA::ValueError,
        "#{position.value} is not a positive integer"
    end
    return position
  end

  def validate_decoded(object)
    case object
    when Integer
      if object < 0
        raise RGFA::ValueError,
          "#{object} is not a positive integer"
      end
    when RGFA::Position
      object.validate!
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: RGFA::Position, Integer)"
    end
  end

  def validate_encoded(string)
    if string =~ /^[0-9]+\$?$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA2 position\n"+
        "(it must be an unsigned integer eventually followed by a $)"
    end
  end

  def validate(object)
    if object.kind_of?(String)
      validate_encoded(object)
    else
      validate_decoded(object)
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    validate(object)
    object.to_s
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
