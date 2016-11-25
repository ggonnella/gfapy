module RGFA::Field::OrientedIdentifierListGFA2

  def unsafe_decode(string)
    string.split(" ").map do |item|
      OL[item[0..-2].to_sym, item[-1].to_sym]
    end
  end

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end

  def validate_encoded(string)
    if string !~ /^[!-~][+-]( [!-~][+-])*$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid list of oriented GFA2 identifier\n"+
        "(it contains non-printable characters or invalid orientations)"
    end
  end

  def validate_decoded(object)
    case object
    when Array
      object.each do |elem|
        if !elem.kind_of?(RGFA::OrientedLine)
          raise RGFA::TypeError,
            "the array contains an object of class #{elem.class}\n"+
            "(accepted classes: RGFA::OrientedLine)"
        end
        if elem.name !~ /^[!-~]+$/
          raise RGFA::FormatError,
          "the list contains an invalid GFA2 identifier (#{elem.name})\n"+
          "(it contains spaces and/or non-printable characters)"
        end
        if ![:+,:-].include?(elem.orient)
          raise RGFA::ValueError,
            "#{elem} is not a valid GFA2 oriented identifier\n"+
            "(orientation #{elem.orient} is invalid)"
        end
      end
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array)"
    end
  end

  def unsafe_encode(object)
    case object
    when Array
      object.map do |elem|
        case elem
        when RGFA::OrientedLine
          elem.to_s
        else
          raise RGFA::TypeError,
            "the array contains an object of class #{elem.class}\n"+
            "(accepted classes: RGFA::OrientedLine)"
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
  module_function :unsafe_encode
  module_function :encode

end
