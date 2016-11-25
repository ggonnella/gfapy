module RGFA::Field::OrientedIdentifierGFA2

  def unsafe_decode(string)
    string.to_oriented_line
  end

  def decode(string)
    object = unsafe_decode(string)
    validate_decoded(object)
    return object
  end

  def validate_encoded(string)
    if string !~ /^[!-~]+[+-]$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA2 oriented identifier\n"+
        "(it contains spaces or non-printable characters,"+
        "or does not end with an orientation symbol)"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::OrientedLine
      if object.name !~ /^[!-~]+$/
        raise RGFA::ValueError,
          "#{object.inspect} is not a valid GFA2 oriented identifier\n"+
          "(segment name contains spaces or non-printable characters)"
      elsif ![:+,:-].include?(object.orient)
        raise RGFA::ValueError,
          "#{object.inspect} is not a valid GFA2 oriented identifier\n"+
          "(orientation is invalid)"
      end
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: RGFA::OrientedLine)"
    end
  end

  def unsafe_encode(object)
    case object
    when String, RGFA::OrientedLine
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::OrientedLine)"
    end
  end

  def encode(object)
    object.kind_of?(String) ?
      validate_encoded(object) : validate_decoded(object)
    return object.to_s
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
