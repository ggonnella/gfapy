module RGFA::Line::Comment::Tags

  def method_missing(m, *args, &block)
    raise NoMethodError,
      "undefined method `#{m}' for #{self.inspect}"
  end

  def set(fieldname, value)
    if [:comment, :sp].include?(fieldname.to_sym)
      super
    else
      raise RGFA::RuntimeError,
        "Tags of comment lines cannot be set"
    end
  end

end
