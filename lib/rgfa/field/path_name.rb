module RGFA::Field::PathName

  def unsafe_decode(string)
    string.to_sym
  end

  def decode(string)
    validate_encoded(string)
    string.to_sym
  end

  def validate_encoded(string)
    if string !~ /^[!-)+-<>-~][!-~]*$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA1 path name\n"+
        "(it does not match the regular expression [!-)+-<>-~][!-~]*"
    end
  end

  def validate_decoded(object)
    case object
    when String, Symbol
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Symbol, String)"
    end
  end

  def validate(object)
    validate_decoded(object)
  end

  def unsafe_encode(object)
    case object
    when String
      return object
    when Symbol
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Symbol, String)"
    end
  end

  def encode(object)
    string = unsafe_encode(object)
    validate_encoded(string)
    return string
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
