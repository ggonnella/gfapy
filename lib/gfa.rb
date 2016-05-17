class GFA

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = []
    @connect = {}
    ["L","C"].each {|rt| @connect[rt] = {:from => {}, :to => {}}}
    @paths_with = {}
    @path_names = []
  end

  def <<(gfa_line)
    gfa_line = gfa_line.to_gfa_line
    rt = gfa_line.record_type
    i = @lines[rt].size
    @lines[rt] << gfa_line
    case rt
    when "S"
      validate_segment_and_path_name_unique!(gfa_line.name)
      @segment_names << gfa_line.name
    when "L", "C"
      [:from,:to].each do |e|
        sn = gfa_line.send(e)
        validate_segment_name_exists!(sn)
        @connect[rt][e][sn] ||= []
        @connect[rt][e][sn] << i
      end
    when "P"
      validate_segment_and_path_name_unique!(gfa_line.path_name)
      @path_names << gfa_line.path_name
      gfa_line.segment_name.each do |sn, o|
        validate_segment_name_exists!(sn)
        @paths_with[sn] ||= []
        @paths_with[sn] << i
      end
    end
  end

  def get_segment(segment_name)
    i = @segment_names.index(segment_name)
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

  def lines(record_type)
    retval = []
    each(record_type) {|l| retval << l}
    return retval
  end

  def segments
    lines("S")
  end

  def links
    lines("L")
  end

  def paths
    lines("P")
  end

  def containments
    lines("C")
  end

  def headers
    lines("H")
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

  def validate_segment_and_path_name_unique!(sn)
    if @segment_names.include?(sn) or @path_names.include?(sn)
      raise ArgumentError, "Segment or path name not unique '#{sn}'"
    end
  end

  def validate_segment_name_exists!(sn)
    if !@segment_names.include?(sn)
      raise ArgumentError, "Link line refer to unknown segment '#{sn}'"
    end
  end

  def get_link_or_containment(rt, from, from_orient, to, to_orient, pos)
    @connect[rt][:from].fetch(from,[]).each do |li|
      l = @lines[rt][li]
      if (l.to == to) and
         (to_orient.nil? or (l.to_orient == to_orient)) and
         (from_orient.nil? or (l.from_orient == from_orient)) and
         (pos.nil? or (l.pos(false) == pos.to_s))
        return l
      end
    end
    return nil
  end

end

require_relative "./gfa_edit.rb"
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
