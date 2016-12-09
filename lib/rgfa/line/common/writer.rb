module RGFA::Line::Common::Writer

  # @return [String] a string representation of self
  def to_s
    to_a.join(RGFA::Line::SEPARATOR)
  end

  # @return [Array<String>] an array of string representations of the fields
  # @api private
  def to_a
    a = [record_type.to_s]
    positional_fieldnames.each {|fn| a << field_to_s(fn, tag: false)}
    tagnames.each {|fn| a << field_to_s(fn, tag: true)}
    if virtual?
      a << "co:Z:RGFA_virtual_line"
    end
    return a
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
    field.validate_gfa_field(t, fieldname) if @validate >= 4
    return tag ? field.to_gfa_tag(fieldname, datatype: t) : field
  end

  def inspect
    if instance_variable_defined?(:@refs) and !@refs.nil?
      local_refs = @refs
      @refs = {}
      local_refs.each do |k, v|
        @refs[k] ||= []
        v.each {|l| @refs[k] << l.to_s.gsub("\t"," ")}
      end
    end
    if !@rgfa.nil?
      local_rgfa = @rgfa
      @rgfa = "<RGFA:#{local_rgfa.object_id}>"
    end
    retval = super
    @refs = local_refs if local_refs
    @rgfa = local_rgfa if local_rgfa
    retval
  end

  private

  # Returns the tags as an array of [fieldname, datatype, value]
  #   triples.
  # @api private
  # @return [Array<[Symbol, Symbol, Object]>]
  def tags
    retval = []
    tagnames.each do |of|
      retval << [of, get_datatype(of), get(of)]
    end
    return retval
  end

end
