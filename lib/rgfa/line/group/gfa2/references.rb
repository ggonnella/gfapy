RGFA::Line::Group::GFA2 ||= Module.new

module RGFA::Line::Group::GFA2::References

  private

  def prepare_and_check_ref(ref)
    ref = line_for_ref_symbol(ref) if ref.kind_of?(Symbol)
    check_ref_class(ref)
    check_ref_connection(ref)
    check_ref_not_self(ref)
    return ref
  end

  def check_ref_class(item)
    if ![RGFA::Line::Edge::GFA2,
         RGFA::Line::Segment::GFA2,
         RGFA::Line::Gap,
         RGFA::Line::Group::Ordered,
         self::class].include?(item.class)
    raise RGFA::ArgumentError,
      "Line: #{self}\n"+
    "Cannot add items of class #{item.class}\n"+
    "Only GFA2 edges, segments, gaps, groups[*] "+
    "can be added\n(* = unordered groups to unordered groups only)."
    end
  end

  def check_ref_connection(item)
    if line.rgfa != self.rgfa
      raise RGFA::ArgumentError,
        "Line: #{self}\n"+
      "Item: #{item.inspect}"+
      "The item added to the group must be connected\n"+
      "to the same RGFA object as the group"
    end
  end

  def check_ref_not_self(item)
    if (line == self)
      raise RGFA::RuntimeError,
        "Line: #{self}\n"+
      "Item is the line itself\n"+
      "A group is not allowed to refer to itself"
    end
  end

  def line_for_ref_symbol(ref)
    line = @rgfa.search_by_name(ref)
    if line.nil?
      if @rgfa.segments_first_order
        raise RGFA::NotFoundError, "Group: #{self}\n"+
        "requires a non-existing ref with ID #{ref}"
      end
      line = RGFA::Line::Unknown.new({:name => ref}, virtual: true,
                                     version: :gfa2)
      @rgfa << line
    end
    line.add_reference(self, (record_type == :O) ?
                         :ordered_groups : :unordered_groups)
    return line
  end

end
