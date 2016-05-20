require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFA < Test::Unit::TestCase

  def test_add_headers
    gfa = GFA.new
    assert(gfa)
    h = "H\tVN:Z:1.0".to_gfa_line
    assert_nothing_raised { gfa << h }
    assert_equal([h], gfa.headers)
  end

  def test_add_segments
    gfa = GFA.new
    s1 = "S\t1\t*".to_gfa_line
    s2 = "S\t2\t*".to_gfa_line
    assert_nothing_raised { gfa << s1 }
    assert_nothing_raised { gfa << s2 }
    assert_equal([s1, s2], gfa.segments)
    assert_equal(s1, gfa.segment("1"))
    assert_equal(nil, gfa.segment("0"))
    assert_nothing_raised { gfa.segment!("1") }
    assert_raises(RuntimeError) { gfa.segment!("0") }
    assert_raises(ArgumentError) { gfa << s2 }
  end

  def test_add_links
    gfa = GFA.new
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    l1 = "L\t1\t+\t2\t+\t12M".to_gfa_line
    assert_nothing_raised { gfa << l1 }
    assert_equal([l1], gfa.links)
    assert_equal(l1, gfa.link("1", nil, "2", nil))
    assert_equal(nil, gfa.link("2", :E, "1", :B))
    assert_nothing_raised {gfa.link!("1", nil, "2", nil)}
    assert_raises(RuntimeError) {gfa.link!("2", :E, "1", :B)}
    l2 = "L\t1\t+\t3\t+\t12M"
    assert_raises(ArgumentError) { gfa << l2 }
  end

  def test_add_containments
    gfa = GFA.new
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    c1 = "C\t1\t+\t2\t+\t12\t12M".to_gfa_line
    assert_nothing_raised { gfa << c1 }
    assert_equal([c1], gfa.containments)
    assert_equal(c1, gfa.containment("1", "2"))
    assert_nothing_raised {gfa.containment!("1",  "2")}
    assert_raises(RuntimeError) {gfa.containment!("2", "1")}
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    assert_raises(ArgumentError) { gfa << c2 }
  end

  def test_add_paths
    gfa = GFA.new
    gfa << "S\t1\t*"
    gfa << "S\t2\t*"
    p1 = "P\t4\t1+,2+\t122M,120M".to_gfa_line
    assert_nothing_raised { gfa << p1 }
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

  def test_links_of_segment_end
    gfa = GFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t*".to_gfa_line; gfa << l0
    l1 = "L\t0\t+\t1\t+\t*".to_gfa_line; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*".to_gfa_line; gfa << l2
    assert_equal([],         gfa.links_of("0", :B))
    assert_equal([l1],       gfa.links_of("0", :E))
    assert_equal([l1],       gfa.links_of("0", nil))
    assert_equal([l1],       gfa.links_of("1", :B))
    assert_equal([l0,l2],    gfa.links_of("1", :E))
    assert_equal([l1,l0,l2], gfa.links_of("1", nil))
    assert_equal([l0],       gfa.links_of("2", :B))
    assert_equal([],         gfa.links_of("2", :E))
    assert_equal([l0],       gfa.links_of("2", nil))
    assert_equal([l2],       gfa.links_of("3", :B))
    assert_equal([],         gfa.links_of("3", :E))
    assert_equal([l2],       gfa.links_of("3", nil))
    gfa = GFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t-\t*".to_gfa_line; gfa << l0
    l1 = "L\t0\t+\t1\t-\t*".to_gfa_line; gfa << l1
    l2 = "L\t1\t-\t3\t+\t*".to_gfa_line; gfa << l2
    assert_equal([],         gfa.links_of("0", :B))
    assert_equal([l1],       gfa.links_of("0", :E))
    assert_equal([l1],       gfa.links_of("0", nil))
    assert_equal([l2],       gfa.links_of("1", :B))
    assert_equal([l0,l1],    gfa.links_of("1", :E))
    assert_equal([l2,l0,l1], gfa.links_of("1", nil))
    assert_equal([],         gfa.links_of("2", :B))
    assert_equal([l0],       gfa.links_of("2", :E))
    assert_equal([l0],       gfa.links_of("2", nil))
    assert_equal([l2],       gfa.links_of("3", :B))
    assert_equal([],         gfa.links_of("3", :E))
    assert_equal([l2],       gfa.links_of("3", nil))
  end

  def test_containing_and_contained
    gfa = GFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    gfa << c
    assert_equal([c], gfa.containing("0"))
    assert_equal([],  gfa.containing("1"))
    assert_equal([],  gfa.containing("2"))
    assert_equal([],  gfa.contained_in("0"))
    assert_equal([c], gfa.contained_in("1"))
    assert_equal([],  gfa.contained_in("2"))
  end

  def test_paths_with_segment
    gfa = GFA.new
    s = (0..3).map{|i| "S\t#{i}\t*".to_gfa_line}
    p = "P\t4\t2+,0-\t*".to_gfa_line
    (s + [p]).each {|line| gfa << line }
    assert_equal([p], gfa.paths_with("0"))
    assert_equal([p], gfa.paths_with("2"))
    assert_equal([], gfa.paths_with("1"))
  end

end
