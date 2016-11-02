module RGFA::Line::Common::Cloning

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

end
