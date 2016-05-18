require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFA < Test::Unit::TestCase

  def test_basic_functionality
    gfa = GFA.new
    assert(gfa)
    h = "H\tVN:Z:1.0".to_gfa_line
    assert_nothing_raised { gfa << h }
    assert_equal([h], gfa.lines("H"))
    assert_equal([h], gfa.headers)
    assert_equal([], gfa.lines("S"))
  end

  def test_add_segments
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s1 = "S\t1\t*".to_gfa_line
    s2 = "S\t2\t*".to_gfa_line
    assert_nothing_raised { gfa << s1 }
    assert_nothing_raised { gfa << s2 }
    assert_equal([s1, s2], gfa.lines("S"))
    assert_equal([s1, s2], gfa.segments)
    assert_equal(s1, gfa.segment("1"))
    assert_equal(nil, gfa.segment("0"))
    assert_nothing_raised { gfa.segment!("1") }
    assert_raises(RuntimeError) { gfa.segment!("0") }
    assert_raises(ArgumentError) { gfa << s2 }
  end

  def test_add_links
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    l1 = "L\t1\t+\t2\t+\t12M".to_gfa_line
    assert_nothing_raised { gfa << l1 }
    assert_equal([l1], gfa.lines("L"))
    assert_equal([l1], gfa.links)
    assert_equal(l1, gfa.link("1", "2", :from_orient => "+", :to_orient => "+"))
    assert_equal(l1, gfa.link("1", "2"))
    assert_equal(nil, gfa.link("1", "2", :from_orient => "-"))
    assert_nothing_raised {gfa.link!("1", "2")}
    assert_raises(RuntimeError) {gfa.link!("1", "2", :from_orient => "-")}
    l2 = "L\t1\t+\t3\t+\t12M"
    assert_raises(ArgumentError) { gfa << l2 }
  end

  def test_add_containments
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    c1 = "C\t1\t+\t2\t+\t12\t12M".to_gfa_line
    assert_nothing_raised { gfa << c1 }
    assert_equal([c1], gfa.lines("C"))
    assert_equal([c1], gfa.containments)
    assert_equal(c1, gfa.containment("1", "2", :from_orient => "+",
                                     :to_orient => "+", :pos => "12"))
    assert_equal(c1, gfa.containment("1", "2"))
    assert_equal(nil, gfa.containment("1", "2", :from_orient => "+",
                                     :to_orient => "+", :pos => "10"))
    assert_nothing_raised {gfa.containment!("1",  "2")}
    assert_raises(RuntimeError) {gfa.containment!("1", "2", :from_orient => "+",
                                     :to_orient => "+", :pos => "10")}
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    assert_raises(ArgumentError) { gfa << c2 }
  end

  def test_add_paths
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    p1 = "P\t4\t1+,2+\t122M,120M".to_gfa_line
    assert_nothing_raised { gfa << p1 }
    assert_equal([p1], gfa.lines("P"))
    assert_equal([p1], gfa.paths)
    assert_equal(p1, gfa.path("4"))
    assert_equal(nil, gfa.path("5"))
    assert_nothing_raised {gfa.path!("4")}
    assert_raises(RuntimeError) {gfa.path!("5")}
    p2 = "P\t1\t1+,2+\t122M,120M"
    p3 = "P\t5\t1+,3+\t122M,120M"
    assert_raises(ArgumentError) { gfa << p2 }
    assert_raises(ArgumentError) { gfa << p3 }
  end

  def test_links_containments_from_to_segment
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = (0..3).map{|i| "S\t#{i}\t*".to_gfa_line}
    l = [[1,2],[0,1],[1,3]].map {|a,b| "L\t#{a}\t+\t#{b}\t+\t*".to_gfa_line}
    c = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    p = "P\t4\t2+,0-\t*".to_gfa_line
    (s + l + [c,p]).each {|line| gfa << line }
    assert_equal([l[0],l[2]], gfa.links_from("1"))
    assert_equal([], gfa.links_from("3"))
    assert_equal([l[1]], gfa.links_to("1"))
    assert_equal([], gfa.links_to("0"))
    assert_equal([c], gfa.containments_from("1"))
    assert_equal([], gfa.containments_from("2"))
    assert_equal([], gfa.containments_from("0"))
    assert_equal([c], gfa.containments_to("0"))
  end

  def test_paths_with_segment
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = (0..3).map{|i| "S\t#{i}\t*".to_gfa_line}
    p = "P\t4\t2+,0-\t*".to_gfa_line
    (s + [p]).each {|line| gfa << line }
    assert_equal([p], gfa.paths_with("0"))
    assert_equal([p], gfa.paths_with("2"))
    assert_equal([], gfa.paths_with("1"))
  end

end
