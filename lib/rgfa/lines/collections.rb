#
# Methods for the RGFA class, which allow to add lines.
#
# @tested_in api_lines_collections
#
module RGFA::Lines::Collections

  # Names of the collections and record type of lines which
  # do not have a name field
  COLLECTIONS_NO_NAME = {
    :comments => :"#",
    :gfa1_containments => :C,
    :gfa1_links => :L,
  }

  # Names of the collections and record type of lines which
  # have a mandatory name field
  COLLECTIONS_MANDATORY_NAME = {
    :segments => :S,
    :gfa1_paths => :P
  }

  # Names of the collections and record type of lines which
  # have an optional name field
  COLLECTIONS_OPTIONAL_NAME = {
    :gfa2_edges => :E,
    :gaps => :G,
    :sets => :U,
    :gfa2_paths => :O
  }

  # @!method comments
  #   All comment lines of the RGFA
  #   @return [Array<RGFA::Line::Comment>]
  COLLECTIONS_NO_NAME.each do |k, v|
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
  COLLECTIONS_OPTIONAL_NAME.each do |k, v|
    define_method(k) {@records[v].values.flatten}
    define_method(:"#{k[0..-2]}_names") {@records[v].keys - [nil]}
  end

  # @!method segments
  #   All segment lines of the RGFA
  #   @return [Array<RGFA::Line::Segment::GFA1,RGFA::Line::Segment::GFA2>]
  # @!method segment_names
  #   List all names of segments in the RGFA
  #   @return [Array<Symbol>]
  COLLECTIONS_MANDATORY_NAME.each do |k, v|
    define_method(k) {@records[v].values}
    define_method(:"#{k[0..-2]}_names") {@records[v].keys}
  end

  # All edge lines of the RGFA
  # @return [Array<RGFA::Line::Edge>]
  def edges
    if version == :gfa1
      gfa1_links + gfa1_containments
    elsif version == :gfa2
      gfa2_edges
    else
      gfa1_links + gfa1_containments + gfa2_edges
    end
  end

  # All dovetail lines of the RGFA
  # (GFA1 links, GFA2 dovetail edges)
  # @return [Array<RGFA::Line::Edge>]
  def dovetails
    if version == :gfa1
      gfa1_links
    elsif version == :gfa2
      gfa2_edges.select {|e| e.dovetail?}
    else
      gfa1_links + gfa2_edges.select {|e| e.dovetail?}
    end
  end

  # All containment lines of the RGFA
  # (GFA1 containments, GFA2 containment edges)
  # @return [Array<RGFA::Line::Edge>]
  def containments
    if version == :gfa1
      gfa1_containments
    elsif version == :gfa2
      gfa2_edges.select {|e| e.containment?}
    else
      gfa1_containments + gfa2_edges.select {|e| e.containment?}
    end
  end

  # List all names of edges in the RGFA
  # @return [Array<Symbol>]
  def edge_names
    gfa2_edge_names
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

  # All fragments of the RGFA instance
  # @return [Array<RGFA::Line::Fragment>]
  def fragments
    @records[:F].values.flatten
  end

  # All names of external sequences mentioned in fragments
  # @return [Array<Symbol>]
  def external_names
    @records[:F].keys
  end

  # All names of lines
  # (segments and paths in GFA1/GFA2; edges, gaps, sets in GFA2)
  # @return [Array<Symbol>]
  def names
    segment_names + edge_names + gap_names + path_names + set_names
  end

  # Record types only allowed in GFA1 (in RGFA)
  GFA1_ONLY_KEYS = [:L, :C, :P]

  # Record types allowed in GFA2 (except custom lines);
  # nil is a placeholder for virtual lines of unknown type
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

  # All custom records of the RGFA instance
  # @return [Array<RGFA::Line::CustomRecord>]
  def custom_records(record_type=nil)
    if record_type
      return [].freeze if !custom_record_keys.include?(record_type)
      collection = @records[record_type]
      case collection
      when nil
        return [].freeze
      when Array
        return collection.clone.freeze
      when Hash
        return collection.values.freeze
      end
    else
      cr = []
      custom_record_keys.each do |k|
        collection = @records[k]
        case collection
        when Array
          cr += collection
        when Hash
          cr += collection.values
        end
      end
      cr.freeze
    end
  end

  # All lines of the RGFA instance
  # @return [Array<RGFA::Line>]
  def lines
    comments + headers + segments + edges +
        paths + sets + gaps + fragments +
          custom_records
  end

  # Iterate over each line of the RGFA instance
  # @yield [Array<RGFA::Line>]
  def each_line(&block)
    lines.each(&block)
  end

end
