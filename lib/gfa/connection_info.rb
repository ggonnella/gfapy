# @connect["L"|"C"][:from|:to][segment_name]["+"|"-"] and
# @paths_with[segment_name] are hashes of indices of
# @lines["L"|"C"|"P"] which allow to directly find the links, containments
# and paths involving a given segment; they must be updated if links,
# containments or paths are added or deleted
class GFA::ConnectionInfo

  def initialize(lines)
    @lines = lines
    @connect = {}
    ["L","C"].each {|rt| @connect[rt] = {:from => {}, :to => {}}}
  end

  # Add values to connection infos
  def add(rt, dir, sn, o, value)
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    raise if o != "+" and o != "-"
    @connect[rt][dir][sn]||={}
    @connect[rt][dir][sn][o]||=[]
    @connect[rt][dir][sn][o] << value
    validate! if $DEBUG
    self
  end

  # Remove values from connection infos
  #
  # Usage:
  # - delete(rt, dir, sn, o, value) => rm value from @connect
  # - delete(rt, dir, sn, nil, value) => rm value from both "+" and "-"
  #                                          connections of sn
  def delete(rt, dir, sn, o, value)
    raise if value.nil?
    raise if rt != "L" and rt != "C"
    raise if dir != :from and dir != :to
    if o.nil?
      delete(rt, dir, sn, "+", value)
      delete(rt, dir, sn, "-", value)
      return
    end
    raise if o != "+" and o != "-"
    @connect[rt][dir].fetch(sn,{}).fetch(o,[]).delete(value)
    validate! if $DEBUG
    self
  end

  def rename_segment(sn, new_sn)
    ["L", "C"].each do |rt|
      [:from, :to].each do |dir|
        if @connect[rt][dir].has_key?(sn)
          @connect[rt][dir][new_sn] = @connect[rt][dir][sn]
          @connect[rt][dir].delete(sn)
        end
      end
    end
    validate! if $DEBUG
    self
  end

  def delete_segment(sn)
    ["L", "C"].each do |rt|
      [:from, :to].each do |dir|
        @connect[rt][dir].delete(sn)
      end
    end
    self
  end

  def lines(rt, dir, sn, o = nil)
    find(rt, dir, sn, o).map{|i| @lines[rt][i]}
  end

  # Find values from connection infos
  #
  # *Usage*:
  # +find(rt, :from|:to, sn)+ => both orientations of +sn+
  # +find(rt, :from|:to, sn, :+|:-)+ => only specified orientation
  #
  # *Note*:
  # The specified array should only be read, as it is often a
  # copy of the original; thus modifications must be done using
  # +add()+ or +delete()+
  def find(rt, dir, sn, o = nil)
    raise "RT invalid: #{rt.inspect}" if rt != "L" and rt != "C"
    raise "dir unknown: #{dir.inspect}" if dir != :from and dir != :to
    return find(rt,dir,sn,"+")+find(rt,dir,sn,"-") if o.nil?
    raise "o unknown: #{o.inspect}" if o != "+" and o != "-"
    @connect[rt][dir].fetch(sn,{}).fetch(o,[])
  end

  # Checks if all elements of connect refer to a link of containment
  # which was not deleted and whose from, to, from_orient, to_orient fields
  # have the expected values.
  #
  # Method useful for debugging.
  def validate!
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
