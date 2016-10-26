module RGFA::Field::Integer

  def decode(string)
    Integer(string) rescue raise RGFA::FormatError,
      "the string does not represent a valid integer"
  end

  alias_method :unsafe_decode, :decode

  def validate_decoded(integer)
    # always valid
  end

  def validate_encoded(string)
    if string !~ /^[-+]?[0-9]+$/
      raise RGFA::FormatError,
        "#{string.inspect} does not represent a valid integer\n"+
        "(it does not match the regular expression [-+]?[0-9]+)"
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
        "(accepted classes: Integer, String)"
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
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Integer, String)"
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
