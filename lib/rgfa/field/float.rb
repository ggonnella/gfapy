module RGFA::Field::Float

  def decode(string)
    Float(string) rescue raise RGFA::FormatError
  end

  alias_method :unsafe_decode, :decode

  def validate_decoded(object)
    case object
    when Integer, Float
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Integer)"
    end
  end

  def validate_encoded(string)
    if string !~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
      raise RGFA::FormatError,
        "#{string.inspect} does not represent a valid float\n"+
        "(it does not match [-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)"
    end
  end

  def validate(object)
    case object
    when String
      validate_encoded(object)
    when Integer, Float
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Integer, Float)"
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
    when Integer, Float
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Integer, Float)"
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
