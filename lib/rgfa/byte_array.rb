require_relative "error.rb"

#
# Array of positive integers <= 255;
# representation of the data contained in an H field
#
# @tested_in api_tags
#
class RGFA::ByteArray < Array

  # Validates the byte array content
  # @raise [RGFA::ValueError] if any value is not a
  #   positive integer <= 255
  # @return [void]
  def validate
    each do |x|
      unless x.kind_of?(Integer) and (0..255).include?(x)
        raise RGFA::ValueError,
          "Value incompatible with byte array: #{x.inspect}\n"+
          "in array: #{self.inspect}"
      end
    end
    self.trust
    return nil
  end

  # Returns self
  # @param valid [nil] ignored, for compatibility
  # @return [RGFA::ByteArray] self
  def to_byte_array(valid: nil)
    self
  end

  # GFA datatype H representation of the byte array
  # @raise [RGFA::ValueError] if the
  #   array is not a valid byte array
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @return [String]
  def to_s(valid: false)
    validate unless valid
    map do |elem|
      str = elem.to_s(16).upcase
      elem < 16 ? "0#{str}" : str
    end.join
  end

  # @api private
  # @tested_in internals_tag_datatype
  module API_PRIVATE
    # GFA tag datatype to use, if none is provided
    # @return [RGFA::Field::TAG_DATATYPE]
    def default_gfa_tag_datatype; :H; end
  end
  include API_PRIVATE

end

# Method to create a RGFA::ByteArray from an Array
# @tested_in api_tags
class Array
  # Create a RGFA::ByteArray from an Array instance
  # @param valid [nil] ignored, for compatibility
  # @return [RGFA::ByteArray] the byte array
  def to_byte_array(valid: nil)
    RGFA::ByteArray.new(self)
  end
end

# Method to parse the string representation of a RGFA::ByteArray
# @tested_in api_tags
class String
  # Convert a GFA string representation of a byte array to a byte array
  # @return [RGFA::ByteArray] the byte array
  # @param valid [Boolean] <i>(defaults to: +false+)</i> if +true+,
  #   the string is guaranteed to be valid
  # @raise [RGFA::FormatError] if the string size is not > 0
  #   and even
  def to_byte_array(valid: false)
    if !valid and ((size < 2) or (size % 2 == 1))
      raise RGFA::FormatError,
        "Invalid byte array string #{self}; "+
        "each element must be represented by two letters [0-9A-F]"
    end
    scan(/..?/).map do |x|
      begin
        Integer(x,16)
      rescue
        raise RGFA::FormatError,
          "Invalid element #{x} found in byte array string: #{self}"
      end
    end.to_byte_array
  end
end
