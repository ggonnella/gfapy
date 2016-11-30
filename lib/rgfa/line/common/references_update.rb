# Methods in this module are important for lines
# which can be references by virtual lines
#
module RGFA::Line::Common::ReferencesUpdate

  # This is called on lines which were referenced by virtual lines,
  # when a real line is found which substitutes the virtual line.
  #
  # @note SUBCLASSES which can be referenced by virtual lines
  #   must implement the #backreferences_keys method to
  #   support this mechanism
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
      update_nonfield_references(oldref, newref, @refs.keys & keys)
    end
  end

  # @api private
  # this could be useful for E if they change nature
  def move_reference(ref, oldkey, newkey)
    raise "Not implemented yet"
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
      if value == oldref
        set_existing_field(field, newref, set_reference: true)
      end
    when RGFA::OrientedLine
      if value.line == oldref
        value.line = newref
      end
    when Array
      value.map! do |elem|
        case elem
        when RGFA::Line
          elem = newref if elem == oldref
        when RGFA::OrientedLine
          elem.line == newref if elem.line == newref
        end
        elem
      end
    end
  end

  def update_field_references(oldref, newref, possible_fieldnames)
    possible_fieldnames.each do |fn|
      update_reference_in_field(fn, oldref, newref ? newref : oldref.to_sym)
    end
  end

  def update_nonfield_references(oldref, newref, possible_keys)
    possible_keys.each do |key|
      idx = @refs[key].index {|x| x.equal?(oldref)}
      next if idx.nil?
      @refs[key] = ((idx > 0 ? @refs[key][0..idx-1] : []) +
                    (newref ? [newref] : []) + @refs[key][idx+1..-1]).freeze
    end
  end

end
