#
# Private methods for the GFA class, which interrogates and updates the @connect
# data structure.
#
module GFA::Connect

  private

  # Add values to @connect data structure
  def connect(rt, dir, sn, o, value)
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    raise if o != "+" and o != "-"
    @connect[rt][dir][sn]||={}
    @connect[rt][dir][sn][o]||=[]
    @connect[rt][dir][sn][o] << value
    validate_connect if $DEBUG
  end

  def connect_rename_segment(sn, new_sn)
    ["L", "C"].each do |rt|
      [:from, :to].each do |dir|
        if @connect[rt][dir].has_key?(sn)
          @connect[rt][dir][new_sn] = @connect[rt][dir][sn]
          @connect[rt][dir].delete(sn)
        end
      end
    end
    validate_connect if $DEBUG
  end

  # Remove values from @connect data structure
  #
  # Usage:
  # - disconnect(rt, dir, sn, o, value) => rm value from @connect
  # - disconnect(rt, dir, sn, nil, nil) => rm all sn connections
  # - disconnect(rt, dir, sn, nil, value) => rm value from both "+" and "-"
  #                                          connections of sn
  def disconnect(rt, dir, sn, o, value)
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    if o.nil?
      if value.nil?
        @connect[rt][dir].delete(sn)
      else
        disconnect(rt, dir, sn, "+", value)
        disconnect(rt, dir, sn, "-", value)
      end
      return
    end
    raise if o != "+" and o != "-"
    raise if value.nil?
    @connect[rt][dir].fetch(sn,{}).fetch(o,[]).delete(value)
    validate_connect if $DEBUG
  end

  def connection_lines(rt, dir, sn, o = nil)
    connections(rt, dir, sn, o).map{|i| @lines[rt][i]}
  end

  # Find relevant values from @connect data structure
  #
  # *Usage*:
  # +connections(rt, :from|:to, sn)+ => both orientations of +sn+
  # +connections(rt, :from|:to, sn, :+|:-)+ => only specified orientation
  #
  # *Note*:
  # The specified array should only be read, as it is often a
  # copy of the original; thus modifications must be done using
  # +connect()+ or +disconnect()+
  def connections(rt, dir, sn, o = nil)
    raise "RT invalid: #{rt.inspect}" if rt != "L" and rt != "C"
    raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
    return connections(rt,dir,sn,"+")+connections(rt,dir,sn,"-") if o.nil?
    raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
    @connect[rt][dir].fetch(sn,{}).fetch(o,[])
  end

  # Checks if all elements of connect refer to a link of containment
  # which was not deleted and whose from, to, from_orient, to_orient fields
  # have the expected values.
  #
  # Method useful for debugging.
  def validate_connect
    @connect.keys.each do |rt|
      @connect[rt].keys.each do |dir|
        @connect[rt][dir].keys.each do |sn|
          @connect[rt][dir][sn].keys.each do |o|
            @connect[rt][dir][sn][o].each do |li|
              l = @lines[rt][li]
              if l.nil? or l.send(dir) != sn or l.send(:"#{dir}_orient") != o
                raise "Error in connect\n"+
                  "@connect[#{rt}][#{dir.inspect}][#{sn}][#{o}]=#{li}\n"+
                  "@links[#{rt}][#{li}]=#{l.nil? ? l.inspect : l.to_s}"
              end
            end
          end
        end
      end
    end
  end

end
