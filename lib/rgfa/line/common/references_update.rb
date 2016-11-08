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

  # @note SUBCLASSES must overwrite this method if they
  #   can be referenced by virtual lines
  # @return [Array<Symbol>] fieldnames and/or @refs keys
  def backreference_keys(ref, key_in_ref)
    []
  end

  # @note SUBCLASSES can overwrite this method
  # eg. if the field contain references but these are not
  # themselves the field content (e.g. path segment_names)
  def update_reference_in_field(field, oldref, newref)
    if get(field) == oldref
      set_existing_field(field, newref, set_reference: true)
    end
  end

  def update_field_references(oldref, newref, possible_fieldnames)
    possible_fieldnames.each do |fn|
      update_reference_in_field(fn, oldref, newref ? newref : oldref.to_sym)
    end
  end

  def update_nonfield_references(oldref, newref, possible_keys)
    possible_keys.each do |key|
      if @refs[key].include?(oldref)
        @refs[key] -= [oldref]
        @refs[key] += [newref] if newref
        @refs[key].freeze
      end
    end
  end

end
