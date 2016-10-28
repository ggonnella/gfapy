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
  RECORD_TYPES = [ :H, :S, :L, :C, :P, :"#", :G, :F, :E, :O, :U, nil ]

  # List of data types which are parsed only on access;
  # all other are parsed when read.
  DELAYED_PARSING_DATATYPES = [:cig, :cgs, :lbs, :H, :J, :B]

  # Direction of a segment for links/containments
  DIRECTION = [:from, :to]

  # Orientation of segments in paths/links/containments
  ORIENTATION = [:+, :-]

  # Dependency of record type from version
  # - specific => only for a specific version
  # - generic => same syntax for all versions
  # - different => different syntax in different versions
  RECORD_TYPE_VERSIONS =
  {
    :specific =>
      {:"1.0" => [:C, :L, :P],
       :"2.0" => [:E, :G, :F, :O, :U, nil]},
    :generic => [:H, :"#"],
    :different => [:S]
  }

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
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  #
  # <b> Constants defined by subclasses </b>
  #
  # Subclasses of RGFA::Line _must_ define the following constants:
  # - RECORD_TYPE [RGFA::Line::RECORD_TYPES]
  # - POSFIELDS [Hash{Symbol=>(Array<Symbol>,nil)}] positional fields
  #   for each version of the specification (nil if does not apply);
  #   use :generic instead of a version symbol for generic records
  #   (same definition in all versions)
  # - FIELD_ALIAS [Hash{Symbol=>Symbol}] alternative names for positional
  #   fields
  # - PREDEFINED_TAGS [Array<Symbol>] predefined tags
  # - DATATYPE [Hash{Symbol=>Symbol}]:
  #   datatypes for the positional fields and the tags
  #
  # @raise [RGFA::FormatError]
  #   if too less positional fields are specified
  # @raise [RGFA::FormatError]
  #   if a non-predefined tag uses upcase letters
  # @raise [RGFA::NotUniqueError]
  #   if a tag name is used more than once
  # @raise [RGFA::TypeError]
  #   if the type of a predefined tag does not
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
  # - 1: the number of positional fields must be correct; tags
  #      cannot be duplicated; custom tag names must be correct;
  #      predefined tags must have the correct type; only some
  #      fields are validated on initialization or first-time access to
  #      the field content
  # - 2: 1 + all fields are validated on initialization or first-time
  #      access to the field content
  # - 3: 2 + all fields are validated on initialization and record-specific
  #      validations are run (e.g. compare segment LN tag and sequence lenght)
  # - 4: 3 + all fields are validated on writing to string
  # - 5: 4 + all fields are validated by get and set methods
  #
  def initialize(data, validate: 2, virtual: false, version: nil)
    unless self.class.const_defined?(:"RECORD_TYPE")
      raise RGFA::RuntimeError, "This class shall not be directly instantiated"
    end
    @validate = validate
    @virtual = virtual
    @datatype = {}
    @data = {}
    @version = version
    if data.kind_of?(Hash)
      @data.merge!(data)
    else
      # normal initialization, data is an array of strings
      if @version.nil?
        process_unknown_version(data)
      else
        validate_version!
        initialize_positional_fields(data)
        initialize_tags(data)
      end
      validate_record_type_specific_info! if @validate >= 3
      if @version.nil?
        raise "RECORD_TYPE_VERSION has no value for #{record_type}"
      end
    end
  end

  def process_unknown_version(data)
    rt = self.class::RECORD_TYPE
    if RECORD_TYPE_VERSIONS[:generic].include?(rt)
      @version = :generic
      initialize_positional_fields(data)
      initialize_tags(data)
      return
    end
    RECORD_TYPE_VERSIONS[:specific].each do |k, v|
      if v.include?(rt)
        @version = k
        initialize_positional_fields(data)
        initialize_tags(data)
        return
      end
    end
    if RECORD_TYPE_VERSIONS[:different].include?(rt)
      errors = []
      errklass = nil
      RGFA::VERSIONS.each do |version|
        begin
          @version = version
          initialize_positional_fields(data)
          initialize_tags(data)
          return
        rescue => err
          errors << "- #{version}: #{err}"
          errklass = err.class if errklass.nil?
          @data = {}
          @datatype = {}
          next
        end
      end
      raise errklass,
        "Line #{rt} #{data.join(" ")} has an invalid format"+
        " for all known GFA specification versions. \n"+
        "Errors:\n"+
        errors.join("\n")
    end
  end
  private :process_unknown_version

  # @!attribute [r] version
  #   @return [RGFA::VERSIONS, nil] GFA specification version
  attr_reader :version

  # Select a subclass based on the record type
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  # @raise [RGFA::TypeError] if the record_type is not valid
  # @raise [RGFA::VersionError] if the version is unknown
  # @return [Class] a subclass of RGFA::Line
  def self.subclass(record_type, version: nil)
    case version
    when :"1.0"
      subclass_GFA1(record_type)
    when :"2.0"
      subclass_GFA2(record_type)
    when nil
      subclass_unknown_version(record_type)
    else
      raise RGFA::VersionError,
          "GFA specification version unknown (#{version})"
    end
  end

  def self.subclass_GFA1(record_type)
    case record_type.to_sym
    when :H then RGFA::Line::Header
    when :S then RGFA::Line::Segment
    when :"#" then RGFA::Line::Comment
    when :L then RGFA::Line::Link
    when :C then RGFA::Line::Containment
    when :P then RGFA::Line::Path
    else raise RGFA::TypeError,
          "Record type unknown: '#{record_type}'"
    end
  end
  private_class_method :subclass_GFA1

  def self.subclass_GFA2(record_type)
    case record_type.to_sym
    when :H then RGFA::Line::Header
    when :S then RGFA::Line::Segment
    when :"#" then RGFA::Line::Comment
    when :E then RGFA::Line::Edge
    when :F then RGFA::Line::Fragment
    when :G then RGFA::Line::Gap
    when :O then RGFA::Line::OrderedGroup
    when :U then RGFA::Line::UnorderedGroup
    else RGFA::Line::CustomRecord
    end
  end
  private_class_method :subclass_GFA2

  def self.subclass_unknown_version(record_type)
    case record_type.to_sym
    when :H then RGFA::Line::Header
    when :S then RGFA::Line::Segment
    when :"#" then RGFA::Line::Comment
    when :L then RGFA::Line::Link
    when :C then RGFA::Line::Containment
    when :P then RGFA::Line::Path
    when :E then RGFA::Line::Edge
    when :F then RGFA::Line::Fragment
    when :G then RGFA::Line::Gap
    when :O then RGFA::Line::OrderedGroup
    when :U then RGFA::Line::UnorderedGroup
    else RGFA::Line::CustomRecord
    end
  end
  private_class_method :subclass_unknown_version

  # @return [Symbol] record type code
  def record_type
    self.class::RECORD_TYPE
  end

  # @return [Array<Symbol>] name of the positional fields
  # @note these names are not always the field names
  #   in the specification,
  #   as these may be implemented as aliases to cope with
  #   different names for the same content in GFA1 vs GFA2
  # @api private
  def positional_fieldnames
    if @version.nil?
      raise RGFA::VersionError, "Version is not set"
    end
    self.class::POSFIELDS[@version]
  end

  # @return [Array<Symbol>] name of the defined tags
  def tagnames
    (@data.keys - positional_fieldnames)
  end

  # Deep copy of a RGFA::Line instance.
  # @return [RGFA::Line]
  def clone
    data_cpy = {}
    @data.each_pair do |k, v|
      if field_datatype(k) == :J
        data_cpy[k] = JSON.parse(v.to_json)
      elsif v.kind_of?(Array) or v.kind_of?(String)
        data_cpy[k] = v.clone
      else
        data_cpy[k] = v
      end
    end
    cpy = self.class.new(data_cpy, validate: @validate, virtual: @virtual,
                                   version: @version)
    cpy.instance_variable_set("@datatype", @datatype.clone)
    return cpy
  end

  # Is the line virtual?
  #
  # Is this RGFA::Line a virtual line representation
  # (i.e. a placeholder for an expected but not encountered yet line)?
  # @api private
  # @return [Boolean]
  def virtual?
    @virtual
  end

  # Make a virtual line real.
  # @api private
  # This is called when a line which is expected, and for which a virtual
  # line has been created, is finally found. So the line is converted into
  # a real line, by merging in the line information from the found line.
  # @param real_line [RGFA::Line] the real line fou
  def real!(real_line)
    @virtual = false
    real_line.data.each_pair do |k, v|
      @data[k] = v
    end
  end

  # @return [String] a string representation of self
  def to_s
    to_a.join(SEPARATOR)
  end

  # @return [Array<String>] an array of string representations of the fields
  def to_a
    a = [record_type]
    positional_fieldnames.each {|fn| a << field_to_s(fn, tag: false)}
    tagnames.each {|fn| a << field_to_s(fn, tag: true)}
    return a
  end

  # Returns the tags as an array of [fieldname, datatype, value]
  #   triples.
  # @return [Array<[Symbol, Symbol, Object]>]
  def tags
    retval = []
    tagnames.each do |of|
      retval << [of, get_datatype(of), get(of)]
    end
    return retval
  end

  # Remove a tag from the line, if it exists; do nothing if it does not
  # @param tagname [Symbol] the tag name of the tag to remove
  # @return [Object, nil] the deleted value or nil, if the field was not defined
  def delete(tagname)
    if tagnames.include?(tagname)
      @datatype.delete(tagname)
      return @data.delete(tagname)
    else
      return nil
    end
  end

  # Raises an error if the content of the field does not correspond to
  # the field type
  #
  # @param fieldname [Symbol] the tag name of the field to validate
  # @raise [RGFA::FormatError] if the content of the field is
  #   not valid, according to its required type
  # @return [void]
  def validate_field!(fieldname)
    fieldname = self.class::FIELD_ALIAS.fetch(fieldname, fieldname)
    v = @data[fieldname]
    t = field_or_default_datatype(fieldname, v)
    v.validate_gfa_field!(t, fieldname)
    return nil
  end

  # @!macro [new] field_to_s
  #   Compute the string representation of a field.
  #
  #   @param fieldname [Symbol] the tag name of the field
  #   @param tag [Boolean] <i>(defaults to: +false+)</i>
  #     return the tagname:datatype:value representation
  #
  # @raise [RGFA::NotFoundError] if field is not defined
  # @return [String] the string representation
  def field_to_s(fieldname, tag: false)
    fieldname = self.class::FIELD_ALIAS.fetch(fieldname, fieldname)
    field = @data[fieldname]
    raise RGFA::NotFoundError,
      "No value defined for tag #{fieldname}" if field.nil?
    t = field_or_default_datatype(fieldname, field)
    if !field.kind_of?(String)
      field = field.to_gfa_field(datatype: t, fieldname: fieldname)
    end
    field.validate_gfa_field!(t, fieldname) if @validate >= 4
    return tag ? field.to_gfa_tag(fieldname, datatype: t) : field
  end

  # Returns a symbol, which specifies the datatype of a field
  #
  # @param fieldname [Symbol] the tag name of the field
  # @return [RGFA::Field::FIELD_DATATYPE] the datatype symbol
  def get_datatype(fieldname)
    fieldname = self.class::FIELD_ALIAS.fetch(fieldname, fieldname)
    field_or_default_datatype(fieldname, @data[fieldname])
  end

  # Set the datatype of a tag.
  #
  # If an existing tag datatype is changed, its content may become
  # invalid (call #validate_field! if necessary).
  #
  # @param fieldname [Symbol] the field name (it is not required that
  #   the field exists already)
  # @param datatype [RGFA::Field::FIELD_DATATYPE] the datatype
  # @raise [RGFA::ArgumentError] if +datatype+ is not
  #   a valid datatype for tags
  # @return [RGFA::Field::FIELD_DATATYPE] the datatype
  def set_datatype(fieldname, datatype)
    if predefined_tag?(fieldname)
      if get_datatype(fieldname) != datatype
        raise RGFA::RuntimeError,
          "Cannot set the datatype of #{fieldname} to #{datatype}\n"+
          "The datatype of a predefined tag cannot be changed"
        return
      end
    elsif !valid_custom_tagname?(fieldname)
      raise RGFA::FormatError,
        "#{fieldname} is not a valid custom tag name"
    end
    unless RGFA::Field::TAG_DATATYPE.include?(datatype)
      raise RGFA::ArgumentError, "Unknown datatype: #{datatype}"
    end
    @datatype[fieldname] = datatype
  end

  # Set the value of a field.
  #
  # If a datatype for a new custom tag is not set,
  # the default for the value assigned to the field will be used
  # (e.g. J for Hashes, i for Integer, etc).
  #
  # @param fieldname [Symbol] the name of the field to set
  #   (positional field, predefined tag (uppercase) or custom tag (lowercase))
  # @raise [RGFA::FormatError] if +fieldname+ is not a
  #   valid predefined or custom tag name (and +validate[:tags]+)
  # @return [Object] +value+
  def set(fieldname, value)
    if @data.has_key?(fieldname) or predefined_tag?(fieldname)
      return set_existing_field(fieldname, value)
    elsif self.class::FIELD_ALIAS.has_key?(fieldname)
      return set(self.class::FIELD_ALIAS[fieldname], value)
    elsif (@validate == 0) or valid_custom_tagname?(fieldname)
      define_field_methods(fieldname)
      if !@datatype[fieldname].nil?
        return set_existing_field(fieldname, value)
      elsif !value.nil?
        @datatype[fieldname] = value.default_gfa_tag_datatype
        return @data[fieldname] = value
      end
    else
      raise RGFA::FormatError,
        "#{fieldname} is not an existing or predefined field or a "+
        "valid custom tag"
    end
  end

  # Get the value of a field
  # @param fieldname [Symbol] name of the field
  # @return [Object,nil] value of the field
  #   or +nil+ if field is not defined
  def get(fieldname)
    v = @data[fieldname]
    if v.kind_of?(String)
      t = field_datatype(fieldname)
      if t != :Z and t != :seq
        # value was not parsed or was set to a string by the user
        return (@data[fieldname] = v.parse_gfa_field(t, safe: @validate >= 2))
      else
         v.validate_gfa_field!(t, fieldname) if (@validate >= 5)
      end
    elsif !v.nil?
      if (@validate >= 5)
        t = field_datatype(fieldname)
        v.validate_gfa_field!(t, fieldname)
      end
    else
      dealiased_fieldname = self.class::FIELD_ALIAS[fieldname]
      return get(dealiased_fieldname) if !dealiased_fieldname.nil?
    end
    return v
  end

  # Value of a field, raising an exception if it is not defined
  # @param fieldname [Symbol] name of the field
  # @raise [RGFA::NotFoundError] if field is not defined
  # @return [Object,nil] value of the field
  def get!(fieldname)
    v = get(fieldname)
    raise RGFA::NotFoundError,
      "No value defined for tag #{fieldname}" if v.nil?
    return v
  end

  # Methods are dynamically created for non-existing but valid tag names.
  # Methods for predefined tags and positional fields
  # are created dynamically for each subclass; methods for existing tags
  # are created on instance initialization.
  #
  # ---
  #  - (Object) <fieldname>(parse=true)
  # The parsed content of a field. See also #get.
  #
  # <b>Parameters:</b>
  #
  # <b>Returns:</b>
  # - (String, Hash, Array, Integer, Float) the parsed content of the field
  # - (nil) if the field does not exist, but is a valid tag field name
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
  # - (RGFA::NotFoundError) if the field does not exist
  #
  # ---
  #
  #  - (self) <fieldname>=(value)
  # Sets the value of a positional field or tag,
  # or creates a new tag if the fieldname is
  # non-existing but a valid tag name. See also #set, #set_datatype.
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
      raise RGFA::ArgumentError, "Wrong number of arguments"
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
        raise RGFA::NotFoundError,
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
  #   contains the same tags
  #   and all positional fields and tags contain the same field values?
  # @see RGFA::Line::Link#==
  def ==(o)
    return self.to_sym == o.to_sym if o.kind_of?(Symbol)
    return false if (o.record_type != self.record_type)
    return false if o.data.keys.sort != data.keys.sort
    o.data.each do |k, v|
      if @data[k] != o.data[k]
        if field_to_s(k) != o.field_to_s(k)
          return false
        end
      end
    end
    return true
  end

  # Validate the RGFA::Line instance
  # @raise [RGFA::FormatError] if any field content is not valid
  # @return [void]
  def validate!
    fieldnames.each {|fieldname| validate_field!(fieldname) }
    validate_record_type_specific_info!
  end

  protected

  def data
    @data
  end

  def datatype
    @datatype
  end

  private

  def n_positional_fields
    self.class::POSFIELDS[@version].size
  end

  def field_datatype(fieldname)
    @datatype.fetch(fieldname, self.class::DATATYPE[fieldname])
  end

  def field_or_default_datatype(fieldname, value)
    t = field_datatype(fieldname)
    if t.nil?
      t = value.default_gfa_tag_datatype
      @datatype[fieldname] = t
    end
    return t
  end

  def init_field_value(n ,t, s)
    if @validate >= 3
      s = s.parse_gfa_field(t, safe: true)
    elsif !DELAYED_PARSING_DATATYPES.include?(t)
      s = s.parse_gfa_field(t, safe: false)
    end
    @data[n] = s
  end

  def set_existing_field(fieldname, value)
    if value.nil?
      @data.delete(fieldname)
    else
      if @validate >= 5
        field_or_default_datatype(fieldname, value)
        value.validate_gfa_field!(field_datatype(fieldname), fieldname)
      end
      @data[fieldname] = value
    end
  end

  def initialize_positional_fields(strings)
    if @version.nil?
      raise RGFA::VersionError, "Version unknown"
      # this should never happen
    end
    if (@validate >= 1) and (strings.size < n_positional_fields)
      raise RGFA::FormatError,
        "#{n_positional_fields} positional fields expected, "+
        "#{strings.size}) found\n#{strings.inspect}"
    end
    n_positional_fields.times do |i|
      n = self.class::POSFIELDS[@version][i]
      init_field_value(n, self.class::DATATYPE[n], strings[i])
    end
  end

  def valid_custom_tagname?(fieldname)
    /^[a-z][a-z0-9]$/ =~ fieldname
  end

  def validate_custom_tagname!(fieldname)
    if not valid_custom_tagname?(fieldname)
      raise RGFA::FormatError,
        "#{fieldname} is not a valid custom tag name"
    end
  end

  def predefined_tag?(fieldname)
    self.class::PREDEFINED_TAGS.include?(fieldname)
  end

  def initialize_tags(strings)
    n_positional_fields.upto(strings.size-1) do |i|
      initialize_tag(*strings[i].parse_gfa_tag)
    end
  end

  def initialize_tag(n, t, s)
    if (@validate > 0)
      if @data.has_key?(n)
        raise RGFA::NotUniqueError,
          "Tag #{n} found multiple times"
      elsif predefined_tag?(n)
        unless t == self.class::DATATYPE[n]
          raise RGFA::TypeError,
            "Tag #{n} must be of type "+
            "#{self.class::DATATYPE[n]}, #{t} found"
        end
      elsif not valid_custom_tagname?(n)
        raise RGFA::FormatError,
          "Custom tags must be lower case; found: #{n}"
      else
        @datatype[n] = t
      end
    else
      (@datatype[n] = t) if !field_datatype(t)
    end
    init_field_value(n, t, s)
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
      elsif self.class::PREDEFINED_TAGS.include?(m) or
          valid_custom_tagname?(m)
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
    (self::POSFIELDS.values.flatten.compact.uniq +
     self::PREDEFINED_TAGS).each do |fieldname|
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
    self::FIELD_ALIAS.each do |k,v|
      alias_method :"#{k}",  :"#{v}"
      alias_method :"#{k}!", :"#{v}!"
      alias_method :"#{k}=", :"#{v}="
    end
  end
  private_class_method :define_field_methods!

  def validate_version!
    rt = self.class::RECORD_TYPE
    if !RGFA::VERSIONS.include?(@version)
        raise RGFA::VersionError,
            "GFA specification version unknown (#{version})"
    else
      RECORD_TYPE_VERSIONS[:specific].each do |k, v|
        if v.include?(rt)
          if version != k
            raise RGFA::VersionError,
              "Records of type #{record_type} are incompatible "+
              "with version #{@version}"
          end
          return
        end
      end
    end
  end

