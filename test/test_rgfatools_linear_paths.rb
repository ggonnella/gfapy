require_relative "../lib/rgfatools.rb"
require "test/unit"

class TestRGFAToolsLinearPaths < Test::Unit::TestCase

  def test_linear_path_merging
    s = ["S\t0\tACGA",
         "S\t1\tACGA",
         "S\t2\tACGA",
         "S\t3\tACGA"]
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"]
    gfa = RGFA.new
    (s + l).each {|line| gfa << line }
    gfa.merge_linear_path([["0", :E],["1", :E],["2", :B],["3", :E]],
                          enable_tracking: true)
    assert_nothing_raised {gfa.segment!("0_1_2^_3")}
    assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
    gfa = RGFA.new
    gfa.enable_extensions
    (s + l).each {|line| gfa << line }
    gfa.merge_linear_path([["0", :E],["1", :E],["2", :B],["3", :E]])
    assert_nothing_raised {gfa.segment!("0_1_2^_3")}
    assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2^_3").sequence)
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
    gfa.enable_extensions
    (s + l).each {|line| gfa << line }
    gfa.merge_linear_paths
    assert_equal([:"0_1_2^_3"], gfa.segment_names)
    l = ["L\t0\t+\t1\t+\t1M",
         "L\t0\t+\t2\t+\t1M",
         "L\t1\t+\t2\t-\t1M",
         "L\t2\t-\t3\t+\t1M"].map(&:to_rgfa_line)
    gfa = RGFA.new
    gfa.enable_extensions
    (s + l).each {|line| gfa << line }
    gfa.merge_linear_paths
    assert_equal([:"0",:"3",:"1_2^"], gfa.segments.map(&:name))
  end

end
