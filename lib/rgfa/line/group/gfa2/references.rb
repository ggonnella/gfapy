RGFA::Line::Group::GFA2 ||= Module.new

module RGFA::Line::Group::GFA2::References

  private

  def add_item_to_unconnected_group(item, append = true)
    item = item.name if item.kind_of?(RGFA::Line)
    items.send(append ? :push : :unshift, item)
    return nil
  end

  def add_item_to_connected_group(item, append = true)
    item = line_for_item_symbol(item) if item.kind_of?(Symbol)
    check_item_class(item)
    check_item_connection(item)
    check_item_not_self(item)
    self.add_reference(item, :items, append: append)
    check_consistency if record_type == :O
    return nil
  end

  def check_item_class(item)
    if ![RGFA::Line::Edge::GFA2,
         RGFA::Line::Segment::GFA2,
         RGFA::Line::Gap,
         self::class].include?(item.class)
    raise RGFA::ArgumentError,
      "Line: #{self}\n"+
    "Cannot add items of class #{item.class}\n"+
    "Only GFA2 edges, segments, gaps and groups of the same kind "+
    "can be added"
    end
  end

  def check_item_connection(item)
    if line.rgfa != self.rgfa
      raise RGFA::ArgumentError,
        "Line: #{self}\n"+
      "Item: #{item.inspect}"+
      "The item added to the group must be connected\n"+
      "to the same RGFA object as the group"
    end
  end

  def check_item_not_self(item)
    if (line == self)
      raise RGFA::RuntimeError,
        "Line: #{self}\n"+
      "Item is the line itself\n"+
      "A group is not allowed to refer to itself"
    end
  end

  def line_for_item_symbol(item)
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
    line.add_reference(self, (record_type == :O) ? :ordered_groups :
                       :unordered_groups)
    return line
  end

  def update_reference_in_field(field, oldref, newref)
    case field
    when :items
      items.each {|item| item = newref if item == oldref }
    end
  end

  def initialize_references
    items.size.times {|i| items[i] = line_for_item_symbol(items[i])}
  end

  def disconnect_field_references
    items.size.times {|i| items[i] = i.to_sym if items[i].kind_of?(RGFA::Line)}
  end

  def backreference_keys(ref, key_in_ref)
    [:items]
  end

end
