#
# Generic representation of a record of a RGFA file.
#
# @!macro[new] rgfa_line
#   @note
#     This class is usually not meant to be directly initialized by the user;
#     initialize instead one of its child classes, which define the concrete
#     different record types.
#
class RGFA::Line

  # Separator in the string representation of RGFA lines
  SEPARATOR = "\t"

  # List of allowed record_type values
  RECORD_TYPES = [ "H", "S", "L", "C", "P" ]

  # Full name of the record types
  RECORD_TYPE_LABELS = {
    "H" => "header",
    "S" => "segment",
    "L" => "link",
    "C" => "containment",
    "P" => "path",
  }

  # A symbol representing a datatype for optional fields
  OPTFIELD_DATATYPE = [:A, :i, :f, :Z, :J, :H, :B]

  # A symbol representing a datatype for required fields
  REQFIELD_DATATYPE = [:lbl, :orn, :lbs, :seq, :pos, :cig, :cgs]

  # A symbol representing a valid datatype
  FIELD_DATATYPE = OPTFIELD_DATATYPE + REQFIELD_DATATYPE

  # @!macro rgfa_line
  #
  # @param fields [Array<String>] the content of the line; the
  #   array content is not preserved by this method (the array
  #   will be empty after calling this method)
  # @param validate [Boolean] <i>(default: +true+)</i>
  #   validate the content of the fields
  #   using the regular expressions of the GFA specification
  #
  # <b> Constants defined by subclasses </b>
  #
  # Subclasses of RGFA::Line _must_ define the following constants:
  # - RECORD_TYPE [String, size 1]
  # - REQFIELDS [Array<Symbol>] required fields
  # - PREDEFINED_OPTFIELDS [Array<Symbol>] predefined optional fields
  # - DATATYPE [Hash{Symbol=>Symbol}]:
  #   datatypes for the required fields and the predefined optional fields
  #
  # @raise [RGFA::Line::RequiredFieldMissingError]
  #   if too less required fields are specified
  # @raise [RGFA::Line::CustomOptfieldNameError]
  #   if a non-predefined optional field uses upcase letters
  # @raise [RGFA::Line::DuplicatedOptfieldNameError]
  #   if an optional field tag name is used more than once
  # @raise [RGFA::Line::PredefinedOptfieldTypeError]
  #   if the type of a predefined optional field does not
  #   respect the specified type.
  #
  # @return [RGFA::Line]
  #
  def initialize(data, validate: true)
    unless self.class.const_defined?("RECORD_TYPE")
      raise "This class shall not be directly instantiated"
    end
    @validate = validate
    @data = {}
    if data.kind_of?(Hash)
      # cloning initialization
      data.each_pair {|k, v| @data[k] = v.clone}
    else
      # normal initialization, from array of strings
      initialize_required_fields(data)
      initialize_optional_fields(data)
      validate_record_type_specific_info! if @validate
    end
  end

  # Select a subclass based on the record type
  # @raise [RGFA::Line::UnknownRecordTypeError] if the record_type is not valid
  # @return [Class] a subclass of RGFA::Line
  def self.subclass(record_type)
    case record_type
    when "H" then RGFA::Line::Header
    when "S" then RGFA::Line::Segment
    when "L" then RGFA::Line::Link
    when "C" then RGFA::Line::Containment
    when "P" then RGFA::Line::Path
    else
      raise RGFA::Line::UnknownRecordTypeError,
        "Record type unknown: '#{record_type}'"
    end
  end

  # @return [Symbol] record type code
  def record_type
    self.class::RECORD_TYPE
  end

  # @return [Array<Symbol>] fields defined for this instance
  def fieldnames
    @data.keys
  end

  # @return [Array<Symbol>] name of the required fields
  def required_fieldnames
    self.class::REQFIELDS
  end

  # @return [Array<Symbol>] name of the optional fields
  def optional_fieldnames
    (@data.keys - self.class::REQFIELDS)
  end

  # @return [RGFA::Line] deep copy of self (RGFA::Line subclass)
  def clone
    self.class.new(@data, validate: @validate)
  end

  # @return [String] a string representation of self
  def to_s(validate: true)
    to_a(validate: validate).join(SEPARATOR)
  end

  # @return [Array<String>] an array of string representations of the fields
  def to_a(validate: true)
    a = [record_type]
    required_fieldnames.each {|fn| a << get_string(fn, validate: validate,
                                                       optfield: false)}
    optional_fieldnames.each {|fn| a << get_string(fn, validate: validate,
                                                       optfield: true)}
    return a
  end

  # Remove an optional field from the line, if it exists;
  #   do nothing if it does not
  # @param fieldname [#to_sym] the tag name of the optfield to remove
  # @return [Object, nil] the deleted value or nil, if the field was not defined
  def delete(fieldname)
    fn = fieldname.to_sym
    if optional_fieldnames.include?(fn)
      v = @data.delete(fn)
      return v.nil? ? nil : v[0]
    else
      return nil
    end
  end

  # Raises an error if the content of the field does not correspond to
  # the field type
  #
  # @param fieldname [#to_sym] the tag name of the field to validate
  # @raise [Exception] if the content of the field is not valid, according
  #   to its required type
  # @return [nil]
  def validate_field!(fieldname)
    fieldname = fieldname.to_sym
    v = @data[fieldname]
    return nil if v.nil? or v[1].nil?
    v[0].validate_datastring(v[1], fieldname: fieldname)
    return nil
  end

  # Returns a symbol, which specifies the datatype of a field
  #
  # @return [Symbol, nil] the datatype symbol or +nil+ if the field
  #   does not exist and/or the datatype is not (yet) defined
  def get_datatype(fieldname)
    v = @data[fieldname.to_sym]
    v.nil? ? nil : v[1]
  end

  # @!macro[new] get_string
  #   Returns the string representation of the content of a field.
  #   The datatype is either predefined (required fields,
  #   optional fields), manually set (see #set_datatype)
  #   or automatically computed.
  #
  #   @param validate [Boolean] <i>(defaults to: +true+)</i> perform a
  #     validation of the string, using the regular expression
  #     for the datatype
  #
  #   @param optfield [Boolean] <i>(defaults to: +false+)</i>
  #     return the tagname:datatype:datastring representation
  #
  # @return [String] the string representation (an empty
  #   string if the field does not exist)
  def get_string(fieldname, validate: true, optfield: false)
    field = @data[fieldname.to_sym]
    return nil if field.nil?
    f = field[0].to_gfa_field(datatype: field[1],
                              optfield: optfield,
                              fieldname: fieldname,
                              validate: validate)
    return f
  end

  # @!macro get_string
  # @raise [RGFA::Line::TagMissingError] if field is not defined
  # @return [String] the string representation
  def get_string!(fieldname, validate: true, optfield: false)
    v = get_string(fieldname, validate: validate, optfield: optfield)
    raise RGFA::Line::TagMissingError,
      "No value defined for tag #{fieldname}" if v.nil?
    return v
  end

  # Set or change the datatype of a custom optional field
  #
  # @param fieldname [#to_sym] the field name
  # @param datatype [#to_sym] the datatype
  # @raise [RGFA::Line::CustomOptfieldNameError] if the field name is not a
  #   valid custom optional name
  # @raise [RGFA::Line::UnknownDatatype] if +datatype+ is not
  #   a valid datatype for optional fields
  def set_datatype(fieldname, datatype)
    fieldname = fieldname.to_sym
    datatype = datatype.to_sym
    unless OPTFIELD_DATATYPES.includes?(datatype)
      raise RGFA::Line::UnknownDatatype, "Unknown datatype: #{datatype}"
    end
    validate_custom_optional_fieldname(fieldname)
    @data[fieldname] ||= []
    @data[fieldname][1] ||= datatype
  end

  # Set the value of a field. The field name must be a required field,
  # a predefined optional field name (uppercase) or custom optional
  # field name (lowercase).
  # The field content is not validated by this method.
  # To validate the content, use #validate_field!. Automatic validation
  # is performed, when the fields are read from string or written to
  # string.
  # To explicitely set the datatype of a new custom optional fields
  # use #set_datatype,
  # otherwise the type will be automatically selected from the value.
  # @param fieldname [#to_sym] the name of the field to set
  # @return [void]
  def set(fieldname, value)
    fieldname = fieldname.to_sym
    if @data.has_key?(fieldname)
      @data[fieldname][0] = value
    elsif predefined_optional_fieldname?(fieldname)
      @data[fieldname] = [value, self.class::DATATYPE[fieldname]]
    elsif valid_custom_optional_fieldname?(fieldname)
      @data[fieldname] = [value]
    else
      raise RGFA::Line::FieldnameError,
        "#{fieldname} is not an existing or predefined field or a "+
        "valid custom optional field"
    end
    return nil
  end

  # Value of a field
  # @param field_name [#to_sym] name of the field
  # @return [Object,nil] value of the field
  #   or +nil+ if field is not defined
  def get(fieldname)
    v = @data[fieldname.to_sym]
    return nil if v.nil?
    if not_casted?(v[0], v[1])
      v[0] = v[0].parse_datastring(v[1], validate: false, lazy: false)
    end
    return v[0]
  end

  # Value of a field, raising an exception if it is not defined
  # @param field_name [#to_sym] name of the field
  # @raise [RGFA::Line::TagMissingError] if field is not defined
  # @return [Object,nil] value of the field
  def get!(field_name)
    v = get(field_name)
    raise RGFA::Line::TagMissingError,
      "No value defined for tag #{field_name}" if v.nil?
    return v
  end

  # Three methods are dynamically created for each existing field name as well
  # as for each non-existing but valid optional field name.
  #
  # ---
  #  - (Object) <fieldname>(parse=true)
  # The value of a field.
  #
  # <b>Parameters:</b>
  # - +*parse*+ (Boolean) <i>(default: +true+)</i>
  #   parse the string and return the corresponding ruby object if +true+;
  #   return the GFA string representation of the data if +false+
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) if the field exists
  # - (nil) if the field does not exist, but is a valid optional field name
  #
  # ---
  #  - (Object) <fieldname>!(parse=true)
  # The valid of a field, raising an exception if not available.
  #
  # <b>Parameters:</b>
  # - +*parse*+ (Boolean) <i>(default: +true+)</i>
  #   parse the string and return the corresponding ruby object if +true+;
  #   return the GFA string representation of the data if +false+
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) if the field exists
  #
  # <b>Raises:</b>
  # - (RGFA::Line::TagMissingError) if the field does not exist
  #
  # ---
  #
  #  - (self) <fieldname>=(value)
  # Sets the value of a required or optional
  # field, or creates a new optional field if the fieldname is
  # non-existing but valid. No validation is performed by this
  # method. See also #set, #validate_field!, #set_datatype.
  #
  # <b>Parameters:</b>
  # - +*value*+ (String|Hash|Array|Integer|Float) value to set
  #
  # ---
  #
  def method_missing(m, *args, &block)
    field_name, operation, state = split_method_name(m)
    if ((operation == :get or operation == :get!) and args.size > 1) or
       (operation == :set and args.size != 1)
      raise ArgumentError, "wrong number of arguments"
    end
    case state
    when :invalid
      super
    when :field
      case operation
      when :get
        if args[0] == false
          get_string(field_name)
        else
          get(field_name)
        end
      when :get!
        if args[0] == false
          get_string!(field_name)
        else
          get!(field_name)
        end
      when :set
        set(field_name, args[0])
        return nil
      end
    when :valid
      case operation
      when :get
        return nil
      when :get!
        raise RGFA::Line::TagMissingError,
          "No value defined for tag #{field_name}"
      when :set
        @data[field_name] = [args[0]]
        return nil
      end
    end
  end

  # Redefines respond_to? to correctly handle dynamical methods.
  # @see #method_missing
  def respond_to?(m, include_all=false)
    super ? true : (split_method_name(m)[2] != :invalid)
  end

  # @return self
  # @param validate [Boolean] ignored (compatibility reasons)
  def to_rgfa_line(validate: true)
    self
  end

  # Equivalence check
  # @return [Boolean] does the line has the same record type,
  #   contains the same optional fields
  #   and all required and optional fields contain the same field values?
  # @see RGFA::Line::Link#==
  def ==(o)
    (o.record_type == self.record_type) and
      (o.fieldnames == self.fieldnames) and
        (o.fieldnames.all? do |fn|
          (o.send(fn) == self.send(fn)) or
          field_str()
        end)
  end

  # Validate the RGFA::Line instance
  # @raise if any field content is not valid
  # @return [void]
  def validate!
    @data.each_pair do |fieldname, field|
      field[0].validate_datastring(field[1], fieldname: fieldname) if field[1]
    end
    validate_record_type_specific_info!
  end

  private

  def n_required_fields
    self.class::REQFIELDS.size
  end

  def not_casted?(value, datatype)
    value.kind_of?(String) and not [:A, :Z, :seq, nil].include?(datatype)
  end

  def initialize_required_fields(strings)
    if strings.size < n_required_fields
      raise RGFA::Line::RequiredFieldMissingError,
        "#{n_required_fields} required fields expected, "+
        "#{strings.size}) found\n#{strings.inspect}"
    end
    n_required_fields.times do |i|
      s = strings.shift
      n = self.class::REQFIELDS[i]
      t = self.class::DATATYPE[n]
      s = s.parse_datastring(t, validate: @validate, lazy: true, fieldname: n)
      @data[n] = [s, t]
    end
  end

  def valid_custom_optional_fieldname?(fieldname)
    fieldname =~ /^[a-z][a-z0-9]$/
  end

  def validate_custom_optional_fieldname(fieldname)
    if not valid_custom_optional_fieldname?(fieldname)
      raise RGFA::Line::CustomOptfieldNameError,
        "#{fieldname} is not a valid custom optional field name"
    end
  end

  def predefined_optional_fieldname?(fieldname)
    self.class::PREDEFINED_OPTFIELDS.include?(fieldname)
  end

  def initialize_optional_fields(strings)
    while (s = strings.shift)
      n, t, s = s.parse_optfield(parse_datastring: false,
                                 validate_datastring: false)
      if @validate
        if @data.has_key?(n)
          raise RGFA::Line::DuplicatedOptfieldNameError,
            "Optional field #{n} found multiple times"
        end
        if not valid_custom_optional_fieldname?(n)
          unless predefined_optional_fieldname?(n)
            raise RGFA::Line::CustomOptfieldNameError,
                    "Custom-defined optional "+
                    "fields must be lower case; found: #{n}"
          end
          unless t == self.class::DATATYPE[n]
            raise RGFA::Line::PredefinedOptfieldTypeError,
              "Optional field #{n} must be of type "+
                "#{self.class::DATATYPE[n]}, #{t} found"
          end
        end
      end
      s = s.parse_datastring(t, validate: @validate, lazy: true, fieldname: n)
      @data[n] = [s, t]
    end
  end

  def split_method_name(m)
    if @data.has_key?(m)
      return m, :get, :field
    else
      case m[-1]
      when "!"
        var = :get!
        m = m[0..-2].to_sym
      when "="
        var = :set
        m = m[0..-2].to_sym
      else
        var = :get
      end
      if @data.has_key?(m)
        state = :field
      elsif self.class::PREDEFINED_OPTFIELDS.include?(m) or
          valid_custom_optional_fieldname?(m)
        state = :valid
      else
        state = :invalid
      end
      return m, var, state
    end
  end

  def validate_record_type_specific_info!
  end

