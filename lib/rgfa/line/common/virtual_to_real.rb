# Methods in this module are important for lines
# which can be virtual
#
module RGFA::Line::Common::VirtualToReal

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
    import_references(previous)
    @rgfa.unregister_line(previous)
    @rgfa.register_line(self)
    return nil
  end

  # This is called when a virtual line (previous) is
  # substituted by a real line
  def import_references(previous)
    if !previous.kind_of?(RGFA::Line::Unknown)
      import_field_references(previous)
      update_field_backreferences(previous)
    else
      initialize_references
    end
    import_nonfield_references(previous)
    update_nonfield_backreferences(previous)
  end

  def import_field_references(previous)
    (self.class::REFERENCE_FIELDS +
     self.class::REFERENCE_RELATED_FIELDS).each do |k|
      ref = previous.get(k)
      set_existing_field(k, ref, set_reference: true)
    end
  end

  def update_backreference_in(ref, previous, k)
    case ref
    when RGFA::Line
      ref.update_references(previous, self, k)
    when RGFA::OrientedLine
      ref.line.update_references(previous, self, k)
    when Array
      ref.each do |item|
        update_backreference_in(item, previous, k)
      end
    end
  end

  # @note currently this method supports fields which are: references,
  #   oriented lines and arrays of references of oriented lines;
  #   if SUBCLASSES have reference fields which contain references
  #   in a different fashion, the method must be updated or overwritten
  #   in the subclass
  def update_field_backreferences(previous)
    self.class::REFERENCE_FIELDS.each do |k|
      ref = get(k)
      update_backreference_in(ref, previous, k)
    end
  end

  def import_nonfield_references(previous)
    @refs = previous.refs
  end

  def update_nonfield_backreferences(previous)
    @refs.each do |k, v|
      v.each do |ref|
        update_backreference_in(ref, previous, k)
      end
    end
  end

end
