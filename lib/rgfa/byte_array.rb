#
# Array of positive integers < 255;
# representation of the data contained in an H field
#
class RGFA::ByteArray < Array

  def to_gfa_datastring(datatype)
    validate!
    map{|x|x.to_s(16).upcase}.join
  end

  def validate!
    each do |x|
      if ![0..255].include?(x)
        raise RGFA::Line::FormatError,
          "Value incompatible with type H: #{x.inspect}\n"+
          "in array: #{self.inspect}"
      end
    end
  end

  def gfa_datatype
    :H
  end

  def to_byte_array(validate: nil)
    self
  end
end

class Array
  def to_byte_array(validate: nil)
    ba = RGFA::ByteArray.new(self)
    ba.validate! if validate
    ba
  end
end

class String
  def to_byte_array(validate: nil)
    scan(/..?/).map {|x|x.to_i(16)}
  end
end