end

# Error raised if the record_type is not one of RGFA::Line::RECORD_TYPES
class RGFA::Line::UnknownRecordTypeError      < TypeError;     end

# Error raised if an invalid datatype symbol is found
class RGFA::Line::UnknownDatatype             < TypeError;     end

# Error raised if an invalid fieldname symbol is found
class RGFA::Line::FieldnameError              < NameError;     end

# Error raised if optional tag is not present
class RGFA::Line::TagMissingError             < NoMethodError; end

# Error raised if too less required fields are specified.
class RGFA::Line::RequiredFieldMissingError   < ArgumentError; end

# Error raised if a non-predefined optional field uses upcase
# letters.
class RGFA::Line::CustomOptfieldNameError     < ArgumentError; end

# Error raised if an optional field tag name is used more than once.
class RGFA::Line::DuplicatedOptfieldNameError < ArgumentError; end

# Error raised if the type of a predefined optional field does not
# respect the specified type.
class RGFA::Line::PredefinedOptfieldTypeError < TypeError;     end

#
# Require the child classes
#
require_relative "line/header.rb"
require_relative "line/segment.rb"
require_relative "line/path.rb"
require_relative "line/link.rb"
require_relative "line/containment.rb"

# Extensions to the String core class.
#
class String

  # Parses a line of a RGFA file and creates an object of the correct
  #   record type child class of {RGFA::Line}
  # @return [subclass of RGFA::Line]
  # @raise if the string does not comply to the RGFA specification
  # @param validate [Boolean] <i>(defaults to: +true+)</i>
  #   if false, turn off validations
  def to_rgfa_line(validate: true)
    split(RGFA::Line::SEPARATOR).to_rgfa_line(validate: validate)
  end

end

# Extensions to the Array core class.
#
class Array

  # Parses an array containing the fields of a RGFA file line and creates an
  # object of the correct record type child class of {RGFA::Line}
  # @note
  #  This method modifies the content of the array; if you still
  #  need the array, you must create a copy before calling it
  # @return [subclass of RGFA::Line]
  # @raise if the fields do not comply to the RGFA specification
  # @param validate [Boolean] <i>(defaults to: +true+)</i>
  #   if false, turn off validations
  def to_rgfa_line(validate: true)
    RGFA::Line.subclass(shift).new(self, validate: validate)
  end

end
