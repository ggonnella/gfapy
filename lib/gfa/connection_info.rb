#
# Collection of hashes which allow fast retrieval of the lines of a GFA
# which refer to a given segment.
#
# @api private
#
# @note It is not required that a segment has already been added
#   to the GFA using an "S" line. This is necessary, as the order of the lines
#   in the file during parsing is arbitrary.
#
class GFA::ConnectionInfo

  # @return [GFA::ConnectionInfo]
  # @param lines [Array] reference to GFA instance @lines array
  #   (required by the #validate! and the #lines methods)
  def initialize(lines)
    @lines = lines
    @connect = {}
    [:L,:C,:P].each {|rt| @connect[rt] = {}}
  end

  # Add a reference to a link/containment or path to connection infos
  #
  # @!macro [new] connection_params
  #   @param rt [:L, :C, :P] the record type
  #   @param sn [String, GFA::Line::Segment] the segment name or instance
  #   @param dir [:from, :to, nil] is segment the from or the to segment of the
  #     link/containment?; use nil for paths
  # @param value [Integer] an index in @lines[rt]
  # @param o ["+", "-", nil] the segment orientation (links/containments); use
  #   nil for # paths
  # @return [void]
  def add(rt, value, sn, dir=nil, o=nil)
    rt = rt.to_sym
    sn = sn.to_sym
    raise if value.nil?
    raise "RT invalid: #{rt.inspect} "if ![:L, :C, :P].include?(rt)
    if rt == :P
      @connect[rt][sn]||=[]
      @connect[rt][sn] << value
    else
      raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
      raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
      @connect[rt][sn]||={}
      @connect[rt][sn][dir]||={}
      @connect[rt][sn][dir][o]||=[]
      @connect[rt][sn][dir][o] << value
    end
    validate! if $DEBUG
    nil
  end

  # Remove a link/containment/path reference from connection infos
  #
  # @!macro connection_params
  # @!macro orientation_or_nil
  #   @param o ["+","-",nil] orientation (for links/containments);
  #     set to nil for paths; if nil in links/containments: both orientations
  # @param value [Integer] index in @lines[rt] to remove
  # @return [void]
  #
  # @example
  #   delete("P", value, sn)                         # => rm path ref
  #   delete("C"|"L", value, sn, :from|:to, "+"|"-") # => rm link/cont. ref
  #   delete("C"|"L", value, sn, :from|:to, nil)
  #               # => rm link/cont. ref from sn in both "+" and "-" orient
  #
  def delete(rt, value, sn, dir=nil, o=nil)
    rt = rt.to_sym
    sn = sn.to_sym
    raise if value.nil?
    raise "RT invalid: #{rt.inspect} "if ![:L, :C, :P].include?(rt)
    if rt == :P
      @connect[rt].fetch(sn,[]).delete(value)
    else
      raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
      if o.nil?
        delete(rt, value, sn, dir, "+")
        delete(rt, value, sn, dir, "-")
        return
      end
      raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
      @connect[rt].fetch(sn,{}).fetch(dir,{}).fetch(o,[]).delete(value)
    end
    validate! if $DEBUG
    nil
  end

  # Rename a segment in the connection info.
  # @param sn [GFA::Line::Segment, String] the old segment instance or name
  # @param new_sn [GFA::Line::Segment, String] the new segment instance or name
  # @return [void]
  def rename_segment(sn, new_sn)
    sn = sn.to_sym
    new_sn = new_sn.to_sym
    [:P, :L, :C].each do |rt|
      if @connect[rt].has_key?(sn)
        @connect[rt][new_sn] = @connect[rt][sn]
        @connect[rt].delete(sn)
      end
    end
    validate! if $DEBUG
    nil
  end

  # Delete all information about a segment in the connection info.
  # @param sn [GFA::Line::Segment, String] the segment instance or segment name
  # @return [void]
  def delete_segment(sn)
    [:P, :L, :C].each {|rt| @connect[rt].delete(sn.to_sym)}
    nil
  end

  # Find indices of GFA lines referring to a segment
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
    rt = rt.to_sym
    sn = sn.to_sym
    raise "RT invalid: #{rt.inspect} "if ![:L, :C, :P].include?(rt)
    if rt == :P
      @connect[rt].fetch(sn,[])
    else
      raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
      return find(rt,sn,dir,"+")+find(rt,sn,dir,"-") if o.nil?
      raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
      @connect[rt].fetch(sn,{}).fetch(dir,{}).fetch(o,[])
    end
  end

  # Find GFA lines referring to a segment
  #
  # @!macro connection_params
  # @!macro orientation_or_nil
  #
  # @note You can modify the line instances, but do not modify the returned
  #   array itself; modifications must be done using {#add} and {#delete}.
  # @return [Array<GFA::Line>] the lines of given record type referring to the
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
    @connect[:P].keys.each do |sn|
      @connect[:P][sn].each do |li|
        l = @lines["P"][li]
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
              l = @lines[rt.to_s][li]
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

end
