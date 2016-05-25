class GFA::ConnectionInfo

  def initialize(lines)
    @lines = lines
    @connect = {}
    ["L","C","P"].each {|rt| @connect[rt] = {}}
  end

  # Add values to connection infos
  def add(rt, value, sn, dir=nil, o=nil)
    raise if value.nil?
    raise "RT invalid: #{rt.inspect} "if !["L", "C", "P"].include?(rt)
    if rt == "P"
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

  # Remove values from connection infos
  #
  # Usage:
  # - delete("P", value, sn) => rm path ref
  # - delete("C"|"L", value, sn, :from|:to, "+"|"-") => rm link/containment ref
  # - delete("C"|"L", value, sn, :from|:to, nil) => rm link/containment ref
  #                                                 from both "+" and "-"
  #                                                 connections of sn
  def delete(rt, value, sn, dir=nil, o=nil)
    raise if value.nil?
    raise "RT invalid: #{rt.inspect} "if !["L", "C", "P"].include?(rt)
    if rt == "P"
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

  def rename_segment(sn, new_sn)
    ["P", "L", "C"].each do |rt|
      if @connect[rt].has_key?(sn)
        @connect[rt][new_sn] = @connect[rt][sn]
        @connect[rt].delete(sn)
      end
    end
    validate! if $DEBUG
    self
  end

  def delete_segment(sn)
    ["L", "C", "P"].each {|rt| @connect[rt].delete(sn)}
    self
  end

  def lines(rt, sn, dir = nil, o = nil)
    find(rt, sn, dir, o).map{|i| @lines[rt][i]}
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
    raise "RT invalid: #{rt.inspect} "if !["L", "C", "P"].include?(rt)
    if rt == "P"
      @connect[rt].fetch(sn,[])
    else
      raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
      return find(rt,sn,dir,"+")+find(rt,sn,dir,"-") if o.nil?
      raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
      @connect[rt].fetch(sn,{}).fetch(dir,{}).fetch(o,[])
    end
  end

  # Checks if all elements of connect refer to a path, link of containment
  # which was not deleted and whose fields (from, to, from_orient, to_orient
  # for links and containments, segment_names for paths) have the expected
  # values.
  #
  # Method useful for debugging.
  def validate!
    @connect["P"].keys.each do |sn|
      @connect["P"][sn].each do |li|
        l = @lines["P"][li]
        if l.nil? or !l.segment_names.map{|s,o|s}.include?(sn)
          raise "Error in connect\n"+
            "@connect[P][#{sn}]=[#{li},..]\n"+
            "@links[P][#{li}]=#{l.nil? ? l.inspect : l.to_s}"
        end
      end
    end
    ["L", "C"].each do |rt|
      @connect[rt].keys.each do |sn|
        @connect[rt][sn].keys.each do |dir|
          @connect[rt][sn][dir].keys.each do |o|
            @connect[rt][sn][dir][o].each do |li|
              l = @lines[rt][li]
              if l.nil? or l.send(dir) != sn or l.send(:"#{dir}_orient") != o
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
