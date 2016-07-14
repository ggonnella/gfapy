require "set"

#
# Collection of hashes which allow fast retrieval of the lines of a GFA graph
# which refer to a given segment.
#
# @api private
#
# @note It is not required that a segment has already been added
#   to the GFA using an :S line. This is necessary, as the order of the lines
#   in the file during parsing is arbitrary.
#
class RGFA::ConnectionInfo

  # @return [RGFA::ConnectionInfo]
  # @param lines [Array] reference to RGFA instance @lines array
  #   (required by the #validate! and the #lines methods)
  def initialize(lines, segment_names)
    @lines = lines
    @segment_names = segment_names
    @virtual_segments = Hash.new
  end

  # Add a reference to a link/containment or path to connection infos
  #
  # @!macro [new] connection_params
  #   @param rt [:L, :C, :P] the record type
  #   @param sn [String, RGFA::Line::Segment] the segment name or instance
  #   @param dir [:from, :to, nil] is segment the from or the to segment of the
  #     link/containment?; use nil for paths
  # @param value [Integer] an index in @lines[rt]
  # @param o [:+, :-, nil] the segment orientation (links/containments); use
  #   nil for # paths
  # @return [void]
  def add(rt, value, sn, dir=nil, o=nil)
    connections = get_connections_hash(sn)
    if rt == :P
      connections[rt] ||= Set.new
      connections[:P] << value
    else
      connections[rt] ||= {}
      connections[rt][dir] ||= {}
      connections[rt][dir][o] ||= Set.new
      connections[rt][dir][o] << value
    end
    nil
  end

  # Remove a link/containment/path reference from connection infos
  #
  # @!macro connection_params
  # @!macro orientation_or_nil
  #   @param o [:+,:-,nil] orientation (for links/containments);
  #     set to nil for paths; if nil in links/containments: both orientations
  # @param value [Integer] index in @lines[rt] to remove
  # @return [void]
  #
  # @example
  #   delete("P", value, sn)                         # => rm path ref
  #   delete("C"|"L", value, sn, :from|:to, :+|:-) # => rm link/cont. ref
  #   delete("C"|"L", value, sn, :from|:to, nil)
  #               # => rm link/cont. ref from sn in both :+ and :- orient
  #
  def delete(rt, value, sn, dir=nil, o=nil)
    connections = get_connections_hash(sn)
    c_rt = connections[rt]
    return if c_rt.nil?
    if rt == :P
      c_rt.delete(value)
    else
      if o.nil?
        delete(rt, value, sn, dir, :+)
        delete(rt, value, sn, dir, :-)
        return
      end
      c_rt_dir = c_rt[dir]
      return if c_rt_dir.nil?
      c_rt_dir_o = c_rt_dir[o]
      return if c_rt_dir_o.nil?
      c_rt_dir_o.delete(value)
    end
    nil
  end

  # Rename a segment in the connection info.
  # @param sn [RGFA::Line::Segment, String] the old segment instance or name
  # @param new_sn [RGFA::Line::Segment, String] the new segment instance or name
  # @return [void]
  def rename_segment(sn, new_sn)
    if @virtual_segments.has_key?(sn)
      @virtual_segments[new_sn] = @virtual_segments.delete(sn)
    end
    nil
  end

  # Delete all information about a segment in the connection info.
  # @param sn [RGFA::Line::Segment, String] the segment instance or segment name
  # @return [void]
  def delete_segment(sn)
    @virtual_segments.delete(sn)
    nil
  end

  # Find indices of RGFA lines referring to a segment
  #
  # @!macro connection_params
  # @!macro orientation_or_nil
  #
  # @example
  #   find("P", sn)                       # => find paths
  #   find("C"|"L", sn, :from|:to)        # => both orientations
  #   find("C"|"L", sn, :from|:to, :+|:-) # => only specified orientation
  #
  # @note Do not modify the returned array; modifications must be done using
  #   {#add} and {#delete}.
  # @return [Array<Integer>] the indices of lines array of given record
  #   type for all lines referring to the segment and respecting the +dir+
  #   and +o+ conditions
  def find(rt, sn, dir = nil, o = nil)
    connections = get_connections_hash(sn)
    c_rt = connections[rt]
    return [] if c_rt.nil?
    if rt == :P
      return c_rt
    else
      return find(rt,sn,dir,:+)+find(rt,sn,dir,:-) if o.nil?
      c_rt_dir = c_rt[dir]
      return [] if c_rt_dir.nil?
      c_rt_dir_o = c_rt_dir[o]
      return c_rt_dir_o.nil? ? [] : c_rt_dir_o.to_a
    end
  end

  # Find GFA lines referring to a segment
  #
  # @!macro connection_params
  # @!macro orientation_or_nil
  #
  # @note You can modify the line instances, but do not modify the returned
  #   array itself; modifications must be done using {#add} and {#delete}.
  # @return [Array<RGFA::Line>] the lines of given record type referring to the
  #   segment and respecting the +dir+ and +o+ conditions
  def lines(rt, sn, dir = nil, o = nil)
    find(rt, sn, dir, o).map{|i| @lines[rt][i]}
  end

  # Validate the information in connection info (useful for debugging).
  #
  # @raise if any path/link/containment was deleted from +@lines+
  # @raise if any link/containment field (from/from_orient/to/to_orient) is not
  #   consistent with the stored information
  # @raise if the paths segment name field is not consistent
  #   with the stored information
  # @return [void]
  #
  def validate!
    return true
    @connect[:P].keys.each do |sn|
      @connect[:P][sn].each do |li|
        l = @lines[:P][li]
        if l.nil? or !l.segment_names.map{|s,o|s.to_sym}.include?(sn)
          raise "Error in connect\n"+
            "@connect[P][#{sn}]=[#{li},..]\n"+
            "@links[P][#{li}]=#{l.nil? ? l.inspect : l.to_s}"
        end
      end
    end
    [:L, :C].each do |rt|
      @connect[rt].keys.each do |sn|
        @connect[rt][sn].keys.each do |dir|
          @connect[rt][sn][dir].keys.each do |o|
            @connect[rt][sn][dir][o].each do |li|
              l = @lines[rt][li]
              if l.nil? or l.send(dir).to_sym != sn or
                   l.send(:"#{dir}_orient") != o
                raise "Error in connect\n"+
                  "@connect[#{rt}][#{sn}][#{dir.inspect}][#{o}]=[#{li},..]\n"+
                  "@links[#{rt}][#{li}]=#{l.nil? ? l.inspect : l.to_s}"
              end
            end
          end
        end
      end
    end
    nil
  end

  private

  def get_connections_hash(sn)
    sn = sn.to_sym
    snum = @segment_names[sn]
    connections = nil
    if snum.nil?
      connections = @virtual_segments[sn]
      if connections.nil?
        connections = {}
        @virtual_segments[sn] = connections
      end
    else
      s = @lines[:S][snum]
      connections = @virtual_segments.delete(sn)
      if connections
        s.connections = connections
      else
        s.connections ||= {}
        connections = s.connections
      end
    end
    return connections
  end

end
