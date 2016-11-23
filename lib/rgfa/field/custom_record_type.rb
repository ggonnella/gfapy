module RGFA::Field::CustomRecordType

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
        "#{string.inspect} is not a valid custom record type\n"+
        "(it contains spaces and/or non-printable characters)"
    elsif [:E, :G, :F, :O, :U, :H, :"#", :S].include?(string.to_sym)
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid custom record type\n"+
        "(it is a predefined GFA2 record type)"
    end
  end

  alias_method :validate_decoded, :validate_encoded

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when String, Symbol
      validate_encoded(object)
      return object
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
