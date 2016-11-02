module RGFA::Line::Common::FieldData

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
    self.class::POSFIELDS
  end

  # @return [Array<Symbol>] name of the defined tags
  def tagnames
    (@data.keys - positional_fieldnames)
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

  private

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

end
