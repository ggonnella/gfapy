module RGFA::Field::AlignmentGFA1

  def decode(string)
    string.to_cigar(valid: false, version: :"1.0")
  end

  def unsafe_decode(string)
    string.to_cigar(valid: true, version: :"1.0")
  end

  def validate_encoded(string)
    if string !~ /^(\*|([0-9]+[MIDNSHPX=])+)$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid GFA1 alignment\n"+
        "(it is not * and is not a CIGAR string (([0-9]+[MIDNSHPX=])+)"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::Alignment::CIGAR
      object.validate
    when RGFA::Alignment::Placeholder
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, RGFA::Alignment::CIGAR,"+
        "RGFA::Alignment::Placeholder)"
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when RGFA::Alignment::CIGAR
      object.validate
      return object.to_s
    when RGFA::Alignment::Placeholder
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, "+
        "RGFA::Alignment::CIGAR, RGFA::Alignment::Placeholder)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
