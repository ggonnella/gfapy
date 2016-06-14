require_relative "../lib/gfa.rb"
require "test/unit"
require "tempfile"

class TestGFA < Test::Unit::TestCase

  def test_initialize
    assert_nothing_raised { GFA.new }
    gfa = GFA.new
    assert_equal(GFA, gfa.class)
  end

  def test_segment_names
    gfa = GFA.new
    assert_equal([], gfa.segment_names)
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    assert_equal(["1", "2"], gfa.segment_names)
    gfa.delete_segment("1")
    assert_equal(["2"], gfa.segment_names)
  end

  def test_path_names
    gfa = GFA.new
    assert_equal([], gfa.path_names)
    gfa << "P\t3\t1+,4-\t*"
    assert_equal(["3"], gfa.path_names)
    gfa.delete_path("3")
    assert_equal([], gfa.path_names)
  end

  def test_validate!
    gfa = GFA.new
    gfa << "S\t1\t*"
    assert_nothing_raised { gfa.validate! }
    gfa << "L\t1\t+\t2\t-\t*"
    assert_raise(GFA::LineMissingError) { gfa.validate! }
    gfa << "S\t2\t*"
    assert_nothing_raised { gfa.validate! }
    gfa << "P\t3\t1+,4-\t*"
    assert_raise(GFA::LineMissingError) { gfa.validate! }
    gfa << "S\t4\t*"
    assert_nothing_raised { gfa.validate! }
  end

  def test_to_s
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa = GFA.new
    lines.each {|l| gfa << l}
    assert_equal(lines.join("\n")+"\n", gfa.to_s)
  end

  def test_to_gfa
    gfa = GFA.new
    gfa2 = gfa.to_gfa
    assert(gfa2)
    assert_equal(GFA, gfa2.class)
  end

  def test_from_file
    filename = "test/testdata/example1.gfa"
    gfa = GFA.from_file(filename)
    assert(gfa)
    assert_equal(IO.read(filename), gfa.to_s)
  end

  def test_to_file
    filename = "test/testdata/example1.gfa"
    gfa = GFA.from_file(filename)
    tmp = Tempfile.new("example1")
    gfa.to_file(tmp.path)
    tmp.rewind
    assert_equal(IO.read(filename), IO.read(tmp))
  end

  def test_string_to_gfa
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = GFA.new
    lines.each {|l| gfa1 << l}
    gfa2 = lines.join("\n").to_gfa
    assert(gfa2)
    assert_equal(GFA, gfa2.class)
    assert_equal(gfa1.to_s, gfa2.to_s)
  end

  def test_array_to_gfa
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = GFA.new
    lines.each {|l| gfa1 << l}
    gfa2 = lines.to_gfa
    assert(gfa2)
    assert_equal(GFA, gfa2.class)
    assert_equal(gfa1.to_s, gfa2.to_s)
  end

end
