#
# Methods for the validation of single fields and of the entire line
#
# @tested_in api_positionals, api_tags
#
module RGFA::Line::Common::Validate

  # Raises an error if the content of the field does not correspond to
  # the field type
  #
  # @param fieldname [Symbol] the tag name of the field to validate
  # @raise [RGFA::FormatError] if the content of the field is
  #   not valid, according to its required type
  # @return [void]
  def validate_field(fieldname)
    fieldname = self.class::FIELD_ALIAS.fetch(fieldname, fieldname)
    v = @data[fieldname]
    t = field_or_default_datatype(fieldname, v)
    v.validate_gfa_field(t, fieldname)
    return nil
  end

  # Validate the RGFA::Line instance
  # @raise [RGFA::FormatError] if any field content is not valid
  # @return [void]
  def validate
    fieldnames = positional_fieldnames + tagnames
    validate_tagnames_and_types if @vlevel == 0 # otherwise validated at init
    fieldnames.each {|fieldname| validate_field(fieldname) }
    validate_record_type_specific_info
  end

  private

  def validate_tagnames_and_types
    tagnames.each do |n|
      if predefined_tag?(n)
        validate_predefined_tag_type(n, field_datatype(n))
      elsif not valid_custom_tagname?(n)
        raise RGFA::FormatError,
          "Custom tags must be lower case; found: #{n}"
      end
    end
  end

  def validate_predefined_tag_type(tagname, datatype)
    unless datatype == self.class::DATATYPE[tagname]
      raise RGFA::TypeError,
        "Tag #{tagname} must be of type "+
        "#{self.class::DATATYPE[tagname]}, #{datatype} found"
    end
  end

  def validate_custom_tagname(tagname)
    if not valid_custom_tagname?(tagname)
      raise RGFA::FormatError,
        "Custom tags must be lower case; found: #{tagname}"
    end
  end

  def valid_custom_tagname?(tagname)
    /^[a-z][a-z0-9]$/ =~ tagname
  end

  def validate_record_type_specific_info
  end

  def predefined_tag?(tagname)
    self.class::PREDEFINED_TAGS.include?(tagname)
  end

end
