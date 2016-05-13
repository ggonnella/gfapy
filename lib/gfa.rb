class GFA

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = []
    @connect = Hash.new { Hash.new [] }
    #["L","C"].each do |rt|
    #  [:from,:to].each do |e|
    #    @connect[rt][e] = Hash.new { [] }
    #  end
    #end
    @paths_with = Hash.new { [] }
  end

  def <<(gfa_line)
    rt = gfa_line.record_type
    i = @lines[rt].size
    @lines[rt] << gfa_line
    case rt
    when "S"
      @segment_names << gfa_line.name
    when "L", "C"
      [:from,:to].each do |e|
        sn = gfa_line.send(e)
        validate_segment_name!(sn)
        @connect[rt][e][sn] << i
      end
    when "P"
      gfa_line.split_segment_names.each do |sn, o|
        validate_segment_name!(sn)
        @paths_with[sn] = i
      end
    end
  end

  def get_segment(segment_name)
    i = @segment_names.index?(segment_name)
    raise ArgumentError, "No segment has name #{segment_name}" if i.nil?
    @lines["S"][i]
  end

  def get_link(from, from_orient, to, to_orient)
    get_link_or_containment("L", from, from_orient, to, to_orient, nil)
  end

  def get_containment(from, from_orient, to, to_orient, pos)
    get_link_or_containment("C", from, from_orient, to, to_orient, pos)
  end

  def each(record_type)
    @lines[record_type].each do |line|
      next if line.nil?
      yield line
    end
  end

  def self.from_file(filename)
    gfa = GFA.new
    f = File.new(filename)
    f.each {|line| gfa << line.chomp.to_gfa_line}
    f.close
    return gfa
  end

  def to_s
    s = ""
    GFA::Line::RecordTypes.keys.each do |rt|
      @lines[rt].each do |line|
        next if line.nil?
        s << "#{line}\n"
      end
    end
    return s
  end

  def to_file(filename)
    f = File.new(filename, "w")
    f.puts self
    f.close
  end

  private

  def validate_segment_name!(sname)
    if !@segment_names.include?(sn)
      raise ArgumentError, "Link line refer to unknown segment '#{sn}'"
    end
  end

  def get_link_or_containment(rt, from, from_orient, to, to_orient, pos)
    @connect[rt][:from].each do |li|
      l = @lines[rt][li]
      if l.to == to and
         (to_orient.nil? or l.to_orient == to_orient) and
         (from_orient.nil? or l.from_orient == from_orient) and
         (pos.nil? or l.pos == pos)
        return l
      end
    end
  end

end

require_relative "./gfa_edit.rb"
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
