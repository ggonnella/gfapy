module RGFA::Line::Common::FieldDatatype

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
  # invalid (call #validate_field if necessary).
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
    elsif !valid_custom_tagname?(fieldname) and @validate > 0
      raise RGFA::FormatError,
        "#{fieldname} is not a valid custom tag name"
    end
    unless RGFA::Field::TAG_DATATYPE.include?(datatype)
      raise RGFA::ArgumentError, "Unknown datatype: #{datatype}"
    end
    @datatype[fieldname] = datatype
  end

  private

  def field_datatype(fieldname)
    @datatype.fetch(fieldname, self.class::DATATYPE[fieldname])
  end

  def field_or_default_datatype(fieldname, value)
    t = field_datatype(fieldname)
    if t.nil?
      return nil if value.nil?
      t = value.default_gfa_tag_datatype
      @datatype[fieldname] = t
    end
    return t
  end

end
