#
# Support for headers defined in multiple lines of the GFA file. The lines may
# also contain the same tag defined multiple times in different lines, with
# multiple values.
#
module RGFA::Line::Header::Multiline

  # Tags which are allowed to be defined with a single value in the header
  # (if multiple header line contain them, they must contain the same value)
  SINGLE_DEFINITION_TAGS = [:VN, :TS]

  # Set a header tag value.
  #
  # If the tag +tagname+ does not exist yet, it is set to +value+.  If it exists
  # and is defined a single time (i.e. it is not a field array): if the tagname
  # is in the {SINGLE_DEFINITION_TAGS} list, if value is the same as before, it
  # is ignored, if different, an error is raised; for other tags: a field array
  # is created, containing the previous value and +value+. If the previous value
  # it is a field array (i.e. the tag was already defined multiple times),
  # +value+ is added to it.
  #
  # @param tagname [Symbol] a valid GFA custom or predefined tag name
  # @param value [Object] the value to which the tag shall be set; if the tag
  #   was already defined (or if a datatype parameter is specified),
  #   the value must be compatible with the datatype
  # @param datatype [RGFA::Field::TAG_DATATYPE, nil] the GFA tag datatype to
  #   use; if none is specified, it is determined by the previous values for
  #   the field (if any) or by the class of value (otherwise)
  #
  # @raise [RGFA::FormatError] if the tagname is invalid
  # @raise [RGFA::TypeError, RGFA::FormatError]
  #    if the value is not compatible with the specified datatype
  # @raise [RGFA::InconsistencyError]
  #    if the value is not compatible with the datatype of the previously
  #    defined value; or a tag in the {SINGLE_DEFINITION_TAGS} list is defined
  #    multiple times with different values.
  #
  # @return [self]
  def add(tagname, value, datatype=nil)
    tagname = tagname.to_sym
    prev = get(tagname)
    if prev.nil?
      set_datatype(tagname, datatype) if datatype
      set(tagname, value)
      return self
    elsif !prev.kind_of?(RGFA::FieldArray)
      if SINGLE_DEFINITION_TAGS.include?(tagname)
        if field_to_s(tagname) == value.to_gfa_field(fieldname: tagname)
          return self
        else
          raise RGFA::InconsistencyError,
            "Inconsistent values for header tag #{tagname} found\n"+
            "Previous definition: #{prev}\n"+
            "Current definition: #{value}"
        end
      end
      prev = RGFA::FieldArray.new(get_datatype(tagname), [prev])
      set_existing_field(tagname, prev)
    end
    if @vlevel > 1
      prev.vpush(value, datatype, tagname)
    else
      prev << value
    end
    return self
  end

  # Compute the string representation of a header field.
  #
  # @param fieldname [Symbol] the tag name of the field
  # @param tag [Boolean] <i>(defaults to: +false+)</i>
  #   return the tagname:datatype:value representation
  #
  # @raise [RGFA::NotFoundError] if field is not defined
  #
  # @return [String] the string representation
  def field_to_s(fieldname, tag: false)
    prev = get(fieldname)
    if prev.kind_of?(RGFA::FieldArray)
      prev.validate_gfa_field(nil, fieldname) if @vlevel >= 2
      return tag ? prev.to_gfa_tag(fieldname)
                 : prev.to_gfa_field(fieldname: fieldname)
    else
      super
    end
  end

  # @api private
  module API_PRIVATE

    # Count the tags which are represented by FieldArray (i.e. with multiple
    # definitions).
    #
    # @return [Integer (>= 0)]
    def n_duptags
      n = 0
      tagnames.each do |tn|
        n += 1 if get(tn).kind_of?(RGFA::FieldArray)
      end
      return n
    end

    # Split the header line into single-tag lines.
    #
    # If a tag is a FieldArray, this is splitted into multiple fields with the
    # same fieldname (note that it leads to an invalid GFA, if all instances
    # are output in the same GFA line).
    #
    # @return [Array<RGFA::Line::Header>]
    def split
      tags.map do |tagname, datatype, value|
        h = RGFA::Line::Header.new([], vlevel: @vlevel)
        h.set_datatype(tagname, datatype)
        h.set(tagname, value)
        h
      end
    end

    # Merge an additional {RGFA::Line::Header} line into this header line.
    #
    # @param gfa_line [RGFA::Line::Header] the header line to merge
    #
    # @return [self]
    def merge(gfa_line)
      gfa_line.tagnames.each do |of|
        add(of, gfa_line.get(of), gfa_line.get_datatype(of))
      end
      self
    end

  end
  include API_PRIVATE

  private

  # Array of tags data.
  #
  # Returns the tags as an array of [fieldname, datatype, value] arrays. If a
  # field is a FieldArray, this is splitted into multiple fields with the same
  # fieldname.
  #
  # @return [Array<(Symbol, Symbol, Object)>]
  def tags
    retval = []
    tagnames.each do |of|
      value = get(of)
      if value.kind_of?(RGFA::FieldArray)
        value.each do |elem|
          retval << [of, value.datatype, elem]
        end
      else
        retval << [of, get_datatype(of), value]
      end
    end
    return retval
  end

end
