# Update of references caused by a virtual line becoming real.
#
module RGFA::Line::Common::UpdateReferences

  # This is called on lines which were referenced by virtual lines,
  # when a real line is found which substitutes the virtual line.
  #
  # @note SUBCLASSES which can be referenced by virtual lines
  #   may implement a specialize #backreferences_keys method to
  #   support this mechanism (the default will work in all cases
  #   of the current specification, but is not optimized for record type)
  #
  # @param oldref [RGFA::Line]
  # @param newref [RGFA::Line]
  # @param key_in_ref [Array<Symbol>]
  # @return [void]
  #
  # @api private
  def update_references(oldref, newref, key_in_ref)
    keys = backreference_keys(oldref, key_in_ref)
    update_field_references(oldref, newref, self.class::REFERENCE_FIELDS & keys)
    if instance_variable_defined?(:@refs)
      # note: keeping the two types of nonfield references separate helps
      #       in subclasses where only one must be redefined
      update_dependent_line_references(oldref, newref,
                                self.class::DEPENDENT_LINES & @refs.keys & keys)
      update_other_references(oldref, newref,
                               self.class::OTHER_REFERENCES & @refs.keys & keys)
    end
  end

  private

  # Return a list of fields and/or @ref keys, which indicates
  # where a reference "ref" _may_ be stored (in order to be able
  # to locate it and update it).
  #
  # The default is: all reference fields, dependent line references
  # and other references.
  #
  # @note SUBCLASSES may overwrite this method if they
  #   can be referenced by virtual lines, by providing more
  #   specific results, depending on the ref and key_in_ref;
  #   this can make the update faster
  # @return [Array<Symbol>] fieldnames and/or @refs keys
  def backreference_keys(ref, key_in_ref)
    self.class::REFERENCE_FIELDS +
      self.class::DEPENDENT_LINES +
        self.class::OTHER_REFERENCES
  end

  # @note this methods supports fields which contain references,
  #   oriented lines or array of references or oriented lines;
  #   if SUBCLASSES contain fields which reference to line in a
  #   different fashion, the method must be updated or overwritten
  #   by the subclass
  def update_reference_in_field(field, oldref, newref)
    value = get(field)
    case value
    when RGFA::Line
      if value.equal?(oldref)
        set_existing_field(field, newref, set_reference: true)
      end
    when RGFA::OrientedLine
      if value.line.equal?(oldref)
        value.line = newref
      end
    when Array
      update_reference_in_array(value, oldref, newref)
    end
  end

  def update_reference_in_array(array, oldref, newref)
    array.map! do |elem|
      case elem
      when RGFA::Line
        elem = newref if elem.equal?(oldref)
      when RGFA::OrientedLine
        if elem.line.equal?(oldref)
          if oldref.respond_to?(:complement?)
            elem.orient = elem.orient.invert if oldref.complement?(newref)
          end
          elem.line = newref
        end
      end
      elem
    end.compact!
  end

  def update_field_references(oldref, newref, possible_fieldnames)
    possible_fieldnames.each do |fn|
      update_reference_in_field(fn, oldref, newref ? newref : oldref.to_sym)
    end
  end

  def update_nonfield_references(oldref, newref, possible_keys)
    possible_keys.each do |key|
      array = @refs[key]
      update_reference_in_array(array, oldref, newref) if !array.nil?
    end
  end

  def update_dependent_line_references(oldref, newref, possible_keys)
    update_nonfield_references(oldref, newref, possible_keys)
  end

  # @note SUBCLASSES may redefine this method
  def update_other_references(oldref, newref, possible_keys)
    update_nonfield_references(oldref, newref, possible_keys)
  end

end
