# A segment line of a RGFA file
class RGFA::Line::Segment < RGFA::Line

  RECORD_TYPE = :S
  POSFIELDS = {:"1.0" => [:name, :sequence],
               :"2.0" => [:name, :slen, :sequence]}
  PREDEFINED_TAGS = [:LN, :RC, :FC, :KC, :SH, :UR]
  DATATYPE = {
    :name => :lbl,
    :sequence => :seq,
    :slen => :pos,
    :LN => :i,
    :RC => :i,
    :FC => :i,
    :KC => :i,
    :SH => :H,
    :UR => :Z
  }
  FIELD_ALIAS = { :sid => :name }

  define_field_methods!

  attr_writer :links, :containments, :paths

  # References to the links in which the segment is involved.
  #
  # @!macro references_table
  #   The references are in four arrays which are
  #   accessed from a nested hash table. The first key is
  #   the direction (from or to), the second is the orientation
  #   (+ or -).
  #
  # @example
  #   segment.links[:from][:+]
  #
  # @return [Hash{RGFA::Line::DIRECTION => Hash{RGFA::Line::ORIENTATION => Array<RGFA::Line::Link>}}]
  def links
    @links ||= {:from => {:+ => [], :- => []},
                :to   => {:+ => [], :- => []}}
    @links
  end

  # References to the containments in which the segment is involved.
  # @!macro references_table
  #
  # @example
  #   segment.containments[:from][:+]
  #
  # @return [Hash{RGFA::Line::DIRECTION => Hash{RGFA::Line::ORIENTATION => Array<RGFA::Line::Containment>}}]
  def containments
    @containments ||= {:from => {:+ => [], :- => []},
                       :to   => {:+ => [], :- => []}}
    @containments
  end

  # References to the containments in which the segment is involved.
  #
  # The references are in two arrays which are
  # accessed from a hash table. The key is the orientation
  # (+ or -).
  #
  # @example
  #   segment.paths[:+]
  #
  # @return [Hash{RGFA::Line::ORIENTATION => Array<RGFA::Line::Path>}]
  def paths
    @paths ||= {:+ => [], :- => []}
    @paths
  end

  # All containments where a segment is involved.
  # @!macro this_is_a_copy
  #   @note the list shall be considered read-only, as this
  #     is a copy of the original arrays of references, concatenated
  #     to each other.
  def all_containments
    l = self.containments
    l[:from][:+] + l[:from][:-] + l[:to][:+] + l[:to][:-]
  end

  # All links where the segment is involved.
  # @!macro this_is_a_copy
  def all_links
    l = self.links
    l[:from][:+] + l[:from][:-] + l[:to][:+] + l[:to][:-]
  end

  # All links and containments where the segment is involved.
  # @!macro this_is_a_copy
  def all_connections
    all_links + all_containments
  end

  # All paths where the segment is involved.
  # @!macro this_is_a_copy
  def all_paths
    pt = self.paths
    pt[:+] + pt[:-]
  end

  # All paths, links and containments where the segment is involved.
  # @!macro this_is_a_copy
  def all_references
    all_connections + all_paths
  end

  # @raise [RGFA::InconsistencyError]
  #    if sequence length and LN tag are not consistent.
  def validate_length!
    if sequence != "*" and tagnames.include?(:LN)
      if self.LN != sequence.length
        raise RGFA::InconsistencyError,
          "Length in LN tag (#{self.LN}) "+
          "is different from length of sequence field (#{sequence.length})"
      end
    end
  end

  # @!macro [new] length
  #   @return [Integer] value of LN tag, if segment has LN tag
  #   @return [Integer] sequence length if no LN and sequence not "*"
  # @return [nil] if sequence is "*"
  # @see #length!
  def length
    if self.LN
      self.LN
    elsif sequence != "*" and !sequence.kind_of?(RGFA::Placeholder)
      sequence.length
    else
      nil
    end
  end

  # @!macro length
  # @!macro [new] length_needed
  #   @raise [RGFA::NotFoundError] if not an LN tag and
  #     the sequence is "*"
  # @see #length
  def length!
    l = self.length()
    raise RGFA::NotFoundError,
      "No length information available" if l.nil?
    return l
  end

  # @!macro [new] coverage
  #   The coverage computed from a count_tag.
  #   If unit_length is provided then: count/(length-unit_length+1),
  #   otherwise: count/length.
  #   The latter is a good approximation if length >>> unit_length.
  #   @param [Symbol] count_tag <i>(defaults to +:RC+)</i>
  #     integer tag storing the count, usually :KC, :RC or :FC
  #   @param [Integer] unit_length the (average) length of a read (for
  #     :RC), fragment (for :FC) or k-mer (for :KC)
  #   @return [Integer] coverage, if count_tag and length are defined
  # @return [nil] otherwise
  # @see #coverage!
  def coverage(count_tag: :RC, unit_length: 1)
    if tagnames.include?(count_tag) and self.length
      return (self.get(count_tag).to_f)/(self.length-unit_length+1)
    else
      return nil
    end
  end

  # @see #coverage
  # @!macro coverage
  # @raise [RGFA::NotFoundError] if segment does not have count_tag
  # @!macro length_needed
  def coverage!(count_tag: :RC, unit_length: 1)
    c = coverage(count_tag: count_tag, unit_length: unit_length)
    if c.nil?
      self.length!
      raise RGFA::NotFoundError,
        "Tag #{count_tag} undefined for segment #{name}"
    else
      return c
    end
  end

  # @return string representation of the segment
  # @param [Boolean] without_sequence if +true+, output "*" instead of sequence
  def to_s(without_sequence: false)
    if !without_sequence
      return super()
    else
      saved = self.sequence
      self.sequence = "*"
      retval = super()
      self.sequence = saved
      return retval
    end
  end

  # @return [Symbol] name of the segment as symbol
  def to_sym
    name.to_sym
  end

  private

  def validate_record_type_specific_info!
    validate_length!
  end

end

