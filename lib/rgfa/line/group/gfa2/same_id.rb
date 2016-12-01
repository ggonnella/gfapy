RGFA::Line::Group::GFA2 ||= Module.new

module RGFA::Line::Group::GFA2::SameID

  private

  def process_not_unique(previous)
    @rgfa = previous.rgfa
    initialize_references
    cur_items = get(:items)
    substitute_virtual_line(previous)
    set_existing_field(:items, get(:items) + cur_items, set_reference: true)
    import_tags_of_previous_group_definition(previous)
    return nil
  end

  def import_tags_of_previous_group_definition(previous)
    previous.tagnames.each do |tag|
      prv = previous.get(tag)
      cur = get(tag)
      if cur
       if cur != prv
         raise RGFA::NotUniqueError,
           "Same tag defined differently in "+
           "multiple group lines with same ID\n"+
           "Previous tag definition: #{prv}\n"+
           "New tag definition: #{cur}\n"+
           "Group ID: #{name}"
       end
      else
        set(tag,prv)
      end
    end
  end

end
