module RGFA::Field::NumericArray

  def unsafe_decode(string)
    string.to_numeric_array(validate: false)
  end

  def decode(string)
    string.to_numeric_array
  end

  def validate_encoded(string)
    if string !~ /^(f(,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+|[CSI](,\+?[0-9]+)+|[csi](,[-+]?[0-9]+)+)$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid numeric array string\n"+
        "(it must be one of [fcsiCSI] followed by a comma-separated list of:"+
        " for f: floats; for csi: signed integers; for CSI: unsigned integers)"
    end
  end

  def validate_decoded(numeric_array)
    numeric_array.validate
  end

  def validate(object)
    case object
    when RGFA::NumericArray
      object.validate
    when Array
      object.to_numeric_array.validate
    when String
      validate_encoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::NumericArray, Array)"
    end
  end

  def unsafe_encode(object)
    case object
    when RGFA::NumericArray
      object.to_s
    when Array
      object.to_numeric_array.to_s
    when String
      object
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::NumericArray, Array)"
    end
  end

  def encode(object)
    case object
    when RGFA::NumericArray
      object.to_s
    when Array
      object.to_numeric_array.to_s
    when String
      validate_encoded(object)
      object
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::NumericArray, Array)"
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
