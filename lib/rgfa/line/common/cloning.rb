module RGFA::Line::Common::Cloning

  # Copy of a RGFA::Line instance.
  # The copy will be disconnected, ie do not belong to the RGFA and do not
  # contain cross-references to other lines. This allows to edit the line
  # (eg. changing the unique ID) before adding it.
  # To achieve this, all reference fields are copied in their string
  # representation.
  # All other fields are copied as they are, and a deep copy is done for
  # arrays, strings and JSON fields.
  # @return [RGFA::Line]
  def clone
    data_cpy = {}
    @data.each_pair do |k, v|
      if self.class::REFERENCE_FIELDS.include?(k)
        data_cpy[k] = field_to_s(k).clone
      elsif field_datatype(k) == :J
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
    # @refs and @rgfa are not set, so that the cpy is disconnected
    return cpy
  end

end
