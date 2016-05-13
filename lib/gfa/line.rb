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
  # <optfield_types> is an hash of optfield_tag to optfield_type
  # pairs; if an instance of the predefined optfield_tag is specified in a
  # record, it will be required to be of type optfield_type
  #
  def initialize(fields, reqfield_definitions, optfield_types)
    validate_field_definitions!(reqfield_definitions, optfield_types)
    validate_required_fields(fields, reqfield_definitions)
    validate_optional_fields(fields, optfield_types)
    @fields = fields
    @fieldnames = @required_fieldnames + @optional_fieldnames
  end

  def to_specific_class
    self.class.validate_record_type!(record_type)
    eval(GFA::Line::RecordTypes[record_type]).new(self)
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

  @@fields_methods = [ :"[]" ]

  def method_missing(m, *args, &block)
    if @@fields_methods.include?(m)
      @fields.send(m, *args, &block)
    elsif (i = @fieldnames.index?(m))
      @fields[i]
    else
      super
    end
  end

  def respond_to?(m, include_private = false)
    @@fields_methods.include?(m) || super
  end

  private

  def validate_field_definitions!(reqfield_definitions, optfield_types)
    if !reqfield_definitions.kind_of?(Array)
      raise ArgumentError, "Argument 'reqfield_definitions' must be an Array"
    end
    if !optfield_types.kind_of?(Hash)
      raise ArgumentError, "Argument 'optfield_types' must be a Hash"
    end
    names = []
    reqfield_definitions.each do |name, regexp|
      if respond_to?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of required field, '#{name}' is a method of GFA::Line"
      end
      if names.include?(name)
        raise ArgumentError,
          "The names of required fields must be unique ('#{name}' found twice)"
      end
      names << name
    end
    optfield_types.each do |name, type|
      if respond_to?(name.to_sym)
        raise GFA::Line::InvalidFieldNameError,
          "Invalid name of optional field, '#{name}' is a method of GFA::Line"
      end
      if names.include?(name)
        raise ArgumentError,
          "The names of optional fields must be unique and cannot be "+
          "identical to a required field name ('#{name}' found twice)"
      end
      names << name
    end
  end

  def validate_required_fields(fields, reqfield_definitions)
    n_required = reqfield_definitions.size
    @required_fieldnames = reqfield_definitions.map{|name,re| name.to_sym}
    if fields.size < n_required
      raise GFA::Line::RequiredFieldMissingError,
        "#{fields.size} required fields, #{n_required}) found"
    end
    reqfield_definitions.each_with_index do |name_regexp, i|
      name, regexp = name_regexp
      if fields[i] !~ regexp
        raise GFA::Line::RequiredFieldTypeError,
          "Field n.#{i} ('#{name}') has a wrong format, expected: #{regexp}"
      end
    end
  end

  def validate_optional_fields!(fields, optfield_types)
    predefopt = optfield_types.keys
    @optional_fieldnames = []
    fields[@required_fieldnames.size..-1].each do |f|
      f = f.to_gfa_optfield
      if @optional_fieldnames.include?(f.tag.to_sym)
        raise GFA::Line::DuplicateOptfieldNameError,
          "Optional tag '#{f.tag}' specified more than once"
      end
      @optional_fieldnames << f.tag.to_sym
      if predefopt.include?(f.tag)
        if optfield_types[f.tag] != f.type
          raise GFA::Line::PredefinedOptfieldTypeError,
            "Optional field #{f.tag} must be of type #{optfield_types[f.tag]}"
        end
      else
        if opt.tag !~ /[a-z][a-z0-9]/
          raise GFA::Line::CustomOptfieldNameError,
          "Invalid name of custom-defined optional field,"+
          "'#{name}' is now in lower case"
        end
      end
      if @required_fieldnames.include?(f.tag.to_sym)
        raise GFA::Line::CustomOptfieldNameError,
          "Invalid name of custom-defined optional field, "+
          "'#{name}' is a required field name"
      elsif respond_to?(f.tag.to_sym)
        raise GFA::Line::CustomOptfieldNameError,
          "Invalid name of custom-defined optional field, "+
          "'#{name}' is a method of GFA::Line"
      end
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
  require "./#{rtclass.downcase.gsub("::","/")}.rb"
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
