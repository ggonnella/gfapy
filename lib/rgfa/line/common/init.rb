#
# Initialization of line instances.
# @tested_in unit_line
#
module RGFA::Line::Common::Init

  # List of allowed record_type values
  RECORD_TYPES = [ :H, :S, :L, :C, :P, :"#", :G, :F, :E, :O, :U, nil ]

  # List of data types which are parsed only on access;
  # all other are parsed when read.
  DELAYED_PARSING_DATATYPES = [
                                :alignment_gfa1,
                                :alignment_gfa2,
                                :alignment_list_gfa1,
                                :oriented_segments,
                                :H,
                                :J,
                                :B,
                              ]

  # Dependency of record type from version
  # - specific => only for a specific version
  # - generic => same syntax for all versions
  # - different => different syntax in different versions
  RECORD_TYPE_VERSIONS =
  {
    :specific =>
      {:gfa1 => [:C, :L, :P],
       :gfa2 => [:E, :G, :F, :O, :U, nil]},
    :generic => [:H, :"#"],
    :different => [:S]
  }

  # @param data [Array<String>] the content of the line; if
  #   an array of strings, this is interpreted as the splitted content
  #   of a GFA file line; note: an hash
  #   is also allowed, but this is for internal usage and shall be considered
  #   private
  # @param vlevel [Integer] see paragraph Validation
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
  # - POSFIELDS [Array<Symbol>] positional fields
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
  # responsible to call #validate_field, if necessary.
  #
  # - 0: no validation
  # - 1: basic validations (number of positional fields,
  #      duplicated tags, tag types); some field contents are validated
  # - 2: basic validations; initialization or first-access validation
  #      of all fields
  # - 3: as 2, plus record-type specific cross-field validations
  #      (e.g. compare GFA1 segment LN tag and sequence lenght)
  # - 4: as 3, plus field validation on writing to string
  # - 5: complete validation;
  #      as 4, plus field validation on all access (get/set)
  #
  def initialize(data, vlevel: 1, virtual: false, version: nil)
    unless self.class.const_defined?(:"RECORD_TYPE")
      raise RGFA::RuntimeError, "This class shall not be directly instantiated"
    end
    @vlevel = vlevel
    @virtual = virtual
    @datatype = {}
    @data = {}
    @rgfa = nil
    @version = version
    if data.kind_of?(Hash)
      @data.merge!(data)
    else
      # normal initialization, data is an array of strings
      if @version.nil?
        process_unknown_version(data)
      else
        validate_version
        initialize_positional_fields(data)
        initialize_tags(data)
      end
      validate_record_type_specific_info if @vlevel >= 1
      if @version.nil?
        raise "RECORD_TYPE_VERSIONS has no value for #{record_type}"
      end
    end
  end

  # @return self
  # @param vlevel [Boolean] ignored (compatibility reasons)
  # @param version [Boolean] ignored (compatibility reasons)
  def to_rgfa_line(vlevel: nil, version: nil)
    self
  end

  private

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
      raise RGFA::RuntimeError,
        "GFA version not specified\n"+
        "Records of type #{rt} have different syntax according to the version"
    end
  end

  def validate_version
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

  def n_positional_fields
    self.class::POSFIELDS.size
  end

  def init_field_value(n ,t, s, errmsginfo: nil)
    if @vlevel >= 1
      s = s.parse_gfa_field(t, safe: true, fieldname: n,
                            line: errmsginfo)
    elsif !DELAYED_PARSING_DATATYPES.include?(t)
      s = s.parse_gfa_field(t, safe: @vlevel >= 1, fieldname: n,
                            line: errmsginfo)
    end
    @data[n] = s
  end

  def initialize_positional_fields(strings)
    if @version.nil?
      raise RGFA::AssertionError,
        "Bug found, please report\n"+
        "strings: #{strings.inspect}"
    end
    if (@vlevel >= 1) and (strings.size < n_positional_fields)
      raise RGFA::FormatError,
        "#{n_positional_fields} positional fields expected, "+
        "#{strings.size}) found\n#{strings.inspect}"
    end
    n_positional_fields.times do |i|
      n = self.class::POSFIELDS[i]
      init_field_value(n, self.class::DATATYPE[n], strings[i],
                       errmsginfo: strings)
    end
  end

  def initialize_tags(strings)
    n_positional_fields.upto(strings.size-1) do |i|
      initialize_tag(*strings[i].parse_gfa_tag, errmsginfo: strings)
    end
  end

  def initialize_tag(n, t, s, errmsginfo: nil)
    if @vlevel > 0
      if @data.has_key?(n)
        raise RGFA::NotUniqueError,
          "Tag #{n} found multiple times"
      elsif predefined_tag?(n)
        validate_predefined_tag_type(n, t)
      else
        validate_custom_tagname(n)
        @datatype[n] = t
      end
    else
      (@datatype[n] = t) if !field_datatype(n)
    end
    init_field_value(n, t, s, errmsginfo: errmsginfo)
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      private_class_method :subclass_GFA1
      private_class_method :subclass_GFA2
      private_class_method :subclass_unknown_version
    end
  end

  module ClassMethods

    # Select a subclass based on the record type
    # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
    # @raise [RGFA::TypeError] if the record_type is not valid
    # @raise [RGFA::VersionError] if the version is unknown
    # @return [Class] a subclass of RGFA::Line
    def subclass(record_type, version: nil)
      case version
      when :gfa1
        subclass_GFA1(record_type)
      when :gfa2
        subclass_GFA2(record_type)
      when nil
        subclass_unknown_version(record_type)
      else
        raise RGFA::VersionError,
            "GFA specification version unknown (#{version})"
      end
    end

    def subclass_GFA1(record_type)
      if record_type.nil?
        raise RGFA::VersionError,
          "RGFA uses virtual records of unknown type for GFA2 only"
      end
      case record_type.to_sym
      when :H then RGFA::Line::Header
      when :S then RGFA::Line::Segment::GFA1
      when :"#" then RGFA::Line::Comment
      when :L then RGFA::Line::Edge::Link
      when :C then RGFA::Line::Edge::Containment
      when :P then RGFA::Line::Group::Path
      else raise RGFA::VersionError,
            "Custom record types are not supported in GFA1: '#{record_type}'"
      end
    end

    def subclass_GFA2(record_type)
      case record_type.to_sym
      when :H then RGFA::Line::Header
      when :S then RGFA::Line::Segment::GFA2
      when :"#" then RGFA::Line::Comment
      when :E then RGFA::Line::Edge::GFA2
      when :F then RGFA::Line::Fragment
      when :G then RGFA::Line::Gap
      when :O then RGFA::Line::Group::Ordered
      when :U then RGFA::Line::Group::Unordered
      else RGFA::Line::CustomRecord
      end
    end

    def subclass_unknown_version(record_type)
      case record_type.to_sym
      when :H then RGFA::Line::Header
      when :S then RGFA::Line::Segment::Factory
      when :"#" then RGFA::Line::Comment
      when :L then RGFA::Line::Edge::Link
      when :C then RGFA::Line::Edge::Containment
      when :P then RGFA::Line::Group::Path
      when :E then RGFA::Line::Edge::GFA2
      when :F then RGFA::Line::Fragment
      when :G then RGFA::Line::Gap
      when :O then RGFA::Line::Group::Ordered
      when :U then RGFA::Line::Group::Unordered
      else RGFA::Line::CustomRecord
      end
    end

  end

