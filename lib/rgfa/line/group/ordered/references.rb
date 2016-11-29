module RGFA::Line::Group::Ordered::References

  # Add an item to the group as last item
  # @param item [RGFA::Line, Symbol]
  #    GFA2 edge, segment, gap or group line to add
  # @return [void]
  def append_item(item)
    if !connected?
      add_item_to_unconnected_group(item, true)
    else
      add_item_to_connected_group(item, true)
    end
    check_consistency
  end

  # Add an item to the group as first item
  # @param item [RGFA::Line, Symbol]
  #    GFA2 edge, segment, gap or group line to add
  # @return [void]
  def prepend_item(item)
    if !connected?
      add_item_to_unconnected_group(item, false)
    else
      add_item_to_connected_group(item, false)
    end
    check_consistency
  end

  # Remove the first item from the group
  # @param item [Symbol, RGFA::Line]
  #   GFA2 edge, segment, gap or group line to remove
  # @return [void]
  def rm_first_item
    if !connected?
      items = items[1..-1]
    else
      items[0].delete_reference(self, :ordered_groups)
      self.delete_reference(items[0], :items)
    end
    return nil
  end

  # Remove the last item from the group
  # @param item [Symbol, RGFA::Line]
  #   GFA2 edge, segment, gap or group line to remove
  # @return [void]
  def rm_last_item
    if !connected?
      items = items[0..-2]
    else
      items[-1].delete_reference(self, :ordered_groups)
      self.delete_reference(items[-1], :items)
    end
    return nil
  end

  private

  def add_item_to_unconnected_group(item, append = true)
    item.line = item.name if item.line.kind_of?(RGFA::Line)
    items.send(append ? :push : :unshift, item)
    return nil
  end

  def add_item_to_connected_group(item, append = true)
    item.line = prepare_and_check_ref(item.line)
    self.add_reference(item, :items, append: append)
    check_consistency
    return nil
  end

  # Check that the elements in an ordered set are contiguous
  def check_consistency
    # not implemented yet
  end

  def initialize_references
    items.size.times do |i|
      items[i].line = line_for_ref_symbol(items[i].line)
    end
  end

end
