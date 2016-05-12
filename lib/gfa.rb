class GFA

  def initialize
    @lines = {}
    GFA::Line::RecordTypes.keys.each do |rt|
      @lines[rt] = []
    end
  end

  def <<(gfa_line)
    @lines[gfa_line.record_type] << gfa_line
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

end

require "./gfa/optfield.rb"
require "./gfa/line.rb"
