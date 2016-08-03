require_relative "error.rb"

#
# Array of positive integers <= 255;
# representation of the data contained in an H field
#
class RGFA::ByteArray < Array

  # Validates the byte array content
  # @raise [RGFA::ByteArray::ValueError] if any value is not a
  #   positive integer <= 255
  # @return [void]
  def validate!
    each do |x|
      unless x.kind_of?(Integer) and (0..255).include?(x)
        raise RGFA::ByteArray::ValueError,
          "Value incompatible with byte array: #{x.inspect}\n"+
          "in array: #{self.inspect}"
      end
    end
    self.trust
    return nil
  end

  # Returns self
  # @return [RGFA::ByteArray] self
  def to_byte_array
    self
  end

  # GFA datatype H representation of the byte array
  # @raise [RGFA::ByteArray::ValueError] if the
  #   array is not a valid byte array
  # @return [String]
  def to_s
    validate!
    map do |elem|
      str = elem.to_s(16).upcase
      elem < 16 ? "0#{str}" : str
    end.join
  end

end

# Exception raised if any value is not a positive integer <= 255
class RGFA::ByteArray::ValueError < RGFA::Error; end

# Exception raised if string is not a valid representation of byte array
class RGFA::ByteArray::FormatError < RGFA::Error; end

# Method to create a RGFA::ByteArray from an Array
class Array
  # Create a RGFA::ByteArray from an Array instance
  # @return [RGFA::ByteArray] the byte array
  def to_byte_array
    RGFA::ByteArray.new(self)
  end
end

# Method to parse the string representation of a RGFA::ByteArray
class String
  # Convert a GFA string representation of a byte array to a byte array
  # @return [RGFA::ByteArray] the byte array
  # @raise [RGFA::ByteArray::FormatError] if the string size is not > 0
  #   and even
  def to_byte_array
    if (size < 2) or (size % 2 == 1)
      raise RGFA::ByteArray::FormatError,
        "Invalid byte array string #{self}; "+
        "each element must be represented by two letters [0-9A-F]"
    end
    scan(/..?/).map {|x|Integer(x,16)}.to_byte_array
  end
end
