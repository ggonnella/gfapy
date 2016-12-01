module RGFA::Field::AlignmentListGFA1

  def unsafe_decode(string)
    string.split(",").map {|c| c.to_cigar(valid: true, version: :gfa1)}
  end

  def decode(string)
    validate_encoded(string)
    unsafe_decode(string)
  end

  def validate_encoded(string)
     if string !~ /^(\*|(([0-9]+[MIDNSHPX=])+))(,(\*|(([0-9]+[MIDNSHPX=])+)))*$/
       raise RGFA::FormatError,
         "#{string.inspect} is not a comma separated list of * or CIGARs\n"+
         "(CIGAR strings must match ([0-9]+[MIDNSHPX=])+)"
     end
  end

  def validate_decoded(object)
    case object
    when RGFA::Placeholder
    when Array
      object.map do |elem|
        elem.to_cigar(version: :gfa1)
      end.each(&:validate)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array, RGFA::Placeholder)"
    end
  end

  def unsafe_encode(object)
    case object
    when RGFA::Placeholder
      object.to_s
    when Array
      object.map{|cig|cig.to_cigar.to_s}.join(",")
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array, RGFA::Placeholder)"
    end
  end

  def encode(object)
    case object
    when RGFA::Placeholder
      object.to_s
    when Array
      object.map do |cig|
        cig = cig.to_cigar
        cig.validate
        cig.to_s
      end.join(",")
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: Array, RGFA::Placeholder)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :unsafe_encode
  module_function :encode

end
