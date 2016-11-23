module RGFA::Field::ByteArray

  def unsafe_decode(string)
    string.to_byte_array(valid: true)
  end

  def decode(string)
    string.to_byte_array
  end

  def validate_encoded(string)
    if string !~ /^[0-9A-F]+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid hex string\n"+
        "(it does not match the regular expression [0-9A-F]+)"
    end
  end

  def validate_decoded(byte_array)
    byte_array.validate
  end

  def unsafe_encode(object)
    case object
    when RGFA::ByteArray
      object.to_s(valid: true)
    when Array
      object.to_byte_array.to_s(valid: true)
    when String
      object
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::ByteArray, Array)"
    end
  end

  def encode(object)
    case object
    when RGFA::ByteArray
      object.to_s
    when Array
      object.to_byte_array.to_s
    when String
      validate_encoded(object)
      object
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::ByteArray, Array)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
