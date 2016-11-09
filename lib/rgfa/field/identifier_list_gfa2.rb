module RGFA::Field::IdentifierListGFA2

  def unsafe_decode(string)
    string.split(" ").map(&:to_sym)
  end

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end

  def validate_encoded(string)
    if string !~ /^[ !-~]+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid list of GFA2 identifier\n"+
        "(it contains non-printable characters)"
    end
  end

  def validate_decoded(object)
    case object
    when Array
      object.each do |elem|
        elem = case elem
               when String
                 elem
               when Symbol
                 elem.to_s
               when RGFA::Line
                 elem.id.to_s
               else
                 raise RGFA::TypeError,
                   "the array contains an object of class #{elem.class}\n"+
                   "(accepted classes: String, Symbol, RGFA::Line)"
               end
        if elem !~ /^[!-~]+$/
          raise RGFA::FormatError,
          "the list contains an invalid GFA2 identifier (#{string.inspect})\n"+
          "(it contains spaces and/or non-printable characters)"
        end
      end
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array)"
    end
  end

  def validate(object)
    case object
    when String
      validate_encoded(object)
    when Array
      validate_decoded(object)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array, String)"
    end
  end

  def unsafe_encode(object)
    case object
    when Array
      object.map do |elem|
        case elem
        when String, Symbol
          elem.to_s
        when RGFA::Line
          elem.id.to_s
        else
          raise RGFA::TypeError,
            "the array contains an object of class #{elem.class}\n"+
            "(accepted classes: String, Symbol, RGFA::Line)"
        end
      end.join(" ")
    when String
      return object
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array, String)"
    end
  end

  def encode(object)
    validate_decoded(object)
    return unsafe_encode(object)
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
