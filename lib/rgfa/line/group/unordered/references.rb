module RGFA::Line::Group::Unordered::References

  # Add an item to the group
  # @param item [RGFA::Line, Symbol]
  #    GFA2 edge, segment, gap or group line to add
  # @return [void]
  def add_item(item)
    if !connected?
      add_item_to_unconnected_group(item)
    else
      add_item_to_connected_group(item)
    end
  end

  # Remove an item from the group
  # @param item [Symbol, RGFA::Line]
  #   GFA2 edge, segment, gap or group line to remove
  # @return [void]
  def rm_item(item)
    if !connected?
      rm_item_from_unconnected_group(item)
    else
      rm_item_from_connected_group(item)
    end
  end

  private

  def rm_item_from_unconnected_group(item)
    item = item.name if item.kind_of?(RGFA::Line)
    check_item_included(item)
    self.items.delete(item)
    return nil
  end

  def rm_item_from_connected_group(item)
    item = @rgfa.search_by_name(item) if item.kind_of?(Symbol)
    check_item_included(item)
    line.delete_reference(self, :unordered_groups)
    self.delete_reference(line, :items)
    return nil
  end

  def check_item_included(item)
    if !items.include?(item)
      raise RGFA::NotFoundError,
        "Line: #{self}\n"+
        "Item: #{item.inspect}"+
        "Items of the line do not include the item"
    end
  end

  def add_item_to_unconnected_group(item, append = true)
    item = item.name if item.kind_of?(RGFA::Line)
    items.send(append ? :push : :unshift, item)
    return nil
  end

  def add_item_to_connected_group(item, append = true)
    self.add_reference(prepare_and_check_ref(item),
                       :items, append: append)
    return nil
  end

  def update_reference_in_field(field, oldref, newref)
    case field
    when :items
      items.each {|item| item = newref if item == oldref }
    end
  end

  def initialize_references
    items.size.times do |i|
      items[i] = line_for_ref_symbol(items[i])
    end
  end

  def disconnect_field_references
    items.size.times do |i|
      items[i] = items[i].name if items[i].kind_of?(RGFA::Line)
    end
  end

end
