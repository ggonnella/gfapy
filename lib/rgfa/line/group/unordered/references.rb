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
    deleted = self.items.delete(item)
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

end
