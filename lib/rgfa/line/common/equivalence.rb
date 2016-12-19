# @tested_in unit_line_diff
module RGFA::Line::Common::Equivalence

  # Equivalence check
  # @param other [RGFA::Line, Symbol]
  # @return [Boolean] if other is a symbol, is it the same as
  #   the result of applying to_sym to the line?; if other is a line,
  #   does it have the same record type, positional fields and tags (value
  #   and datatype) as the line?
  # @see RGFA::Line::Edge::Link#==
  def ==(other)
    return self.to_sym == other.to_sym if other.kind_of?(Symbol)
    return false if (other.record_type != self.record_type)
    return false if other.data.keys.sort != data.keys.sort
    other.data.each do |k, v|
      if @data[k] != other.data[k]
        if field_to_s(k) != other.field_to_s(k)
          return false
        end
      end
    end
    return true
  end

  # Returns always false, as a line is not a placeholder (for compatibility
  # with other objects which can be representable as placeholders, such as
  # symbols, strings, arrays).
  # @return [false]
  def placeholder?
    false
  end

  # Computes the differences between the line and another line.
  # @return [Array<Array<Symbol, String>>] information about the differences;
  #   an empty array if no difference found
  def diff(other)
    if self.record_type != other.record_type
      return [:incompatible, :record_type, self.record_type, other.record_type]
    end
    if self.class != other.class
      raise RGFA::AssertionError if self.version == other.version
      return [:incompatible, :version, self.version, other.version]
    end
    differences = []
    positional_fieldnames.each do |fieldname|
      value1 = field_to_s(fieldname)
      value2 = other.field_to_s(fieldname)
      if value1 != value2
        differences << [:different, :positional_field,
                        fieldname, value1, value2]
      end
    end
    (self.tagnames - other.tagnames).each do |tagname|
      differences << [:exclusive, :<, :tag,
                      tagname, get_datatype(tagname), get(tagname)]
    end
    (other.tagnames - self.tagnames).each do |tagname|
      differences << [:exclusive, :>, :tag,
                      tagname, other.get_datatype(tagname), other.get(tagname)]
    end
    (self.tagnames & other.tagnames).each do |tagname|
      tag1 = field_to_s(tagname, tag: true)
      tag2 = other.field_to_s(tagname, tag: true)
      if tag1 != tag2
        differences << [:different, :tag, tagname,
                        get_datatype(tagname), field_to_s(tagname),
                        other.get_datatype(tagname), other.field_to_s(tagname)]
      end
    end
    return differences
  end

  # Computes a RGFA Ruby script for converting line into other
  # @return [String]
  def diffscript(other, selfvar)
    diffinfo = diff(other)
    outscript = []
    diffinfo.each do |diffitem|
      if diffitem[0] == :incompatible
        if diffitem[1] == :record_type
          raise RGFA::RuntimeError,
            "Cannot compute conversion script: different record type\n"+
            "Line: #{self}\n"+
            "Other: #{other}\n"+
            "#{diffitem[2]} != #{diffitem[3]}"
        elsif diffitem[1] == :version
          raise RGFA::RuntimeError,
            "Cannot compute conversion script: different GFA version\n"+
            "Line: #{self}\n"+
            "Other: #{other}\n"+
            "#{diffitem[2]} != #{diffitem[3]}"
        end
      elsif diffitem[0] == :different
        if diffitem[1] == :positional_field
          outscript <<
            "#{selfvar}.set(:#{diffitem[2]},'#{diffitem[4].gsub("'","\'")}')"
        elsif diffitem[1] == :tag
          if diffitem[3] != diffitem[5]
            outscript <<
              "#{selfvar}.set_datatype(:#{diffitem[2]},:#{diffitem[5]})"
          end
          if diffitem[4] != diffitem[6]
            outscript <<
              "#{selfvar}.set(:#{diffitem[2]},'#{diffitem[6].gsub("'","\'")}')"
          end
        end
      elsif diffitem[0] == :exclusive
        if diffitem[1] == :>
          if diffitem[2] == :tag
            outscript <<
              "#{selfvar}.set_datatype(:#{diffitem[3]},:#{diffitem[4]})"
            outscript <<
              "#{selfvar}.set(:#{diffitem[3]},'#{diffitem[5].gsub("'","\'")}')"
          end
        elsif diffitem[1] == :<
          if diffitem[2] == :tag
            outscript <<
              "#{selfvar}.delete(:#{diffitem[3]})"
          end
        end
      end
    end
    return outscript.join("\n")
  end

end