end

#
# Require the child classes
#
require_relative "line/header.rb"
require_relative "line/segment.rb"
require_relative "line/path.rb"
require_relative "line/link.rb"
require_relative "line/containment.rb"
require_relative "line/comment.rb"
require_relative "line/custom_record.rb"
require_relative "line/gap.rb"
require_relative "line/fragment.rb"
require_relative "line/edge.rb"
require_relative "line/ordered_group.rb"
require_relative "line/unordered_group.rb"

# Extensions to the String core class.
#
class String

  # Parses a line of a RGFA file and creates an object of the correct
  #   record type child class of {RGFA::Line}
  # @return [subclass of RGFA::Line]
  # @raise [RGFA::Error] if the fields do not comply to the RGFA specification
  # @param validate [Integer] <i>(defaults to: 2)</i>
  #   see RGFA::Line#initialize
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  def to_rgfa_line(validate: 2, version: nil)
    if self[0] == "#"
      return RGFA::Line::Comment.new([self[1..-1]], validate: 0,
                                     version: version)
    else
      split(RGFA::Line::SEPARATOR).to_rgfa_line(validate: validate,
                                                version: version)
    end
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
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  def to_rgfa_line(validate: 2, version: nil)
    sk = RGFA::Line.subclass(self[0], version: version)
    if sk == RGFA::Line::CustomRecord
      sk.new(self, validate: validate, version: version)
    else
      sk.new(self[1..-1], validate: validate, version: version)
    end
  end

end
