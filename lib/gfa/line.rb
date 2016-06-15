#
# Generic representation of a record of a GFA file.
#
class GFA::Line

  # Separator in the string representation of GFA lines
  Separator = "\t"

  # List of allowed record_type values and the associated subclasses of
  # {GFA::Line}
  #
  # In case new record types are defined, add them here and define the
  # corresponding class (in <tt>lib/gfa/line/<downcasetypename>.rb</tt>).
  # All file in the +line+ subdirectory are automatically required.
  #
  RecordTypes =
    {
      "H" => "GFA::Line::Header",
      "S" => "GFA::Line::Segment",
      "L" => "GFA::Line::Link",
      "C" => "GFA::Line::Containment",
      "P" => "GFA::Line::Path"
    }

  # @raise if record type is not one of GFA::Line::RecordTypes
  def self.validate_record_type!(rtype)
    if !GFA::Line::RecordTypes.has_key?(rtype)
      raise GFA::Line::UnknownRecordTypeError,
        "Record type unknown: '#{rtype}'"
    end
  end

  # @note
  #   This class is usually not meant to be directly initialized by the user;
  #   initialize instead one of its child classes, which define the concrete
  #   different record types.
  #
  # @param fields [Array<String>] the content of the line
  # @param reqfield_definitions
  #   [Array<Array(Symbol,Regex)>] defines
  #   the order of the required fields (Symbol) in the line and their
  #   validators (Regex);
  #   an element _must_ be present for each required field;
  #   to accept any string, use the regex +/.*/ as validator
  # @param optfield_types [Hash{Symbol=>String}]
  #   <i>(possibly empty)</i> defines the predefined optional
  #   fields and their required type (String)
  # @param reqfield_cast [Hash{Symbol=>Lambda}]
  #   defines procedures (Lambda) for casting selected required fields
  #   (Symbol) into instances of the corresponding Ruby classes; the
  #   lambda shall take one argument (the field string value) and
  #   return one argument (the Ruby value)
  # @return [GFA::Line]
  # @raise [GFA::Line::UnknownRecordTypeError]
  #   if the record_type is not one of +GFA::Line::RecordTypes+
  # @raise [GFA::Line::InvalidFieldNameError]
  #   if a field has the same name as a method of the class
  # @raise [GFA::Line::RequiredFieldMissingError]
  #   if too less required fields are specified
  # @raise [GFA::Line::RequiredFieldTypeError]
  #   if the type of a required field does not match the validation regexp
  # @raise [GFA::Line::CustomOptfieldNameError]
  #   if a non-predefined optional field uses upcase letters
  # @raise [GFA::Line::DuplicateOptfieldNameError]
  #   if an optional field tag name is used more than once
  # @raise [GFA::Line::PredefinedOptfieldTypeError]
  #   if the type of a predefined optional field does not
  #   respect the specified type.
  def initialize(fields,
                 reqfield_definitions,
                 optfield_types,
                 reqfield_cast = {},
                 validate: true)
    @reqfield_definitions = reqfield_definitions
    @optfield_types = optfield_types
    @reqfield_cast = reqfield_cast
    @fields = fields
    @fieldnames = []
    @validate = validate
    initialize_required_fields
    self.class.validate_record_type!(self.record_type) if @validate
    initialize_optional_fields
  end

  attr_reader :fieldnames

  # @return [Array<Symbol>] name of the required fields
  def required_fieldnames
    @fieldnames[0..(n_required_fields-1)]
  end

  # @return [Array<Symbol>] name of the optional fields
  def optional_fieldnames
    @fieldnames.size > n_required_fields ?
      @fieldnames[n_required_fields..-1] : []
  end

  # @return [self.class] deep copy of self (GFA::Line or subclass)
  def clone
    if self.class === GFA::Line
      self.class.new(@fields.clone.map{|e|e.clone}, @reqfield_definitions.clone,
                     @optfield_types.clone, @reqfield_cast.clone)
    else
      self.class.new(@fields.clone.map{|e|e.clone})
    end
  end

  # @return [String] a string representation of self
  def to_s
    @fields.join(GFA::Line::Separator)
  end

  # @param optfield [String|GFA::Optfield] an optional field to add to the line
  # @raise [GFA::Line::DuplicateOptfieldNameError] if the line already
  #   contains an optional field with the same tag name
  # @return self
  def add_optfield(optfield)
    if !optfield.respond_to?(:to_gfa_optfield)
      raise ArgumentError,
        "The argument must be a string representing "+
        "an optional field or an GFA::Optfield instance"
    end
    optfield = optfield.to_gfa_optfield(validate: @validate)
    sym = optfield.tag.to_sym
    if @fieldnames[n_required_fields..-1].include?(sym)
      raise GFA::Line::DuplicateOptfieldNameError,
        "Optional tag '#{optfield.tag}' exists more than once"
    end
    validate_optional_field!(optfield) if @validate
    @fields << optfield
    @fieldnames << sym
    self
  end

  # Remove an optional field from the line
  # @param optfield_tag [#to_sym] the tag name of the optfield to remove
  # @return self
  def rm_optfield(optfield_tag)
    i = optional_fieldnames.index(optfield_tag.to_sym)
    if !i.nil?
      i += n_required_fields
      @fieldnames.delete_at(i)
      @fields.delete_at(i)
    end
    self
  end

  # @param optfield_tag [#to_sym]
  # @return GFA::Optfield
  def optfield(optfield_tag)
    i = optional_fieldnames.index(optfield_tag.to_sym)
    return i.nil? ? nil : @fields[i + n_required_fields]
  end

  # @see add_optfield
  def <<(optfield)
    add_optfield(optfield)
  end

  # Three methods are dynamically created for each existing field name as well
  # as for each non-existing but valid optional field name.
  #
  # ---
  #  - (Object) <fieldname>(cast: false)
  # The value of the field.
  #
  # <b>Parameters:</b>
  # - +*cast*+ (Boolean) -- <i>(default: true)</i> if +false+,
  #   return original string, otherwise cast into ruby type
  #
  # <b>Returns:</b>
  # - (String|Hash|Array|Integer|Float) if field exists and +cast+ is true
  # - (String) if field exists and +cast+ is false
  # - (nil) if the field does not exist, but is a valid optional field name
  #
  # ---
  #  - (Object) <fieldname>!(cast: false)
  # Banged version of +<fieldname>+.
  #
  # <b>Parameters:</b>
  # - +*cast*+ (Boolean) -- <i>(default: true)</i> if +false+,
  #   return original string, otherwise cast into ruby type
  #
  # <b>Returns:</b>
  # - (String|Hash|Array|Integer|Float) if field exists and +cast+ is true
  # - (String) if field exists and +cast+ is false
  #
  # <b>Raises:</b>
  # - (GFA::Line::TagMissingError) if the field does not exist
  #
  # ---
  #
  #  - (self) <fieldname>=(value)
  # Sets the value of a required or optional
  # field, or creates a new optional field if the fieldname is
  # non-existing but valid. In the latter case, the type of the
  # optional field is selected, depending on the class of +value+
  # (see GFA::Optfield::new_autotype() method).
  #
  # <b>Parameters:</b>
  # - +*value*+ (String|Hash|Array|Integer|Float) value to set
  #
  # <b>Returns:</b>
  # - (self)
  #
  # ---
  #
  def method_missing(m, *args, &block)
    ms, var, i = process_unknown_method(m)
    if !i.nil?
      return (var == :set) ? (self[i] = args[0]) : get_field(i, *args)
    elsif ms =~ /^#{GFA::Optfield::TAG_REGEXP}$/
      raise GFA::Line::TagMissingError,
        "No value defined for tag #{ms}" if var == :bang
      return (var == :set) ? auto_create_optfield(ms, args[0]) : nil
    end
    super
  end

  # Redefines respond_to? to correctly handle dynamical methods.
  # @see #method_missing
  def respond_to?(m, include_all=false)
    retval = super
    if !retval
      pum_retvals = process_unknown_method(m)
      ms = pum_retvals[0]
      i = pum_retvals[2]
      return (!i.nil? or ms =~ /^#{GFA::Optfield::TAG_REGEXP}$/)
    end
    return retval
  end

  # @return self
  # @param [Boolean] validate ignored (compatibility reasons)
  def to_gfa_line(validate: true)
    self
  end

  # @return [Boolean] does the line contains the same optional fields
  #   and all required and optional fields contain the same field values?
  def ==(o)
    (o.fieldnames == self.fieldnames) and
      (o.fieldnames.all? {|fn|o.send(fn) == self.send(fn)})
  end

  # @raise if the field content is not valid
  def validate!
    validate_required_fields!
    validate_optional_fields!
    self.class.validate_record_type!(self.record_type)
  end

  private

  def []=(i, value)
    set_field(i, value)
  end

  def [](i)
    get_field(i, true)
  end

  def set_field(i, value)
    if i >= @fieldnames.size
      raise ArgumentError, "Line does not have a field number #{i}"
    end
    if i < n_required_fields
      @fields[i] = value
      validate_required_field!(i) if @validate
    else
      if value.nil?
        rm_optfield(@fieldnames[i])
      else
        @fields[i].value = value
      end
    end
  end

  def get_field(i, autocast = true)
    if i >= @fieldnames.size
      raise ArgumentError, "Line does not have a field number #{i}"
    end
    if i < n_required_fields
      if autocast and @reqfield_cast.has_key?(@fieldnames[i])
        return @reqfield_cast[@fieldnames[i]].call(@fields[i])
      else
        return @fields[i]
      end
    else
      return @fields[i].value(autocast)
    end
  end

  def n_required_fields
    @reqfield_definitions.size
  end

  def initialize_required_fields
    validate_reqfield_definitions! if @validate
    @fieldnames += @reqfield_definitions.map{|name,re| name.to_sym}
    validate_required_fields! if @validate
  end

  def initialize_optional_fields
    validate_optfield_types! if @validate
    if @fields.size > n_required_fields
      optfields = @fields[n_required_fields..-1].dup
      @fields = @fields[0..(n_required_fields-1)]
      optfields.each { |f| self << f.to_gfa_optfield(validate: @validate) }
    end
  end

  def process_unknown_method(m)
    ms = m.to_s
    var = nil
    if ms[-1] == "!"
      var = :bang
      ms.chop!
    elsif ms[-1] == "="
      var = :set
      ms.chop!
    end
    i = @fieldnames.index(ms.to_sym)
    return ms, var, i
  end

  def auto_create_optfield(tagname, value, validate: @validate)
    return self if value.nil?
    self << GFA::Optfield.new_autotype(tagname, value, validate: validate)
  end

  def validate_reqfield_definitions!
    if !@reqfield_definitions.kind_of?(Array)
      raise ArgumentError, "Argument 'reqfield_definitions' must be an Array"
    end
    names = []
    @reqfield_definitions.each do |name, regexp|
      if (self.methods+self.private_methods).include?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of required field, '#{name}' is a method of GFA::Line"
      end
      if names.include?(name.to_sym)
        raise ArgumentError,
          "The names of required fields must be unique ('#{name}' found twice)"
      end
      names << name.to_sym
    end
  end

  def validate_optfield_types!
    if !@optfield_types.kind_of?(Hash)
      raise ArgumentError, "Argument 'optfield_types' must be a Hash"
    end
    @optfield_types.each do |name, type|
      if (self.methods+self.private_methods).include?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of optional field, '#{name}' is a method of GFA::Line"
      end
      if required_fieldnames.include?(name.to_sym)
        raise ArgumentError,
          "The names of optional fields cannot be "+
          "identical to a required field name ('#{name}' found twice)"
      end
    end
  end

  def validate_required_field!(i)
    regexp = /^#{@reqfield_definitions[i][1]}$/
    if @fields[i] !~ regexp
      raise GFA::Line::RequiredFieldTypeError,
        "Field n.#{i} ('#{@fieldnames[i]}') has a wrong format, "+
        "expected: #{regexp}"
    end
  end

  def validate_required_fields!
    if @fields.size < n_required_fields
      raise GFA::Line::RequiredFieldMissingError,
        "#{n_required_fields} required fields, #{@fields.size}) found\n"+
        "#{@fields.inspect}"
    end
    n_required_fields.times {|i| validate_required_field!(i)}
  end

  def validate_optional_field!(f)
    predefopt = @optfield_types.keys
    if predefopt.include?(f.tag)
      if @optfield_types[f.tag] != f.type
        raise GFA::Line::PredefinedOptfieldTypeError,
          "Optional field #{f.tag} must be of type #{@optfield_types[f.tag]}"
      end
    else
      if f.tag !~ /^[a-z][a-z0-9]$/
        raise GFA::Line::CustomOptfieldNameError,
        "Invalid name of custom-defined optional field,"+
        "'#{f.tag}' is now in lower case"
      end
    end
    if required_fieldnames.include?(f.tag.to_sym)
      raise GFA::Line::CustomOptfieldNameError,
        "Invalid name of custom-defined optional field, "+
        "'#{f.tag}' is a required field name"
    elsif (self.methods+self.private_methods).include?(f.tag.to_sym)
      raise GFA::Line::CustomOptfieldNameError,
        "Invalid name of custom-defined optional field, "+
        "'#{f.tag}' is a method of GFA::Line"
    end
  end

  def validate_optional_fields!
    found = []
    @fields[n_required_fields..-1].each do |optfield|
      validate_optional_field!(optfield)
      sym = optfield.tag.to_sym
      if found.include?(sym)
        raise GFA::Line::DuplicateOptfieldNameError,
          "Optional tag '#{optfield.tag}' exists more than once"
      end
      found << sym
    end
  end

end

# Error raised if the record_type is not one of GFA::Line::RecordTypes
class GFA::Line::UnknownRecordTypeError      < TypeError;     end

# Error raised if a field has the same name as a method of the class;
# This is required by the dynamic method generation system.
class GFA::Line::InvalidFieldNameError       < ArgumentError; end

# Error raised if too less required fields are specified.
class GFA::Line::RequiredFieldMissingError   < ArgumentError; end

# Error raised if the type of a required field does not match the
# validation regexp.
class GFA::Line::RequiredFieldTypeError      < TypeError;     end

# Error raised if a non-predefined optional field uses upcase
# letters.
class GFA::Line::CustomOptfieldNameError     < ArgumentError; end

# Error raised if an optional field tag name is used more than once.
class GFA::Line::DuplicateOptfieldNameError  < ArgumentError; end

# Error raised if the type of a predefined optional field does not
# respect the specified type.
class GFA::Line::PredefinedOptfieldTypeError < TypeError;     end

# Error raised if optional tag is not present
class GFA::Line::TagMissingError             < NoMethodError; end

#
# Automatically require the child classes specified in the RecordTypes hash
#
GFA::Line::RecordTypes.values.each do |rtclass|
  require_relative "../#{rtclass.downcase.gsub("::","/")}.rb"
end

#
# Define a String#to_gfa_line method which allow to parse a string
# representation of a gfa_line and obtain an object of the correct record type
# child class of GFA::Line
#
class String

  # @return [GFA::Line or subclass] the line instance coded by the string
  # @raise if the string does not comply to the GFA specification
  # @param validate [Boolean] <i>(default: +true+)</i> if false,
  #   turn off validations
  def to_gfa_line(validate: true)
    components = split(GFA::Line::Separator)
    record_type = components[0]
    GFA::Line.validate_record_type!(record_type) unless !validate
    eval(GFA::Line::RecordTypes[record_type]).new(split(GFA::Line::Separator),
                                                  validate: validate)
  end

end