end

# Extensions to the String core class.
#
class String

  # Parses a line of a RGFA file and creates an object of the correct
  #   record type child class of {RGFA::Line}
  # @return [subclass of RGFA::Line]
  # @raise [RGFA::Error] if the fields do not comply to the RGFA specification
  # @param vlevel [Integer] <i>(defaults to: 1)</i>
  #   see RGFA::Line#initialize
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  def to_rgfa_line(vlevel: 1, version: nil)
    if self[0] == "#"
      self =~ /^#(\s*)(.*)$/
      return RGFA::Line::Comment.new([$2, $1],
                                     vlevel: vlevel,
                                     version: version)
    else
      split(RGFA::Line::SEPARATOR).to_rgfa_line(vlevel: vlevel,
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
  # @param vlevel [Integer] <i>(defaults to: 1)</i>
  #   see RGFA::Line#initialize
  # @param version [RGFA::VERSIONS, nil] GFA version, nil if unknown
  # @api private
  def to_rgfa_line(vlevel: 1, version: nil)
    sk = RGFA::Line.subclass(self[0], version: version)
    if sk == RGFA::Line::CustomRecord
      sk.new(self, vlevel: vlevel, version: version)
    else
      sk.new(self[1..-1], vlevel: vlevel, version: version)
    end
  end

end
