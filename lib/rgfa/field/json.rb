require "json"
module RGFA::Field::JSON

  def unsafe_decode(string)
    JSON.parse(string)
  end

  def decode(string)
    validate_all_printable(string)
    unsafe_decode(string)
  end

  def validate_encoded(string)
    # both regex and JSON parse are necessary,
    # because string can be invalid JSON and
    # JSON can contain forbidden chars (non-printable)
    validate_all_printable(string)
    begin
      JSON.parse(string)
    rescue => err
      "#{string.inspect} is not a valid JSON string\n"+
      "JSON.parse raised a #{err.class} exception\n"+
      "error message: #{err.message}"
    end
  end

  def validate_decoded(object)
    case object
    when RGFA::FieldArray
      object.validate!
    when Array, Hash
      string = encode(object)
      validate_all_printable(string)
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Array, Hash)"
    end
  end

  def validate(object)
    case object
    when String, Symbol
      validate_encoded(object)
    else
      validate_decoded(object)
    end
  end

  def unsafe_encode(object)
    object.to_json
  end

  def encode(object)
    case object
    when String
      validate_encoded(object)
      return object
    when Array, Hash
      string = object.to_json
      validate_all_printable(string)
      return string
    else
      raise RGFA::TypeError,
        "the class #{object.class} is incompatible with the datatype\n"+
        "(accepted classes: String, Array, Hash)"
    end
  end

  def validate_all_printable(string)
    if string !~ /^[ !-~]+$/
      raise RGFA::FormatError,
        "#{string.inspect} is not a valid JSON field\n"+
        "(it contains newlines, tabs and/or non-printable characters)"
    end
  end

  module_function :decode
  module_function :unsafe_decode
  module_function :validate_encoded
  module_function :validate_decoded
  module_function :validate
  module_function :unsafe_encode
  module_function :encode
  module_function :validate_all_printable

end
