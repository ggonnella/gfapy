# Array representing multiple values of the same tag in different header lines
# @tested_in api_header
class RGFA::FieldArray < Array
  attr_reader :datatype

  # @param datatype [RGFA::Field::TAG_DATATYPE] the datatype to use
  def initialize(datatype, data = [])
    @datatype = datatype
    super(data)
  end

  # Run the datatype-specific validation on each element of the array
  # @param fieldname [Symbol] fieldname to use for error messages
  # @return [void]
  def validate(fieldname=nil)
    validate_gfa_field(nil, fieldname)
  end

  # @api private
  # @tested_in unit_field_array
  module API_PRIVATE

    # Run a datatype-specific validation on each element of the array,
    #   using the specified datatype
    # @param datatype [nil, RGFA::Field::TAG_DATATYPE] datatype to use for the
    #   validation; use +nil+ to use the stored datatype (self.datatype)
    # @param fieldname [Symbol] fieldname to use for error messages
    # @return [void]
    def validate_gfa_field(datatype, fieldname=nil)
      datatype ||= @datatype
      each {|elem| elem.validate_gfa_field(datatype, fieldname)}
    end

    # Default GFA tag datatype
    # @return [RGFA::Field::TAG_DATATYPE]
    def default_gfa_tag_datatype
      @datatype
    end

    # String representation of the field array
    # @param datatype [RGFA::Field::TAG_DATATYPE]
    #   <i>(defaults to: +self.datatype+)</i> datatype of the data
    # @param fieldname [Symbol]
    #   <i>(defaults to +nil+)</i> fieldname to use for error messages
    # @return [String] tab-separated string representations of the elements
    def to_gfa_field(datatype: @datatype, fieldname: nil)
      map do |x|
        x.to_gfa_field(datatype: datatype, fieldname: fieldname)
      end.join("\t")
    end

    # String representation of the field array as GFA tags
    # @param datatype [RGFA::Field::TAG_DATATYPE]
    #   <i>(defaults to: +self.datatype+)</i> datatype of the data
    # @param fieldname [Symbol] name of the tag
    # @return [String] tab-separated GFA tag representations of the elements
    def to_gfa_tag(fieldname, datatype: @datatype)
      map{|x| x.to_gfa_tag(fieldname, datatype: datatype)}.join("\t")
    end

    # Add a value to the array and validate
    # @raise [RGFA::InconsistencyError] if the type of the new value does not
    #   correspond to the type of existing values
    # @param value [Object] the value to add
    # @param datatype [RGFA::Field::TAG_DATATYPE, nil] the datatype to use;
    #   if not +nil+, it will be checked that the specified datatype is the
    #   same as for previous elements of the field array (no further validation
    #   will be performed);
    #   if +nil+, the value will be validated, according to the datatype
    #   specified on field array creation
    # @param fieldname [Symbol] the field name to use for error messages
    def vpush(value, datatype=nil, fieldname=nil)
      if datatype.nil?
        value.validate_gfa_field(@datatype, fieldname)
      elsif datatype != @datatype
        raise RGFA::InconsistencyError,
          "Datatype mismatch error for field #{fieldname}:\n"+
          "value: #{value}\n"+
          "existing datatype: #{@datatype};\n"+
          "new datatype: #{datatype}"
      end
      self << value
    end

  end
  include API_PRIVATE

end

class Array

  # Create a {RGFA::FieldArray} from an array
  # @param datatype [RGFA::Field::TAG_DATATYPE] the datatype to use
  # @return [RGFA::FieldArray]
  # @tested_in api_array
  def to_rgfa_field_array(datatype=nil)
    if kind_of?(RGFA::FieldArray)
      self
    elsif datatype.nil?
      raise RGFA::ArgumentError, "No datatype specified"
    else
      RGFA::FieldArray.new(datatype, self)
    end
  end

end
