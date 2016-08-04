require "set"
#
# Generic representation of a record of a RGFA file.
#
# @!macro [new] rgfa_line
#   @note
#     This class is usually not meant to be directly initialized by the user;
#     initialize instead one of its child classes, which define the concrete
#     different record types.
#
class RGFA::Line

  # Separator in the string representation of RGFA lines
  SEPARATOR = "\t"

  # List of allowed record_type values
  RECORD_TYPES = [ :H, :S, :L, :C, :P ]

  # Full name of the record types
  RECORD_TYPE_LABELS = {
    :H => "header",
    :S => "segment",
    :L => "link",
    :C => "containment",
    :P => "path",
  }

  # A symbol representing a datatype for optional fields
  OPTFIELD_DATATYPE = [:A, :i, :f, :Z, :J, :H, :B]

  # A symbol representing a datatype for required fields
  REQFIELD_DATATYPE = [:lbl, :orn, :lbs, :seq, :pos, :cig, :cgs]

  # A symbol representing a valid datatype
  FIELD_DATATYPE = OPTFIELD_DATATYPE + REQFIELD_DATATYPE

  # data types which are parsed only on access
  DELAYED_PARSING_DATATYPES = [:cig, :cgs, :lbs, :H, :J, :B]

  def virtual?
    @virtual
  end

  def data
    @data
  end
  protected :data

  def real!(real_line)
    @virtual = false
    real_line.data.each_pair do |k, v|
      @data[k] = v
    end
  end

  # @!macro rgfa_line
  #
  # @param data [Array<String>] the content of the line; if
  #   an array of strings, this is interpreted as the splitted content
  #   of a GFA file line; note: an hash
  #   is also allowed, but this is for internal usage and shall be considered
  #   private
  # @param validate [Integer] see paragraph Validation
  # @param virtual [Boolean] <i>(default: +false+)</i>
  #   mark the line as virtual, i.e. not yet found in the GFA file;
  #   e.g. a link is allowed to refer to a segment which is not
  #   yet created; in this case a segment marked as virtual is created,
  #   which is replaced by a non-virtual segment, when the segment
  #   line is later found
  #
  # <b> Constants defined by subclasses </b>
  #
  # Subclasses of RGFA::Line _must_ define the following constants:
  # - RECORD_TYPE [RGFA::Line::RECORD_TYPES]
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
  # <b>Validation levels</b>
  #
  # The default is 2, i.e. if a field content is changed, the user is
  # responsible to call #validate_field!, if necessary.
  #
  # - 0: no validation
  # - 1: the number of required fields must be correct; optional fields
  #      cannot be duplicated; custom optional field names must be correct;
  #      predefined optional fields must have the correct type; only some
  #      fields are validated on initialization or first-time access to
  #      the field content
  # - 2: 1 + all fields are validated on initialization or first-time
  #      access to the field content
  # - 3: 2 + all fields are validated on initialization and record-specific
  #      validations are run (e.g. compare segment LN tag and sequence lenght)
  # - 4: 3 + all fields are validated on writing to string
  # - 5: 4 + all fields are validated by get and set methods
  #
  def initialize(data,
                 validate: 2,
                 virtual: false)
    unless self.class.const_defined?(:"RECORD_TYPE")
      raise RuntimeError, "This class shall not be directly instantiated"
    end
    @validate = validate
    @virtual = virtual
    @data = {}
    @datatype = {}
    if data.kind_of?(Hash)
      # cloning initialization
      data.each_pair do |k, v|
        v = v.clone if !v.kind_of?(Numeric) and !v.kind_of?(Symbol)
        @data[k] = v
      end
    else
      # normal initialization, from array of strings
      initialize_required_fields(data)
      initialize_optional_fields(data)
      validate_record_type_specific_info! if @validate >= 3
    end
  end

  # Select a subclass based on the record type
  # @raise [RGFA::Line::UnknownRecordTypeError] if the record_type is not valid
  # @return [Class] a subclass of RGFA::Line
  def self.subclass(record_type)
    case record_type.to_sym
    when :H then RGFA::Line::Header
    when :S then RGFA::Line::Segment
    when :L then RGFA::Line::Link
    when :C then RGFA::Line::Containment
    when :P then RGFA::Line::Path
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
  def to_s
    to_a.join(SEPARATOR)
  end

  # @return [Array<String>] an array of string representations of the fields
  def to_a
    a = [record_type]
    required_fieldnames.each {|fn| a << field_to_s(fn, optfield: false)}
    optional_fieldnames.each {|fn| a << field_to_s(fn, optfield: true)}
    return a
  end

  # Remove an optional field from the line, if it exists;
  #   do nothing if it does not
  # @param fieldname [Symbol] the tag name of the optfield to remove
  # @return [Object, nil] the deleted value or nil, if the field was not defined
  def delete(fieldname)
    if optional_fieldnames.include?(fn)
      return @data.delete(fn)
    else
      return nil
    end
  end

  # Raises an error if the content of the field does not correspond to
  # the field type
  #
  # @param fieldname [Symbol] the tag name of the field to validate
  # @raise [RGFA::FieldParser::FormatError] if the content of the field is
  #   not valid, according to its required type
  # @return [void]
  def validate_field!(fieldname)
    v = @data[fieldname]
    t = field_or_default_datatype(fieldname, v)
    v.validate_gfa_field!(t, fieldname)
    return nil
  end

  # @!macro [new] field_to_s
  #   Compute the string representation of a field.
  #
  #   @param fieldname [Symbol] the tag name of the field
  #   @param optfield [Boolean] <i>(defaults to: +false+)</i>
  #     return the tagname:datatype:value representation
  #
  # @raise [RGFA::Line::TagMissingError] if field is not defined
  # @return [String] the string representation
  def field_to_s(fieldname, optfield: false)
    fieldname = fieldname.to_sym
    field = @data[fieldname]
    raise RGFA::Line::TagMissingError,
      "No value defined for tag #{fieldname}" if field.nil?
    t = field_or_default_datatype(fieldname, field)
    if !field.kind_of?(String)
      field = field.to_gfa_field(datatype: t)
    end
    field.validate_gfa_field!(t, fieldname) if @validate >= 4
    return optfield ? field.to_gfa_optfield(fieldname, datatype: t) : field
  end

  # Returns a symbol, which specifies the datatype of a field
  #
  # @param fieldname [Symbol] the tag name of the field
  # @return [RGFA::Line::FIELD_DATATYPE] the datatype symbol
  def get_datatype(fieldname)
    field_or_default_datatype(fieldname, @data[fieldname])
  end

  # Set the datatype of a custom optional field.
  # If an existing field datatype is changed, its content may become
  # invalid (call #validate_field! if necessary).
  # If a datatype for a new custom optional field is not set,
  # the default for the value assigned to the field will be used
  # (e.g. J for Hashes, i for Integer, etc).
  #
  # @param fieldname [Symbol] the field name (it is not required that
  #   the field exists already)
  # @param datatype [RGFA::Line::FIELD_DATATYPE] the datatype
  # @raise [RGFA::Line::CustomOptfieldNameError] if +fieldname+ is not a
  #   valid custom optional name (and +validate[:tags]+)
  # @raise [RGFA::Line::UnknownDatatype] if +datatype+ is not
  #   a valid datatype for optional fields
  # @return [RGFA::Line::FIELD_DATATYPE] the datatype
  def set_datatype(fieldname, datatype)
    unless OPTFIELD_DATATYPE.include?(datatype)
      raise RGFA::Line::UnknownDatatype, "Unknown datatype: #{datatype}"
    end
    validate_custom_optional_fieldname!(fieldname) if @validate >= 1
    @datatype[fieldname] = datatype
  end

  # Set the value of a field.
  #
  # @param fieldname [Symbol] the name of the field to set
  #   (required field, predefined optional field (uppercase) or custom optional
  #   field name (lowercase))
  # @raise [RGFA::Line::FieldnameError] if +fieldname+ is not a
  #   valid predefined or custom optional name (and +validate[:tags]+)
  # @return [Object] +value+
  def set(fieldname, value)
    if @data.has_key?(fieldname) or predefined_optional_fieldname?(fieldname)
      return set_existing_field(fieldname, value)
    elsif (@validate == 0) or valid_custom_optional_fieldname?(fieldname)
      define_field_methods(fieldname)
      if @datatype[fieldname]
        return set_existing_field(fieldname, value)
      else
        @datatype[fieldname] = value.default_gfa_datatype
        return @data[fieldname] = value
      end
    else
      raise RGFA::Line::FieldnameError,
        "#{fieldname} is not an existing or predefined field or a "+
        "valid custom optional field"
    end
  end

  # Get the value of a field
  # @param fieldname [Symbol] name of the field
  # @param frozen [Boolean] <i>defaults to: +false+</i> return a frozen value;
  #   this guarantees that a validation will not be necessary on output
  #   if the field value has not been changed using #set
  # @return [Object,nil] value of the field
  #   or +nil+ if field is not defined
  def get(fieldname, frozen: false)
    v = @data[fieldname]
    if v.kind_of?(String)
      t = field_datatype(fieldname)
      if t != :Z and t != :seq
        # value was not parsed or was set to a string by the user
        return (@data[fieldname] = v.parse_gfa_field(datatype: t,
                                                     validate_strings:
                                                       @validate >= 2))
      else
         v.validate_gfa_field!(t, fieldname) if (@validate >= 5)
      end
    else
      if (@validate >= 5)
        t = field_datatype(fieldname)
        v.validate_gfa_field!(t, fieldname)
      end
    end
    return v
  end

  # Value of a field, raising an exception if it is not defined
  # @param fieldname [Symbol] name of the field
  # @raise [RGFA::Line::TagMissingError] if field is not defined
  # @return [Object,nil] value of the field
  def get!(fieldname)
    v = get(fieldname)
    raise RGFA::Line::TagMissingError,
      "No value defined for tag #{fieldname}" if v.nil?
    return v
  end

  # Methods are dynamically created for non-existing but valid optional
  # field names. Methods for predefined optional fields and required fields
  # are created dynamically for each subclass; methods for existing optional
  # fields are created on instance initialization.
  #
  # ---
  #  - (Object) <fieldname>(parse=true)
  # The parsed content of a field. See also #get.
  #
  # <b>Parameters:</b>
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) the parsed content of the field
  # - (nil) if the field does not exist, but is a valid optional field name
  #
  # ---
  #  - (Object) <fieldname>!(parse=true)
  # The parsed content of a field, raising an exception if not available.
  # See also #get!.
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) the parsed content of the field
  #
  # <b>Raises:</b>
  # - (RGFA::Line::TagMissingError) if the field does not exist
  #
  # ---
  #
  #  - (self) <fieldname>=(value)
  # Sets the value of a required or optional
  # field, or creates a new optional field if the fieldname is
  # non-existing but valid. See also #set, #set_datatype.
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
    when :existing
      case operation
      when :get
        if args[0] == false
          field_to_s(field_name)
        else
          get(field_name)
        end
      when :get!
        if args[0] == false
          field_to_s!(field_name)
        else
          get!(field_name)
        end
      when :set
        set_existing_field(field_name, args[0])
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
        set(field_name, args[0])
        return nil
      end
    end
  end

  # Redefines respond_to? to correctly handle dynamical methods.
  # @see #method_missing
  def respond_to?(m, include_all=false)
    super || (split_method_name(m)[2] != :invalid)
  end

  # @return self
  # @param validate [Boolean] ignored (compatibility reasons)
  def to_rgfa_line(validate: nil)
    self
  end

  # Equivalence check
  # @return [Boolean] does the line has the same record type,
  #   contains the same optional fields
  #   and all required and optional fields contain the same field values?
  # @see RGFA::Line::Link#==
  #def ==(o)
  #  (o.record_type == self.record_type) and
  #    (o.fieldnames == self.fieldnames) and
  #      (o.fieldnames.all? do |fn|
  #        (o.get(fn) == self.get(fn)) or
  #        field_str()
  #      end)
  #end

  # Validate the RGFA::Line instance
  # @raise [RGFA::FieldParser::FormatError] if any field content is not valid
  # @return [void]
  def validate!
    fieldnames.each {|fieldname| validate_field!(fieldname) }
    validate_record_type_specific_info!
  end

  private

  def n_required_fields
    self.class::REQFIELDS.size
  end

  def field_datatype(fieldname)
    self.class::DATATYPE.fetch(fieldname, @datatype[fieldname])
  end

  def field_or_default_datatype(fieldname, value)
    t = field_datatype(fieldname)
    if t.nil?
      t = value.default_gfa_datatype
      @datatype[fieldname] = t
    end
    return t
  end

  def init_field_value(n ,t, s)
    if @validate >= 3
      s = s.parse_gfa_field(datatype: t, validate_strings: true)
    elsif !DELAYED_PARSING_DATATYPES.include?(t)
      s = s.parse_gfa_field(datatype: t, validate_strings: false)
    end
    @data[n] = s
  end

  def set_existing_field(fieldname, value)
    if @validate >= 5
      value.validate_gfa_field!(field_datatype(fieldname), fieldname)
    end
    @data[fieldname] = value
  end

  def initialize_required_fields(strings)
    if (@validate >= 1) and (strings.size < n_required_fields)
      raise RGFA::Line::RequiredFieldMissingError,
        "#{n_required_fields} required fields expected, "+
        "#{strings.size}) found\n#{strings.inspect}"
    end
    n_required_fields.times do |i|
      n = self.class::REQFIELDS[i]
      init_field_value(n, self.class::DATATYPE[n], strings[i])
    end
  end

  def valid_custom_optional_fieldname?(fieldname)
    /^[a-z][a-z0-9]$/ =~ fieldname
  end

  def validate_custom_optional_fieldname!(fieldname)
    if not valid_custom_optional_fieldname?(fieldname)
      raise RGFA::Line::CustomOptfieldNameError,
        "#{fieldname} is not a valid custom optional field name"
    end
  end

  def predefined_optional_fieldname?(fieldname)
    self.class::PREDEFINED_OPTFIELDS.include?(fieldname)
  end

  def initialize_optional_fields(strings)
    n_required_fields.upto(strings.size-1) do |i|
      n, t, s = strings[i].parse_gfa_optfield
      if (@validate > 0)
        if @data.has_key?(n)
          raise RGFA::Line::DuplicatedOptfieldNameError,
            "Optional field #{n} found multiple times"
        elsif predefined_optional_fieldname?(n)
          unless t == self.class::DATATYPE[n]
            raise RGFA::Line::PredefinedOptfieldTypeError,
              "Optional field #{n} must be of type "+
              "#{self.class::DATATYPE[n]}, #{t} found"
          end
        elsif not valid_custom_optional_fieldname?(n)
            raise RGFA::Line::CustomOptfieldNameError,
              "Custom-defined optional "+
              "fields must be lower case; found: #{n}"
        else
          @datatype[n] = t
        end
      else
        (@datatype[n] = t) if !field_datatype(t)
      end
      init_field_value(n, t, s)
    end
  end

  def split_method_name(m)
    if @data.has_key?(m)
      return m, :get, :existing
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
        state = :existing
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

  #
  # Define field methods for a single field
  #
  def define_field_methods(fieldname)
    define_singleton_method(fieldname) do
      get(fieldname)
    end
    define_singleton_method :"#{fieldname}!" do
      get!(fieldname)
    end
    define_singleton_method :"#{fieldname}=" do |value|
      set_existing_field(fieldname, value)
    end
  end

  #
  # This avoids calls to method_missing for fields which are already defined
  #
  def self.define_field_methods!
    (self::REQFIELDS+self::PREDEFINED_OPTFIELDS).each do |fieldname|
      define_method(fieldname) do
        get(fieldname)
      end
      define_method :"#{fieldname}!" do
        get!(fieldname)
      end
      define_method :"#{fieldname}=" do |value|
        set_existing_field(fieldname, value)
      end
    end
  end
  private_class_method :define_field_methods!

