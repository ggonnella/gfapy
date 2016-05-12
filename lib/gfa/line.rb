class GFA::Line

  Separator = "\t"

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
      raise ArgumentError,
        "Record type unknown: '#{rtype}'"
    end
  end

  def initialize(fields, required_definitions, optfield_predefined_types)
    handle_required_fields(fields, required_definitions)
    handle_optional_fields(fields, optfield_predefined_types)
  end

  def to_specific_class
    self.class.validate_record_type!(record_type)
    eval(GFA::Line::RecordTypes[record_type]).new(@fields)
  end

  def reqfields
    @fields[0..@n_required-1]
  end

  def optfields
    @fields[@n_required..-1]
  end

  def to_s
    @fields.join(GFA::Line::Separator)
  end

  private

  def handle_required_fields(fields, required_definitions)
    if !required_definitions.kind_of?(Array)
      raise ArgumentError,
        "Argument 'required' must be an Array"
    end
    @n_required = required_definitions.size
    if fields.size < @n_required
      raise TypeError,
        "#{fields.size} required fields, #@n_required) found"
    end
    @fields = fields[0..@n_required-1]
    required_definitions.each_with_index do |name_regexp, i|
      name, regexp = name_regexp
      if @fields[i] !~ regexp
        raise TypeError,
          "Field '#{name}' has a wrong format, expected: #{regexp}"
      end
      instance_eval("def #{name}; @fields[#{i}]; end")
    end
  end

  def handle_optional_fields(fields, optfield_predefined_types)
    fields[@n_required..-1].each do |f|
      optfield = f.to_gfa_optfield
      if optfield_predefined_types
        type = optfield_predefined_types[optfield.tag]
        if !type.nil? and type != optfield.type
          raise TypeError,
            "Optional field #{optfield.tag} must be of type #{type}"
        end
      end
      if respond_to?(optfield.tag.to_sym)
        raise ArgumentError,
          "Tag '#{optfield.tag}' existed already"
      end
      instance_eval("def #{optfield.tag}; @fields[#{@fields.size}]; end")
      @fields << optfield
    end
  end

end

class String

  def to_gfa_line
    components = split(GFA::Line::Separator)
    record_type = components[0]
    GFA::Line.validate_record_type!(record_type)
    eval(GFA::Line::RecordTypes[record_type]).new(split(GFA::Line::Separator))
  end

end

require "./gfa/line/header.rb"
require "./gfa/line/segment.rb"
require "./gfa/line/link.rb"
require "./gfa/line/containment.rb"
require "./gfa/line/path.rb"

