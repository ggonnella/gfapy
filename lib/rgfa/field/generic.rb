module RGFA::Field::Generic

  def unsafe_decode(string)
    string
  end

  def decode(string)
    validate_encoded(string)
    string
  end

  def validate_encoded(string)
    if string.index("\n") or string.index("\t")
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid field content\n"+
        "(it contains newlines and/or tabs)"
    end
  end

  alias_method :validate_decoded, :validate_encoded

  def validate(object)
    case object
    when String
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String)"
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    validate(object)
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
