#
# This class is not meant to be directly initialized by the end-user;
# instead the end-user will typically initialize one of its child classes,
# which define the different record types.
#
class GFA::Line

  Separator = "\t"

  #
  # In case new record types are defined, add them here and define the
  # corresponding class in a file gfa/line/<downcasetypename>.rb;
  # the file will be automatically required
  #
  RecordTypes =
    {
      "H" => "GFA::Line::Header",
      "S" => "GFA::Line::Segment",
      "L" => "GFA::Line::Link",
      "C" => "GFA::Line::Containment",
      "P" => "GFA::Line::Path"
    }

  def self.validate_record_type!(rtype)
    if !GFA::Line::RecordTypes.has_key?(rtype)
      raise GFA::Line::UnknownRecordTypeError,
        "Record type unknown: '#{rtype}'"
    end
  end

  #
  # <fields> is an array of strings, the content of a line
  #
  # <reqfield_definitions> is an array of two-element arrays,
  # which contain a field name and a regular expression;
  # the field name will be used as method name; the regular expression
  # will be used to validate the content of the field
  #
  # <optfield_types> is a (possibly empty) hash of optfield_tag to optfield_type
  # pairs; if an instance of the predefined optfield_tag is specified in a
  # record, it will be required to be of type optfield_type
  #
  # <reqfield_cast> is a (possibly empty) hash of field name to lambda,
  # where the lambda defines a conversion of the value of the field
  # which is performed when the field name getter method is called
  def initialize(fields,
                 reqfield_definitions,
                 optfield_types,
                 reqfield_cast = {})
    @reqfield_definitions = reqfield_definitions
    @optfield_types = optfield_types
    @reqfield_cast = reqfield_cast
    @fields = fields
    @fieldnames = []
    initialize_required_fields
    self.class.validate_record_type!(self.record_type)
    initialize_optional_fields
  end

  attr_reader :fieldnames

  def required_fieldnames
    @fieldnames[0..(n_required_fields-1)]
  end

  def optional_fieldnames
    @fieldnames.size > n_required_fields ?
      @fieldnames[n_required_fields..-1] : []
  end

  def clone
    if self.class === GFA::Line
      self.class.new(@fields.clone.map{|e|e.clone}, @reqfield_definitions.clone,
                     @optfield_types.clone, @reqfield_cast.clone)
    else
      self.class.new(@fields.clone.map{|e|e.clone})
    end
  end

  def to_s
    @fields.join(GFA::Line::Separator)
  end

  def add_optfield(optfield)
    if !optfield.respond_to?(:to_gfa_optfield)
      raise ArgumentError,
        "The argument must be a string representing "+
        "an optional field or an GFA::Optfield instance"
    end
    optfield = optfield.to_gfa_optfield
    sym = optfield.tag.to_sym
    if @fieldnames[n_required_fields..-1].include?(sym)
      raise GFA::Line::DuplicateOptfieldNameError,
        "Optional tag '#{optfield.tag}' exists more than once"
    end
    validate_optional_field!(optfield)
    @fields << optfield
    @fieldnames << sym
  end

  def <<(optfield)
    add_optfield(optfield)
  end

  def set_field(i, value)
    if  i >= @fieldnames.size
      raise ArgumentError, "Line does not have a field number #{i}"
    end
    if i < n_required_fields
      @fields[i] = value
      validate_required_field!(i)
    else
      @fields[i].value = value
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

  def []=(i, value)
    set_field(i, value)
  end

  def [](i)
    get_field(i, true)
  end

  def method_missing(m, *args, &block)
    ms, var, i = process_unknown_method(m)
    if !i.nil?
      return (var == :set) ? (self[i] = args[0]) : get_field(i, *args)
    elsif ms =~ /^#{GFA::Optfield::TagRegexp}$/
      raise "No value defined for tag #{ms}" if var == :bang
      return (var == :set) ? auto_create_optfield(ms, args[0]) : nil
    end
    super
  end

  def respond_to?(m, include_all=false)
    retval = super
    if !retval
      ms, var, i = process_unknown_method(m)
      return (!i.nil? or ms =~ /^#{GFA::Optfield::TagRegexp}$/)
    end
    return retval
  end

  def to_gfa_line
    self
  end

  def ==(o)
    (o.fieldnames == self.fieldnames) and
      (o.fieldnames.all? {|fn|o.send(fn) == self.send(fn)})
  end

  def self.other_orientation(orientation)
    raise "Unknown orientation" if !["+","-"].include?(orientation)
    return orientation == "+" ? "-" : "+"
  end

  def self.other_end_type(end_type)
    raise "Unknown end_type" if ![:B,:E].include?(end_type)
    return end_type == :B ? :E : :B
  end

  def validate!
    validate_required_fields!
    validate_optional_fields!
    self.class.validate_record_type!(self.record_type)
  end

  private

  def n_required_fields
    @reqfield_definitions.size
  end

  def initialize_required_fields
    validate_reqfield_definitions!
    @fieldnames += @reqfield_definitions.map{|name,re| name.to_sym}
    validate_required_fields!
  end

  def initialize_optional_fields
    validate_optfield_types!
    if @fields.size > n_required_fields
      optfields = @fields[n_required_fields..-1].dup
      @fields = @fields[0..(n_required_fields-1)]
      optfields.each { |f| self << f.to_gfa_optfield }
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

  def auto_create_optfield(tagname, value)
    self << GFA::Optfield.new_autotype(tagname, value)
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

class GFA::Line::UnknownRecordTypeError      < TypeError;     end
class GFA::Line::InvalidFieldNameError       < ArgumentError; end
class GFA::Line::RequiredFieldMissingError   < ArgumentError; end
class GFA::Line::RequiredFieldTypeError      < TypeError;     end
class GFA::Line::CustomOptfieldNameError     < ArgumentError; end
class GFA::Line::DuplicateOptfieldNameError  < ArgumentError; end
class GFA::Line::PredefinedOptfieldTypeError < TypeError;     end

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

  def to_gfa_line
    components = split(GFA::Line::Separator)
    record_type = components[0]
    GFA::Line.validate_record_type!(record_type)
    eval(GFA::Line::RecordTypes[record_type]).new(split(GFA::Line::Separator))
  end

end
