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

  attr_reader :fields, :fieldnames, :required_fieldnames, :optional_fieldnames

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
  def initialize(fields, reqfield_definitions, optfield_types,
                 reqfield_cast = {})
    @reqfield_definitions = reqfield_definitions
    @optfield_types = optfield_types
    @reqfield_cast = reqfield_cast
    @fields = fields
    @fieldnames = []
    validate_field_definitions!
    validate_required_fields!
    validate_optional_fields!
    self.class.validate_record_type!(self.record_type)
  end

  # allow to access the required fields only
  def reqfields
    @fields[0..@required_fieldnames.size-1]
  end

  # allow to access the optional fields only
  def optfields
    @fields[@required_fieldname.size..-1]
  end

  def to_s
    @fields.join(GFA::Line::Separator)
  end

  def <<(optfield)
    if !optfield.kind_of?(GFA::Optfield)
      raise ArgumentError, "<< argument must be a GFA::Optfield instance"
    end
    sym = optfield.tag.to_sym
    if @optional_fieldnames.include?(sym)
      raise GFA::Line::DuplicateOptfieldNameError,
        "Optional tag '#{optfield.tag}' specified more than once"
    end
    validate_optional_field!(optfield)
    @fields << optfield
    @optional_fieldnames << sym
    @fieldnames << sym
  end

  def []=(i, value)
    if  i >= @fieldnames.size
      raise ArgumentError, "Line does not have a field number #{i}"
    end
    if i < @required_fieldnames.size
      @fields[i] = value
      validate_required_field!(i)
    else
      @fields[i].value = value
    end
  end

  def [](i)
    if  i >= @fieldnames.size
      raise ArgumentError, "Line does not have a field number #{i}"
    end
    if i < @required_fieldnames.size
      return @fields[i]
    else
      return @fields[i].value
    end
  end

  def method_missing(m, *args, &block)
    i = @fieldnames.index(m)
    if !i.nil?
      raise ArgumentError, "#{m} takes at most 1 argument" if args.size > 1
      if @reqfield_cast[m] and (args[0] or args.size == 0)
        return @reqfield_cast[m].call(self[i])
      else
        return self[i]
      end
    end
    if m.to_s =~ /(.*)=/
      i = @fieldnames.index($1.to_sym)
      if !i.nil?
        raise ArgumentError, "#{m} requires 1 argument" if args.size != 1
        return (self[i] = args[0])
      end
    end
    super
  end

  private

  def validate_field_definitions!
    if !@reqfield_definitions.kind_of?(Array)
      raise ArgumentError, "Argument 'reqfield_definitions' must be an Array"
    end
    if !@optfield_types.kind_of?(Hash)
      raise ArgumentError, "Argument 'optfield_types' must be a Hash"
    end
    names = []
    @reqfield_definitions.each do |name, regexp|
      if respond_to?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of required field, '#{name}' is a method of GFA::Line"
      end
      if names.include?(name.to_sym)
        raise ArgumentError,
          "The names of required fields must be unique ('#{name}' found twice)"
      end
      names << name.to_sym
    end
    @optfield_types.each do |name, type|
      if respond_to?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of optional field, '#{name}' is a method of GFA::Line"
      end
      if names.include?(name.to_sym)
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
    if @required_fieldnames.include?(f.tag.to_sym)
      raise GFA::Line::CustomOptfieldNameError,
        "Invalid name of custom-defined optional field, "+
        "'#{f.tag}' is a required field name"
    elsif respond_to?(f.tag.to_sym)
      raise GFA::Line::CustomOptfieldNameError,
        "Invalid name of custom-defined optional field, "+
        "'#{f.tag}' is a method of GFA::Line"
    end
  end

  def validate_required_fields!
    n_required = @reqfield_definitions.size
    @required_fieldnames = @reqfield_definitions.map{|name,re| name.to_sym}
    @fieldnames = @required_fieldnames.dup
    if @fields.size < n_required
      raise GFA::Line::RequiredFieldMissingError,
        "#{n_required} required fields, #{@fields.size}) found"
    end
    n_required.times {|i| validate_required_field!(i)}
  end

  def validate_optional_fields!
    @optional_fieldnames = []
    optfields = @fields[@required_fieldnames.size..-1].dup
    @fields = @fields[0..@required_fieldnames.size-1]
    optfields.each { |f| self << f.to_gfa_optfield }
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
