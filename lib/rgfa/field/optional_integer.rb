module RGFA::Field::OptionalInteger

  def decode(string)
    if string == "*"
      return RGFA::Placeholder
    else
      Integer(string) rescue raise RGFA::FormatError,
        "the string does not represent a valid integer"
    end
  end

  alias_method :unsafe_decode, :decode

  def validate_decoded(object)
    case object
    when Integer, RGFA::Placeholder
      # always valid
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Integer, RGFA::Placeholder)"
    end
  end

  def validate_encoded(string)
    if string !~ /^(\*|[-+]?[0-9]+)$/
      raise RGFA::FormatError,
        "#{string.inspect} does not represent a valid optional integer value\n"+
        "(it is not * and does not match the regular expression [-+]?[0-9]+)"
    end
  end

  def validate(object)
    case object
    when String
      validate_encoded(object)
    when Integer, RGFA::Placeholder
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Integer, RGFA::Placeholder, String)"
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
    when Integer, RGFA::Placeholder
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Integer, RGFA::Placeholder, String)"
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
