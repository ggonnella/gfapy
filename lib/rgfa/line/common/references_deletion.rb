module RGFA::Line::Common::ReferencesDeletion

  # Remove the line from the RGFA instance it belongs to, if any.
  #
  # The Line instance itself will still exist, but all references from it to
  # other lines are deleted, as well as references to it from other lines.
  # Mandatory references are turned into their non-reference representations
  # (e.g. segments references in the sid fields of E lines
  # or in the from/to lines of L/C lines are changed into symbols).
  #
  # @return [void]
  def disconnect!
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
    refs[key] -= [line]
    @refs[key].freeze
  end

  private

  # @note SUBCLASSES with reference fields may
  #   overwrite this method to discconnect their reference
  #   fields, if they are not directly a reference
  #   but contain a reference (e.g path segment_names)
  def remove_field_references
    self.class::REFERENCE_FIELDS.each do |k|
      ref = get(k)
      if ref.kind_of?(RGFA::Line)
        set_existing_field(k, ref.to_sym, set_reference: true)
      end
    end
  end

  # @note SUBCLASSES with reference fields may
  #   overwrite this method to discconnect their reference
  #   fields, if they are not directly a reference
  #   but contain a reference (e.g path segment_names)
  def remove_field_backreferences
    self.class::REFERENCE_FIELDS.each do |k|
      ref = get(k)
      if ref.kind_of?(RGFA::Line)
        ref.update_references(self, nil, k)
      end
    end
  end

  def disconnect_dependent_lines
    self.class::DEPENDENT_REFERENCES.each do |k|
      refs.fetch(k, []).each {|l| l.disconnect!}
    end
  end

  def remove_nonfield_backreferences
    self.class::NONDEPENDENT_REFERENCES.each do |k|
      refs.fetch(k, []).each do |l|
        l.update_references(self, nil, k)
      end
    end
  end

  def remove_nonfield_references
    @refs ||= {}
  end

end
