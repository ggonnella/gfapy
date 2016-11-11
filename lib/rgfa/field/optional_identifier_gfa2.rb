module RGFA::Field::OptionalIdentifierGFA2

  def unsafe_decode(string)
    if string.placeholder?
      return RGFA::Placeholder.new
    else
      return string.to_sym
    end
  end

  def decode(string)
    if string.placeholder?
      return RGFA::Placeholder.new
    else
      validate_encoded(string)
      return string.to_sym
    end
  end

  def validate_encoded(string)
    if string !~ /^[!-~]+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA2 optional identifier\n"+
        "(it contains spaces or non-printable characters)"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::Placeholder
    when RGFA::Line
      validate_encoded(object.id)
    when String, Symbol
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol, RGFA::Line, RGFA::Placeholder)"
    end
  end

  def validate(object)
    validate_decoded(object)
  end

  def unsafe_encode(object)
    case object
    when String
      return object
    when Symbol, RGFA::Placeholder
      return object.to_s
    when RGFA::Line
      return object.id.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol, RGFA::Line, RGFA::Placeholder)"
    end
  end

  def encode(object)
    case object
    when RGFA::Placeholder
      return object.to_s
    when String
    when Symbol
      object = object.to_s
    when RGFA::Line
      object = object.id.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol, RGFA::Line, RGFA::Placeholder)"
    end
    validate_encoded(object)
    return object
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
