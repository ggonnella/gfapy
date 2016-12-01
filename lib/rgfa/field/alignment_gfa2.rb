module RGFA::Field::AlignmentGFA2

  def unsafe_decode(string)
    string.to_alignment(version: :gfa2, valid: true)
  end

  def decode(string)
    string.to_alignment(version: :gfa2, valid: false)
  end

  alias_method :validate_encoded, :decode

  def validate_decoded(alignment)
    alignment.validate
  end

  def unsafe_encode(object)
    object.to_s
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when RGFA::Alignment::CIGAR, RGFA::Alignment::Trace
      object.validate
      return object.to_s
    when RGFA::Alignment::Placeholder
      return object.to_s
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: "+
        "String, RGFA::Alignment::CIGAR, RGFA::Alignment::Trace, "+
        "RGFA::Alignment::Placeholder)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
