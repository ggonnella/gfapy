require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFATraverse < Test::Unit::TestCase

  def test_unbranched_path_merging
    s = ["S\t0\tACGA",
         "S\t1\tACGA",
         "S\t2\tACGA",
         "S\t3\tACGA"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t+\t3\t+\t1M"]
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_raises(RuntimeError) do
      gfa.merge_unbranched_segpath([["0", :E],["1", :E],["2", :B],["3", :E]])
    end
    s = ["S\t0\tACGA",
         "S\t1\tACGA",
         "S\t2\tACGT",
         "S\t3\tTCGA"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"]
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised do
      gfa.merge_unbranched_segpath([["0", :E],["1", :E],["2", :B],["3", :E]])
    end
    assert_raises(RuntimeError) {gfa.segment!("0")}
    assert_raises(RuntimeError) {gfa.segment!("1")}
    assert_raises(RuntimeError) {gfa.segment!("2")}
    assert_raises(RuntimeError) {gfa.segment!("3")}
    assert_nothing_raised {gfa.segment!("0_1_2^_3")}
    assert_equal([], gfa.links)
    assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
  end

  def test_unbranched_path_merge_all
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"]
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    gfa.merge_all_unbranched_segpaths
    assert_nothing_raised { gfa.merge_all_unbranched_segpaths }
    assert_equal(["0_1_2^_3"], gfa.segment_names)
    assert_equal(1, gfa.segments.size)
    assert_equal([], gfa.links)
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t0\t+\t2\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"].map(&:to_gfa_line)
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised { gfa.merge_all_unbranched_segpaths }
    assert_equal(3, gfa.segments.size)
    assert_equal(["0","3","1_2^"], gfa.segments.map(&:name))
    s = ["S\t0\t*",
         "S\t1\t*",
         "S\t2\t*",
         "S\t3\t*"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t0\t+\t2\t+\t1M",
         "L\t1\t+\t2\t+\t1M",
         "L\t2\t+\t3\t+\t1M"].map(&:to_gfa_line)
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    (s + l).each {|line| gfa << line }
    assert_nothing_raised { gfa.merge_all_unbranched_segpaths }
    assert_equal(4, gfa.segments.size)
    assert_equal(["0", "1", "2", "3"], gfa.segments.map(&:name))
  end

  def test_unbranched_path_merge_example1
    gfa = GFA.from_file("test/testdata/example1.gfa")
    assert_equal([%w[18 19 1],
                  %w[11 9 12],
                  %w[22 16 20 21 23]],
                 gfa.unbranched_segpaths.map{|sp|sp.map{|sn,et|sn}})
  end

end
