RGFA::Line::Group::GFA2 ||= Module.new

module RGFA::Line::Group::GFA2::References

  private

  def update_reference_in_field(field, oldref, newref)
    case field
    when :items
      items.each {|item| item = newref if item == oldref }
    end
  end

  def initialize_references
    items.size.times do |i|
      item = items[i]
      line = @rgfa.search_by_name(item)
      if line.nil?
        if @rgfa.segments_first_order
          raise RGFA::NotFoundError, "Group: #{self}\n"+
          "requires a non-existing item with ID #{item}"
        end
        line = RGFA::Line::Unknown.new({:name => item}, virtual: true,
                                     version: :"2.0")
        line.connect(@rgfa)
      end
      items[i] = line
      line.add_reference(self, (record_type == :O) ? :ordered_groups :
                                                     :unordered_groups)
    end
  end

  def disconnect_field_references
    items.size.times {|i| items[i] = i.to_sym if items[i].kind_of?(RGFA::Line)}
  end

  def backreference_keys(ref, key_in_ref)
    [:items]
  end

end
