# Methods in this module are important for lines
# which can be virtual
#
module RGFA::Line::Common::ReferencesImport

  # Is the line virtual?
  #
  # Is this RGFA::Line a virtual line representation
  # (i.e. a placeholder for an expected but not encountered yet line)?
  #
  # @return [Boolean]
  #
  # @api private
  def virtual?
    @virtual
  end

  private

  def substitute_virtual_line(previous)
    @rgfa = previous.rgfa
    @rgfa.unregister_line(previous)
    @rgfa.register_line(self)
    import_references(previous)
    return nil
  end

  # This is called when a virtual line (previous) is
  # substituted by a real line
  def import_references(previous)
    if previous.kind_of?(RGFA::Line::Unknown)
      import_field_references(previous)
      update_field_backreferences(previous)
    else
      initialize_references
    end
    import_nonfield_references(previous)
    update_nonfield_backreferences(previous)
  end

  # @note SUBCLASSES shall overwrite this method, if they can be virtual and
  #   the reference fields are not directly references
  #   but rather contain the reference (e.g. path segment_names)
  def import_field_references(previous)
    self.class::REFERENCE_FIELDS.each do |k|
      ref = previous.get(k)
      set_existing_field(k, ref, set_reference: true)
    end
  end

  # @note SUBCLASSES shall overwrite this method, if they can be virtual and
  #   the reference fields are not directly references
  #   but rather contain the reference (e.g. path segment_names)
  def update_field_backreferences(previous)
    self.class::REFERENCE_FIELDS.each do |k|
      ref = get(k)
      if ref.kind_of?(RGFA::Line)
        ref.update_references(previous, self, k)
      end
    end
  end

  def import_nonfield_references(previous)
    @refs = previous.refs
  end

  def update_nonfield_backreferences(previous)
    @refs.each do |k, v|
      v.each {|l| l.update_references(previous, self, k)}
    end
  end

end
