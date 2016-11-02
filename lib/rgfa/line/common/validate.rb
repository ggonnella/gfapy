module RGFA::Line::Common::Validate

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

  # Validate the RGFA::Line instance
  # @raise [RGFA::FormatError] if any field content is not valid
  # @return [void]
  def validate!
    fieldnames.each {|fieldname| validate_field!(fieldname) }
    validate_record_type_specific_info!
  end

  private

  def valid_custom_tagname?(fieldname)
    /^[a-z][a-z0-9]$/ =~ fieldname
  end

  def validate_record_type_specific_info!
  end

  def predefined_tag?(fieldname)
    self.class::PREDEFINED_TAGS.include?(fieldname)
  end

end
