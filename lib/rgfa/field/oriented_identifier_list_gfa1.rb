module RGFA::Field::OrientedIdentifierListGFA1

  def unsafe_decode(string)
    string.split(",").map do |l|
      OL[l[0..-2].to_sym, l[-1].to_sym]
    end
  end

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end

  def validate_encoded(string)
    if string !~ /^[!-)+-<>-~][!-~]*[+-](,[!-)+-<>-~][!-~]*[+-])+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid list of GFA1 segment names "+
        "and orientations\n"+
        "(the segment names must match [!-)+-<>-~][!-~]*;\n"+
        " the orientations must be + or -;\n"+
        " the list must be comma-separated "+
        "NameOrient,NameOrient[,NameOrient...])"
    end
  end

  def validate_decoded(array)
    array.each do |elem|
      if !elem.kind_of?(RGFA::OrientedLine)
        raise RGFA::TypeError,
          "an element of the list is not a RGFA::OrientedLine\n"+
          "Element class: #{elem.class}\n"+
          "Element: #{elem}\n"+
          "List: #{array}"
      end
      elem.validate
      if elem.name !~ /^[!-)+-<>-~][!-~]*$/
        raise RGFA::FormatError,
          "#{elem.name} is not a valid GFA1 segment name\n"+
          "(it does not match [!-)+-<>-~][!-~]*)"
      end
    end
  end

  def unsafe_encode(object)
    case object
    when String
      return object
    when Array
      return object.map{|os|os.to_s}.join(",")
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Array)"
    end
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when Array
      validate_decoded(object)
      return object.map{|os|os.to_s}.join(",")
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Array)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
