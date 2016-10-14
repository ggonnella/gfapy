require_relative "../lib/rgfa.rb"
require "test/unit"
require "tempfile"

class TestRGFA < Test::Unit::TestCase

  def test_initialize
    assert_nothing_raised { RGFA.new }
    gfa = RGFA.new
    assert_equal(RGFA, gfa.class)
  end

  def test_version_empty
    gfa = RGFA.new
    assert_equal(nil, gfa.version)
    gfa = RGFA.new(version: :"1.0")
    assert_equal(:"1.0", gfa.version)
    gfa = RGFA.new(version: :"2.0")
    assert_equal(:"2.0", gfa.version)
    assert_raises(RGFA::VersionError) { RGFA.new(version: :"0.0") }
  end

  def test_segment_names
    gfa = RGFA.new
    assert_equal([], gfa.segment_names)
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    assert_equal([:"1", :"2"], gfa.segment_names)
    gfa.delete_segment("1")
    assert_equal([:"2"], gfa.segment_names)
  end

  def test_path_names
    gfa = RGFA.new(version: :"1.0")
    assert_equal([], gfa.path_names)
    gfa << "P\t3\t1+,4-\t*"
    assert_equal([:"3"], gfa.path_names)
    gfa.delete_path("3")
    assert_equal([], gfa.path_names)
  end

  def test_validate!
    gfa = RGFA.new(version: :"1.0")
    gfa << "S\t1\t*"
    assert_nothing_raised { gfa.validate! }
    gfa << "L\t1\t+\t2\t-\t*"
    assert_raise(RGFA::LineMissingError) { gfa.validate! }
    gfa << "S\t2\t*"
    assert_nothing_raised { gfa.validate! }
    gfa << "P\t3\t1+,4-\t*"
    assert_raise(RGFA::LineMissingError) { gfa.validate! }
    gfa << "S\t4\t*"
    assert_raise(RGFA::LineMissingError) { gfa.validate! }
    gfa << "L\t4\t+\t1\t-\t*"
    assert_nothing_raised { gfa.validate! }
  end

  def test_to_s
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa = RGFA.new
    lines.each {|l| gfa << l}
    assert_equal(lines.join("\n")+"\n", gfa.to_s)
  end

  def test_to_rgfa
    gfa = RGFA.new
    gfa2 = gfa.to_rgfa
    assert(gfa2)
    assert_equal(RGFA, gfa2.class)
  end

  def test_from_file
    filename = "test/testdata/example1.gfa"
    gfa = RGFA.from_file(filename)
    assert(gfa)
    assert_equal(IO.read(filename), gfa.to_s)
  end

  def test_to_file
    filename = "test/testdata/example1.gfa"
    gfa = RGFA.from_file(filename)
    tmp = Tempfile.new("example1")
    gfa.to_file(tmp.path)
    tmp.rewind
    assert_equal(IO.read(filename), IO.read(tmp))
  end

  def test_string_to_rgfa
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = RGFA.new
    lines.each {|l| gfa1 << l}
    gfa2 = lines.join("\n").to_rgfa
    assert(gfa2)
    assert_equal(RGFA, gfa2.class)
    assert_equal(gfa1.to_s, gfa2.to_s)
  end

  def test_array_to_rgfa
    lines = ["H\tVN:Z:1.0","S\t1\t*","S\t2\t*","S\t3\t*",
     "L\t1\t+\t2\t-\t*","C\t1\t+\t3\t-\t12\t*","P\t4\t1+,2-\t*"]
    gfa1 = RGFA.new
    lines.each {|l| gfa1 << l}
    gfa2 = lines.to_rgfa
    assert(gfa2)
    assert_equal(RGFA, gfa2.class)
    assert_equal(gfa1.to_s, gfa2.to_s)
  end

end
