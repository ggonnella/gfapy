#
# Methods for the RGFA class, which allow to add lines.
#
module RGFA::Lines::Collections

  COLLECTIONS_NO_ID = {
    :comments => :"#",
    :containments => :C,
    :links => :L,
  }

  COLLECTIONS_MANDATORY_ID = {
    :segments => :S,
    :gfa1_paths => :P
  }

  COLLECTIONS_OPTIONAL_ID = {
    :edges => :E,
    :gaps => :G,
    :sets => :U,
    :gfa2_paths => :O
  }

  # @!method comments
  #   All comment lines of the RGFA
  #   @return [Array<RGFA::Line::Comment>]
  # @!method containments
  #   All containments in the RGFA
  #   @return [Array<RGFA::Line::Edge::Containment>]
  # @!method fragments
  #   All fragment lines of the RGFA
  #   @return [Array<RGFA::Line::Fragment>]
  # @!method links
  #   All links of the RGFA
  #   @return [Array<RGFA::Line::Edge::Link>]
  COLLECTIONS_NO_ID.each do |k, v|
    define_method(k){@records[v]}
  end

  # @!method sets
  #   All unordered group lines of the RGFA
  #   @return [Array<RGFA::Line::Group::Set>]
  # @!method set_names
  #   List all names of sets in the RGFA
  #   @return [Array<Symbol>]
  # @!method gaps
  #   All gap lines of the RGFA
  #   @return [Array<RGFA::Line::Gap>]
  # @!method gap_names
  #   List all names of gaps in the RGFA
  #   @return [Array<Symbol>]
  # @!method edges
  #   All edge lines of the RGFA
  #   @return [Array<RGFA::Line::Edge::GFA2>]
  # @!method edge_names
  #   List all names of edges in the RGFA
  #   @return [Array<Symbol>]
  COLLECTIONS_OPTIONAL_ID.each do |k, v|
    define_method(k) {@records[v].values.flatten}
    define_method(:"#{k[0..-2]}_names") {@records[v].keys - [nil]}
  end

  # @!method segments
  #   All segment lines of the RGFA
  #   @return [Array<RGFA::Line::Segment::GFA1,RGFA::Line::Segment::GFA2>]
  # @!method segment_names
  #   List all names of segments in the RGFA
  #   @return [Array<Symbol>]
  COLLECTIONS_MANDATORY_ID.each do |k, v|
    define_method(k) {@records[v].values}
    define_method(:"#{k[0..-2]}_names") {@records[v].keys}
  end

  # All path or ordered set lines of the RGFA
  # @return [Array<RGFA::Line::Group::Path,RGFA::Line::Group::Ordered>]
  def paths
    gfa1_paths + gfa2_paths
  end

  # List all names of path lines in the RGFA
  # @return [Array<Symbol>]
  def path_names
    gfa1_path_names + gfa2_path_names
  end

  def fragments
    @records[:F].values.flatten
  end

  def external_names
    @records[:F].keys
  end

  def names
    segment_names + edge_names + gap_names + path_names + set_names
  end

  GFA1_ONLY_KEYS = [:L, :C, :P]
  NONCUSTOM_GFA2_KEYS = [:H, :"#", :F, :S, :E, :G, :U, :O, nil]

  # All record type keys of custom records of the RGFA
  # @return [Array<Symbol>]
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

  # All custom records of the RGFA
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
        paths + sets + gaps + fragments +
          custom_records
  end

  def each_line(&block)
    lines.each(&block)
  end

end
