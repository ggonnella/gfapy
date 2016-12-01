#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Collections

  COLLECTIONS_NO_ID = {
    :comments => :"#",
    :containments => :C,
    :fragments => :F,
    :links => :L,
  }

  COLLECTIONS_MANDATORY_ID = {
    :segments => :S,
    :paths => :P,
  }

  COLLECTIONS_OPTIONAL_ID = {
    :edges => :E,
    :gaps => :G,
    :unordered_groups => :U,
    :ordered_groups => :O,
  }

  # @!method comments
  #   All comment lines of the graph
  #   @return [Array<RGFA::Line::Comment>]
  # @!method containments
  #   All containments in the graph
  #   @return [Array<RGFA::Line::Edge::Containment>]
  # @!method fragments
  #   All fragment lines of the graph
  #   @return [Array<RGFA::Line::Fragment>]
  # @!method links
  #   All links of the graph
  #   @return [Array<RGFA::Line::Edge::Link>]
  COLLECTIONS_NO_ID.each do |k, v|
    define_method(k){@records[v]}
  end

  # @!method ordered_groups
  #   All ordered_group lines of the graph
  #   @return [Array<RGFA::Line::OrderedGroup>]
  # @!method unordered_groups
  #   All unordered_group lines of the graph
  #   @return [Array<RGFA::Line::UnorderedGroup>]
  # @!method gaps
  #   All gap lines of the graph
  #   @return [Array<RGFA::Line::Gap>]
  # @!method edges
  #   All edge lines of the graph
  #   @return [Array<RGFA::Line::Edge::GFA2>]
  COLLECTIONS_OPTIONAL_ID.each do |k, v|
    define_method(k) {@records[v].values.flatten}
    define_method(:"#{k[0..-2]}_ids") {@records[v].keys - [nil]}
  end

  # @!method paths
  #   All path lines of the graph
  #   @return [Array<RGFA::Line::Path>]
  # @!method path_names
  #   List all names of path lines in the graph
  #   @return [Array<Symbol>]
  # @!method segments
  #   All segment lines of the graph
  #   @return [Array<RGFA::Line::Segment::GFA1,RGFA::Line::Segment::GFA2>]
  # @!method segment_names
  #   List all names of segments in the graph
  #   @return [Array<Symbol>]
  COLLECTIONS_MANDATORY_ID.each do |k, v|
    define_method(k) {@records[v].values}
    define_method(:"#{k[0..-2]}_names") {@records[v].keys}
  end

  GFA1_ONLY_KEYS = [:L, :C, :P]
  NONCUSTOM_GFA2_KEYS = [:H, :"#", :F, :S, :E, :G, :U, :O, nil]

  def custom_record_keys
    keys = (@records.keys-[:H]).select {|k|!@records[k].empty?}
    case @version
    when :gfa1
      []
    when :gfa2
      keys - NONCUSTOM_GFA2_KEYS
    else
      keys - NONCUSTOM_GFA2_KEYS - GFA1_ONLY_KEYS
    end
  end

  # All custom records of the graph
  # @return [Array<RGFA::Line::CustomRecord>]
  def custom_records(record_type=nil)
    if record_type
      return [].freeze if !custom_record_keys.include?(record_type)
      @records.fetch(record_type, []).clone.freeze
    else
      cr = []
      custom_record_keys.each {|k| cr += @records[k]}
      cr.freeze
    end
  end

  def lines
    comments + headers + segments +
      links + containments + edges +
        paths + ordered_groups + unordered_groups +
          gaps + fragments + custom_records
  end

  def each_line(&block)
    lines.each(&block)
  end

end
