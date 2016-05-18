GFA = Class.new
require_relative "./gfa/optfield.rb"
require_relative "./gfa/line.rb"
require_relative "./gfa/edit.rb"
require_relative "./gfa/cigar.rb"
require_relative "./gfa/sequence.rb"

class GFA

  include GFA::Edit

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each {|rt| @lines[rt] = []}
    @segment_names = []
    @connect = {}
    ["L","C"].each {|rt| @connect[rt] = {:from => {}, :to => {}}}
    @paths_with = {}
    @path_names = []
  end

  def segment(segment_name)
    i = @segment_names.index(segment_name)
    i.nil? ? nil : @lines["S"][i]
  end

  def unbranched_segpath(from, to)
    segpath = [from]
    last_orient = nil
    while segpath.last != to
      from_list = links_from(segpath.last)
      return nil if from_list.size != 1
      if !last_orient.nil? and from_list[0].from_orient != last_orient
        return nil
      end
      last_orient = from_list[0].to_orient
      segpath << from_list[0].to
    end
    return segpath
  end

  def segment!(segment_name)
    s = segment(segment_name)
    raise "No segment has name #{segment_name}" if s.nil?
    s
  end

  def path(path_name)
    i = @path_names.index(path_name)
    i.nil? ? nil : @lines["P"][i]
  end

  def path!(path_name)
    pt = path(path_name)
    raise "No path has name #{path_name}" if pt.nil?
    pt
  end

  def link(from, from_orient, to, to_orient)
    link_or_containment("L", from, from_orient, to, to_orient, nil)
  end

  def link!(from, from_orient, to, to_orient)
    l = link(from, from_orient, to, to_orient)
    raise "No link found" if l.nil?
    l
  end

  def containment(from, from_orient, to, to_orient, pos)
    link_or_containment("C", from, from_orient, to, to_orient, pos)
  end

  def containment!(from, from_orient, to, to_orient, pos)
    c = containment(from, from_orient, to, to_orient, pos)
    raise "No containment found" if c.nil?
    c
  end

  ["links", "containments"].each do |c|
    [:from, :to].each do |d|
      define_method(:"#{c}_#{d}") do |segment_name|
        links_or_containments_for_segment(c[0].upcase, d, segment_name)
      end
    end
  end

  def paths_with(segment_name)
    @paths_with.fetch(segment_name,[]).map{|i|@lines["P"][i]}
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

  GFA::Line::RecordTypes.each do |rt, klass|
    klass =~ /GFA::Line::(.*)/
    define_method(:"#{$1.downcase}s") { lines(rt) }
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

  def to_gfa
    self
  end

  def self.from_file(filename)
    gfa = GFA.new
    File.foreach(filename) {|line| gfa << line.chomp}
    return gfa
  end

  def to_file(filename)
    File.open(filename, "w") {|f| f.puts self}
  end

  private

  def link_or_containment(rt, from, from_orient, to, to_orient, pos)
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

  def links_or_containments_for_segment(rt, direction, segment_name)
    @connect[rt][direction].fetch(segment_name,[]).map{|i|@lines[rt][i]}
  end

end

class String

  def to_gfa
    gfa = GFA.new
    split("\n").each {|line| gfa << line}
    return gfa
  end

end

