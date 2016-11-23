module RGFA::Field::Orientation

  def unsafe_decode(string)
    string.to_sym
  end

  def decode(string)
    s = string.to_sym
    validate_decoded(s)
    return s
  end

  def validate_decoded(symbol)
    if symbol != :+ and symbol != :-
      raise RGFA::FormatError,
        "#{symbol.inspect} is not a valid orientation\n"+
        "(it must be + or -)"
    end
    return symbol
  end

  def validate_encoded(string)
    if string != "+" and string != "-"
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid orientation\n"+
        "(it must be + or -)"
    end
    return string
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when Symbol
      validate_decoded(object)
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Symbol)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
