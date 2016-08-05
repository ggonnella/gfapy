# This represents multiple values of the same tag in different header lines
class RGFA::FieldArray < Array
  attr_reader :datatype
  def initialize(datatype, data = [])
    @datatype = datatype
    super(data)
  end
  def validate_gfa_field!(datatype, fieldname=nil)
    each.validate_gfa_field!(@datatype, fieldname)
  end
  def default_gfa_datatype
    :J
  end
  def to_gfa_field(datatype: nil)
    self << @datatype
    self << "\0"
    to_json
  end
  def push_with_validation(value, type, fieldname=nil)
    if type.nil?
      value.validate_gfa_field!(@datatype, fieldname)
    elsif type != @datatype
      raise RGFA::FieldArray::TypeMismatchError,
        "Datatype mismatch error for field #{fieldname}:\n"+
        "value: #{value}\n"+
        "existing datatype: #{@datatype};\n"+
        "new datatype: #{type}"
    end
    self << value
  end
end

class RGFA::FieldArray::Error < RGFA::Error; end
class RGFA::FieldArray::TypeMismatchError < RGFA::Error; end

def Array
  def rgfa_field_array?
    self[-1] == "\0" and
      RGFA::Line::OPTFIELD_DATATYPE.include?(self[-2].to_sym)
  end
  def to_rgfa_field_array(datatype=nil)
    if self.rgfa_field_array?
      RGFA::FieldArray.new(self[-2].to_sym, self[0..-3])
    elsif datatype.nil?
      raise RGFA::FieldArray::Error, "no datatype specified"
    else
      RGFA::FieldArray.new(datatype, self)
    end
  end
end
