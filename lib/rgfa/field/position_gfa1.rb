module RGFA::Field::PositionGFA1

  def unsafe_decode(string)
    begin
      Integer(string)
    rescue
      raise RGFA::FormatError,
        "#{string.inspect} does not represent a valid integer"
    end
  end

  def decode(string)
    value = unsafe_decode(string)
    validate_decoded(value)
    return value
  end

  def validate_decoded(integer)
    if integer < 0
      raise RGFA::ValueError,
        "#{integer} is not a positive integer"
    end
  end

  def validate_encoded(string)
    if string =~ /^[0-9]+$/
      raise RGFA::FormatError,
        "#{string.inspect} does not represent a valid unsigned integer"
    end
  end

  def validate(object)
    case object
    when String
      validate_encoded(object)
    when Integer
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Integer)"
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when Integer
      validate_decoded(object)
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Integer)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
