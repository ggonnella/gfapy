module RGFA::Line::Common::Disconnection

  # Remove the line from the RGFA instance it belongs to, if any.
  #
  # The Line instance itself will still exist, but all references from it to
  # other lines are deleted, as well as references to it from other lines.
  # Mandatory references are turned into their non-reference representations
  # (e.g. segments references in the sid fields of E lines
  # or in the from/to lines of L/C lines are changed into symbols).
  #
  # @return [void]
  def disconnect
    if !connected?
      raise RGFA::RuntimeError,
        "Line #{self} is not connected to a RGFA instance"
    end
    remove_field_backreferences
    remove_field_references
    disconnect_dependent_lines
    remove_nonfield_backreferences
    remove_nonfield_references
    @rgfa.unregister_line(self)
    @rgfa = nil
  end

  # @api private
  def delete_reference(line, key)
    return if !@refs or !@refs[key]
    idx = @refs[key].index {|x| x.equal?(line)}
    return if idx.nil?
    @refs = ((idx == 0 ? [] : @refs[0..idx-1]) + @refs[idx+1..-1])
  end

  # @api private
  def delete_first_reference(key)
    return if !@refs or !@refs[key]
    @refs[key].shift
  end

  # @api private
  def delete_last_reference(key)
    return if !@refs or !@refs[key]
    @refs[key].pop
  end

  private

  # @note currently this method supports fields which are: references,
  #   oriented lines and arrays of references of oriented lines;
  #   if SUBCLASSES have reference fields which contain references
  #   in a different fashion, the method must be updated or overwritten
  #   in the subclass
  def remove_field_references
    self.class::REFERENCE_FIELDS.each do |k|
      ref = get(k)
      case ref
      when RGFA::Line
        set_existing_field(k, ref.to_sym, set_reference: true)
      when RGFA::OrientedLine
        ref.line = ref.name
      when Array
        ref.map! do |elem|
          if elem.kind_of?(RGFA::Line)
            elem = elem.to_sym
          elsif elem.kind_of?(RGFA::OrientedLine)
            elem.line = elem.name
          end
          elem
        end
      end
    end
  end

  #def each_reference_in(field, &block)
  #  case field
  #  when RGFA::Line
  #    yield field
  #  when RGFA::OrientedLine
  #    yield field.line
  #  when Array
  #    field.each {|elem| each_reference_in(elem, &block)}
  #  end
  #end

  def remove_backreference(ref, k)
    case ref
    when RGFA::Line
      ref.update_references(self, nil, k)
    when RGFA::OrientedLine
      ref.line.update_references(self, nil, k)
    when Array
      ref.each {|elem| remove_backreference(elem, k)}
    end
  end

  def disconnect_dependent_line(ref)
    case ref
    when RGFA::Line
      ref.disconnect
    when RGFA::OrientedLine
      ref.line.disconnect
    when Array
      ref.each {|elem| disconnect_dependent_line(elem)}
    end
  end

  # @note currently this method supports fields which are: references,
  #   oriented lines and arrays of references of oriented lines;
  #   if SUBCLASSES have reference fields which contain references
  #   in a different fashion, the method must be updated or overwritten
  #   in the subclass
  def remove_field_backreferences
    self.class::REFERENCE_FIELDS.each do |k|
      remove_backreference(get(k), k)
    end
  end

  def disconnect_dependent_lines
    self.class::DEPENDENT_LINES.each do |k|
      refs.fetch(k, []).each do |ref|
        disconnect_dependent_line(ref)
      end
    end
  end

  def remove_nonfield_backreferences
    self.class::OTHER_REFERENCES.each do |k|
      refs.fetch(k, []).each do |ref|
        remove_backreference(ref, k)
      end
    end
  end

  def remove_nonfield_references
    @refs = {}
  end

end
