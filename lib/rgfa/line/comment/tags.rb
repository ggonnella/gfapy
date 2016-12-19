# Comment lines do not support tags.
# @tested_in api_comments
module RGFA::Line::Comment::Tags

  # Set the value of the comment or sp field
  #
  # @param fieldname [:comment, :sp] the name of the field to set
  # @raise [RGFA::RuntimeError] if +fieldname+ is not one of the above
  # @return [Object] +value+
  def set(fieldname, value)
    if [:comment, :sp].include?(fieldname.to_sym)
      super
    else
      raise RGFA::RuntimeError,
        "Tags of comment lines cannot be set"
    end
  end

  private

  def method_missing(m, *args, &block)
    raise NoMethodError,
      "undefined method `#{m}' for #{self.inspect}"
  end

end
