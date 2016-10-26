module RGFA::Field::AlignmentGFA2

  def unsafe_decode(string)
    string.to_alignment
  end

  def decode(string)
    a = string.to_alignment
    a.validate! if a.kind_of?(RGFA::Trace)
    return a
  end

  alias_method :validate_encoded, :decode

  def validate_decoded(alignment)
    alignment.validate!
  end

  def validate(object)
    case object
    when String
      validate_encoded(object)
    when RGFA::CIGAR, RGFA::Trace
      object.validate!
    when RGFA::Placeholder
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: "+
        "String, RGFA::CIGAR, RGFA::Trace, RGFA::Placeholder)"
    end
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    validate(object)
    object.to_s
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode

end
