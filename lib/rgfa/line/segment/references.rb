require_relative "../segment"

module RGFA::Line::Segment::References

  def self.included(klass)
    klass.class_eval do
      attr_writer :links, :containments, :paths
    end
  end

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

end

