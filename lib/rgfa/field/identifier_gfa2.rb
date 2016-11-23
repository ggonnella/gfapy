module RGFA::Field::IdentifierGFA2

  def unsafe_decode(string)
    string.to_sym
  end

  def decode(string)
    validate_encoded(string)
    string.to_sym
  end

  def validate_encoded(string)
    if string !~ /^[!-~]+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA2 identifier\n"+
        "(it contains spaces or non-printable characters)"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::Line
      validate_encoded(object.name)
    when String, Symbol
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol, RGFA::Line)"
    end
  end

  def unsafe_encode(object)
    case object
    when String
      return object
    when Symbol
      return object.to_s
    when RGFA::Line
      return object.name.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol, RGFA::Line)"
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
  module_function :unsafe_encode
  module_function :encode

end
