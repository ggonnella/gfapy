require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFATraverse < Test::Unit::TestCase

  def test_linear_path_merging
    s = ["S\t0\tACGA",
         "S\t1\tACGA",
         "S\t2\tACGA",
         "S\t3\tACGA"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t+\t3\t+\t1M"]
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_raises(RGFA::ValueError) do
      gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]])
    end
    s = ["S\t0\tACGA",
         "S\t1\tACGA",
         "S\t2\tACGT",
         "S\t3\tTCGA"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"]
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised do
      gfa.merge_linear_path([["0", :R],["1", :R],["2", :L],["3", :R]])
    end
    assert_raises(RGFA::NotFoundError) {gfa.segment!("0")}
    assert_raises(RGFA::NotFoundError) {gfa.segment!("1")}
    assert_raises(RGFA::NotFoundError) {gfa.segment!("2")}
    assert_raises(RGFA::NotFoundError) {gfa.segment!("3")}
    assert_nothing_raised {gfa.segment!("0_1_2_3")}
    assert_equal([], gfa.links)
    assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2_3").sequence)
  end

  def test_linear_path_merge_all
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"]
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    gfa.merge_linear_paths
    assert_nothing_raised { gfa.merge_linear_paths }
    assert_equal([:"0_1_2_3"], gfa.segment_names)
    assert_equal(1, gfa.segments.size)
    assert_equal([], gfa.links)
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t0\t+\t2\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"].map(&:to_rgfa_line)
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised { gfa.merge_linear_paths }
    assert_equal(3, gfa.segments.size)
    assert_equal([:"0",:"3",:"1_2"], gfa.segments.map(&:name))
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t0\t+\t2\t+\t1M",
         "L\t1\t+\t2\t+\t1M",
         "L\t2\t+\t3\t+\t1M"].map(&:to_rgfa_line)
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised { gfa.merge_linear_paths }
    assert_equal(3, gfa.segments.size)
    assert_equal([:"0", :"1", :"2_3"], gfa.segments.map(&:name))
  end

  def test_linear_path_merge_example1
    gfa = RGFA.from_file("test/testdata/example1.gfa")
    assert_equal([%w[18 19 1],
                  %w[11 9 12],
                  %w[22 16 20 21 23]],
                 gfa.linear_paths.map{|sp|sp.map{|sn,et|sn.to_sym.to_s}})
  end

end
