#
# Collection of hashes which allow fast retrieval of the lines of a GFA
# which refer to a given segment.
#
# Note that it is not required that the segment has already been added
# to the GFA using an "S" line. This is necessary, as the order of the lines
# in the file during parsing is arbitrary.
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
  # @param rt [:L|:C|:P] the record type
  # @param value [Integer] an index in @lines[rt]
  # @param sn [String] the segment name
  # @param dir [:from|:to|nil] is segment the from or the to segment of the
  #   link/containment?; use nil for paths
  # @param o ["+"|"-"|nil] the segment orientation (links/containments); use
  #   nil for # paths
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
    self
  end

  # Remove a link/containment/path reference from connection infos
  #
  # @param rt [:L|:C|:P] the record type
  # @param value [Integer] the value (index in @lines[rt]) to remove
  # @param sn [String] the segment name
  # @param dir [:from|:to|nil] direction (for links/containments);
  #   set to nil for paths
  # @param o ["+"|"-"|nil] orientation (for links/containments);
  #   set to nil for paths; if nil in links/containments: both
  #
  # @example delete("P", value, sn) => rm path ref
  # @example  delete("C"|"L", value, sn, :from|:to, "+"|"-")
  #   => rm link/containment ref
  # @example delete("C"|"L", value, sn, :from|:to, nil)
  #   => rm link/containment ref from both "+" and "-" connections of sn
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
    self
  end

  # Rename a segment in the connection info.
  # @param sn [String] old segment name
  # @param new_sn [String] new segment name
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
    self
  end

  # Delete all information about a segment in the connection info.
  # @param sn [String] the segment name
  def delete_segment(sn)
    [:P, :L, :C].each {|rt| @connect[rt].delete(sn.to_sym)}
    self
  end

  # Find values from connection infos
  #
  # *Usage*:
  # +find("P", sn)+ => find paths
  # +find("C"|"L", sn, :from|:to)+ => both orientations of +sn+
  # +find("C"|"L", sn, :from|:to, :+|:-)+ => only specified orientation
  #
  # *Note*:
  # The returned array should only be read; modifications must be done using
  # +add()+ or +delete()+
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

  # @return [Array<GFA::Line>] the lines of the given record type for segment
  def lines(rt, sn, dir = nil, o = nil)
    find(rt, sn, dir, o).map{|i| @lines[rt][i]}
  end

  # Validate the information in connection info (useful for debugging).
  #
  # @raise if any path/link/containment was deleted from +@lines+
  # @raise if any link/containment field (from/from_orient/to/to_orient) is not
  #   consistent with the stored information
  # @raise if the paths segment name field is not consistent
  #   with the stored inforation
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
  end

end
