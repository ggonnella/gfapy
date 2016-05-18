require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAEdit < Test::Unit::TestCase

  def test_delete_connections
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*".to_gfa_line, "S\t1\t*".to_gfa_line, "S\t2\t*".to_gfa_line]
    l = "L\t1\t+\t2\t+\t12M".to_gfa_line
    c = "C\t1\t+\t0\t+\t12\t12M".to_gfa_line
    p = "P\t4\t2+,0-\t12M,12M".to_gfa_line
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal([l], gfa.links)
    assert_equal(l, gfa.link("1", "2"))
    gfa.delete_link!("1", "2", :from_orient => "+",:to_orient => "+")
    assert_equal([], gfa.links)
    assert_equal(nil, gfa.link("1", "2"))
    assert_equal([c], gfa.containments)
    assert_equal(c, gfa.containment("1", "0"))
    gfa.delete_containment!("1", "0", :from_orient => "+", :to_orient => "+",
                            :pos => "12")
    assert_equal([], gfa.containments)
    assert_equal(nil, gfa.containment("1", "0"))
    gfa << l
    assert_equal([l], gfa.links)
    gfa << c
    assert_equal([c], gfa.containments)
    gfa.unconnect_segments!("0", "1")
    gfa.unconnect_segments!("2", "1")
    assert_equal([], gfa.containments)
    assert_equal([], gfa.links)
  end

  def test_delete_segment
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*".to_gfa_line, "S\t1\t*".to_gfa_line, "S\t2\t*".to_gfa_line]
    l = "L\t1\t+\t2\t+\t12M".to_gfa_line
    c = "C\t1\t+\t0\t+\t12\t12M".to_gfa_line
    p = "P\t4\t2+,0-\t12M,12M".to_gfa_line
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments)
    assert_equal([l], gfa.links)
    assert_equal([c], gfa.containments)
    assert_equal([p], gfa.paths)
    gfa.delete_segment!("0")
    assert_equal([s[1],s[2]], gfa.segments)
    assert_equal([l], gfa.links)
    assert_equal([], gfa.containments)
    assert_equal([], gfa.paths)
    gfa.delete_segment!("1")
    assert_equal([s[2]], gfa.segments)
    assert_equal([], gfa.links)
  end

  def test_multiply_segment
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*\tRC:i:600".to_gfa_line,
         "S\t1\t*\tRC:i:6000".to_gfa_line,
         "S\t2\t*\tRC:i:60000".to_gfa_line]
    l = "L\t1\t+\t2\t+\t12M".to_gfa_line
    c = "C\t1\t+\t0\t+\t12\t12M".to_gfa_line
    p = "P\t4\t2+,0-\t12M,12M".to_gfa_line
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments)
    assert_equal([l], gfa.links)
    assert_equal([c], gfa.containments)
    assert_equal(l, gfa.link("1", "2"))
    assert_equal(c, gfa.containment("1", "0"))
    assert_equal(nil, gfa.link("5", "2"))
    assert_equal(nil, gfa.containment("5", "0"))
    assert_equal(6000, gfa.segment("1").RC)
    gfa.duplicate_segment!("1","5")
    assert_equal(l, gfa.link("1", "2"))
    assert_equal(c, gfa.containment("1", "0"))
    assert_not_equal(nil, gfa.link("5", "2"))
    assert_not_equal(nil, gfa.containment("5", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(3000, gfa.segment("5").RC)
    gfa.multiply_segment!("5",["6","7"])
    assert_equal(l, gfa.link("1", "2"))
    assert_not_equal(nil, gfa.link("5", "2"))
    assert_not_equal(nil, gfa.link("6", "2"))
    assert_not_equal(nil, gfa.link("7", "2"))
    assert_not_equal(nil, gfa.containment("5", "0"))
    assert_not_equal(nil, gfa.containment("6", "0"))
    assert_not_equal(nil, gfa.containment("7", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(1000, gfa.segment("5").RC)
    assert_equal(1000, gfa.segment("6").RC)
    assert_equal(1000, gfa.segment("7").RC)
  end

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
    assert_equal(nil, gfa.unbranched_segpath("0","3"))
    assert_raises(RuntimeError) { gfa.unbranched_segpath!("0","3") }
    assert_raises(RuntimeError) { gfa.merge_unbranched_segpath!("0","3") }
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
    assert_equal(["0","1","2","3"], gfa.unbranched_segpath("0","3"))
    assert_nothing_raised { gfa.unbranched_segpath!("0","3") }
    assert_nothing_raised { gfa.merge_unbranched_segpath!("0","3") }
    assert_raises(RuntimeError) {gfa.segment!("0")}
    assert_raises(RuntimeError) {gfa.segment!("1")}
    assert_raises(RuntimeError) {gfa.segment!("2")}
    assert_raises(RuntimeError) {gfa.segment!("3")}
    assert_nothing_raised {gfa.segment!("0_1_2_3")}
    assert_equal([], gfa.links)
    assert_equal("ACGACGACGTCGA", gfa.segment("0_1_2_3").sequence)
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
    assert_nothing_raised { gfa.merge_all_unbranched_segpaths! }
    assert_equal(1, gfa.segments.size)
    assert_equal("0_1_2_3", gfa.segments[0].name)
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
    assert_nothing_raised { gfa.merge_all_unbranched_segpaths! }
    assert_equal(4, gfa.segments.size)
    assert_equal(["0","1","2","3"], gfa.segments.map(&:name))
    assert_equal(l, gfa.links)
  end

end
