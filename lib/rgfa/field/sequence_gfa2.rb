module RGFA::Field::SequenceGFA2

  def unsafe_decode(string)
    if string.placeholder?
      return RGFA::Placeholder.new
    else
      return string
    end
  end

  def decode(string)
    object = unsafe_decode(string)
    validate_decoded(object)
    return object
  end

  def validate_encoded(string)
    if string !~ /^[!-~]+$/
      raise RGFA::FormatError,
        "the string #{string.inspect} is not a valid GFA2 sequence\n"+
        "(it contains spaces and/or non-printable characters)"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::Placeholder
    when String
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::Placeholder)"
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when RGFA::Placeholder
      return object.to_s
    when String
      validate_encoded(object)
      return object
    else
      raise RGFA::TypeError,
        "the class is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::Placeholder)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