end

# Error raised if the record_type is not one of RGFA::Line::RECORD_TYPES
class RGFA::Line::UnknownRecordTypeError      < RGFA::Error;     end

# Error raised if an invalid datatype symbol is found
class RGFA::Line::UnknownDatatype             < RGFA::Error;     end

# Error raised if an invalid fieldname symbol is found
class RGFA::Line::FieldnameError              < RGFA::Error;     end

# Error raised if optional tag is not present
class RGFA::Line::TagMissingError             < RGFA::Error; end

# Error raised if too less required fields are specified.
class RGFA::Line::RequiredFieldMissingError   < RGFA::Error; end

# Error raised if a non-predefined optional field uses upcase
# letters.
class RGFA::Line::CustomOptfieldNameError     < RGFA::Error; end

# Error raised if an optional field tag name is used more than once.
class RGFA::Line::DuplicatedOptfieldNameError < RGFA::Error; end

# Error raised if the type of a predefined optional field does not
# respect the specified type.
class RGFA::Line::PredefinedOptfieldTypeError < RGFA::Error;     end

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
  # @raise [RGFA::Error] if the fields do not comply to the RGFA specification
  # @param validate [Integer] <i>(defaults to: 2)</i>
  #   see RGFA::Line#initialize
  def to_rgfa_line(validate: 2)
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
  # @raise [RGFA::Error] if the fields do not comply to the RGFA specification
  # @param validate [Integer] <i>(defaults to: 2)</i>
  #   see RGFA::Line#initialize
  def to_rgfa_line(validate: 2)
    RGFA::Line.subclass(shift).new(self, validate: validate)
  end

end
