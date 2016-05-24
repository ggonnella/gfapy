require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALineGetters < Test::Unit::TestCase

  def test_headers
    h = ["H\tVN:Z:1.0"]
    assert_equal(h, h.to_gfa.headers.map(&:to_s))
  end

  def test_each_header
    h1 = ["H\tVN:Z:1.0"]
    h2 = []
    gfa = h1.to_gfa
    gfa.each_header {|h| h2 << h.to_s}
    assert_equal(h1, h2)
  end

  def test_segments
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_gfa
    assert_equal(s, gfa.segments.map(&:to_s))
    gfa.delete_segment("1")
    assert_equal([s[1]], gfa.segments.map(&:to_s))
  end

  def test_each_segment
    s1 = ["S\t1\t*","S\t2\t*"]
    s2 = []
    gfa = s1.to_gfa
    gfa.each_segment {|s| s2 << s.to_s}
    assert_equal(s1, s2)
    gfa.delete_segment("1")
    s2 = []
    gfa.each_segment {|s| s2 << s.to_s}
    assert_equal([s1[1]], s2)
  end

  def test_links
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t12M", "L\t1\t+\t3\t+\t12M"]
    gfa = (s+l).to_gfa
    assert_equal(l, gfa.links.map(&:to_s))
    gfa.unconnect_segments("1","2")
    assert_equal([l[1]], gfa.links.map(&:to_s))
  end

  def test_each_link
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l1 = ["L\t1\t+\t2\t+\t12M", "L\t1\t+\t3\t+\t12M"]
    gfa = (s+l1).to_gfa
    l2 = []
    gfa.each_link {|l| l2 << l.to_s}
    assert_equal(l1, l2)
    gfa.unconnect_segments("1","2")
    l2 = []
    gfa.each_link {|l| l2 << l.to_s}
    assert_equal([l1[1]],l2)
  end

  def test_containments
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    c = ["C\t1\t+\t2\t+\t12\t12M", "C\t1\t+\t3\t+\t12\t12M"]
    gfa = (s+c).to_gfa
    assert_equal(c, gfa.containments.map(&:to_s))
    gfa.unconnect_segments("1","2")
    assert_equal([c[1]], gfa.containments.map(&:to_s))
  end

  def test_each_containment
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    c1 = ["C\t1\t+\t2\t+\t12\t12M", "C\t1\t+\t3\t+\t12\t12M"]
    gfa = (s+c1).to_gfa
    c2 = []
    gfa.each_containment {|c| c2 << c.to_s}
    assert_equal(c1, c2)
    gfa.unconnect_segments("1","2")
    c2 = []
    gfa.each_containment {|c| c2 << c.to_s}
    assert_equal([c1[1]], c2)
  end

  def test_paths
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    pt = ["P\t4\t1+,2+\t122M,120M", "P\t5\t1+,3+\t122M,120M"]
    gfa = (s+pt).to_gfa
    assert_equal(pt, gfa.paths.map(&:to_s))
    gfa.delete_path("4")
    assert_equal([pt[1]], gfa.paths.map(&:to_s))
  end

  def test_each_path
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    pt1 = ["P\t4\t1+,2+\t122M,120M", "P\t5\t1+,3+\t122M,120M"]
    gfa = (s+pt1).to_gfa
    pt2 = []
    gfa.each_path {|pt| pt2 << pt.to_s}
    assert_equal(pt1, pt2)
    gfa.delete_path("4")
    pt2 = []
    gfa.each_path {|pt| pt2 << pt.to_s}
    assert_equal([pt1[1]], pt2)
  end

  def test_segment
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_gfa
    assert_equal(s[0],gfa.segment("1").to_s)
    assert_equal(s[0],gfa.segment!("1").to_s)
    assert_equal(nil,gfa.segment("0"))
    assert_raises(RuntimeError) {gfa.segment!("0").to_s}
  end

  def test_path
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    pt = ["P\t4\t1+,2+\t122M,120M", "P\t5\t1+,3+\t122M,120M"]
    gfa = (s+pt).to_gfa
    assert_equal(pt[0],gfa.path("4").to_s)
    assert_equal(pt[0],gfa.path!("4").to_s)
    assert_equal(nil,gfa.path("6"))
    assert_raises(RuntimeError) {gfa.path!("6").to_s}
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

  def test_containing
    gfa = GFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    gfa << c
    assert_equal([c], gfa.containing("0"))
    assert_equal([],  gfa.containing("1"))
    assert_equal([],  gfa.containing("2"))
  end

  def test_contained_in
    gfa = GFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    gfa << c
    assert_equal([],  gfa.contained_in("0"))
    assert_equal([c], gfa.contained_in("1"))
    assert_equal([],  gfa.contained_in("2"))
  end

  def test_containments_between
    gfa = GFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    c2 = "C\t1\t+\t0\t+\t12\t*".to_gfa_line
    gfa << c1
    gfa << c2
    assert_equal([], gfa.containments_between("0", "1"))
    assert_equal([c1,c2], gfa.containments_between("1", "0"))
  end

  def test_containment
    gfa = GFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*".to_gfa_line
    c2 = "C\t1\t+\t0\t+\t12\t*".to_gfa_line
    gfa << c1
    gfa << c2
    assert_equal(nil, gfa.containment("0", "1"))
    assert_raises(RuntimeError) {gfa.containment!("0", "1")}
    assert_equal(c1, gfa.containment("1", "0"))
    assert_equal(c1, gfa.containment!("1", "0"))
  end

  def test_links_of
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

  def test_links_between
    gfa = GFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t11M1D3M".to_gfa_line; gfa << l0
    l1 = "L\t1\t+\t2\t+\t10M2D3M".to_gfa_line; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*".to_gfa_line; gfa << l2
    assert_equal([l0, l1], gfa.links_between("1", :E, "2", :B))
    assert_equal([l0, l1], gfa.links_between("1", nil, "2", nil))
    assert_equal([], gfa.links_between("1", nil, "2", :E))
  end

  def test_link
    gfa = GFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t11M1D3M".to_gfa_line; gfa << l0
    l1 = "L\t1\t+\t2\t+\t10M2D3M".to_gfa_line; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*".to_gfa_line; gfa << l2
    assert_equal(l0, gfa.link("1", nil, "2", nil))
    assert_equal(l0, gfa.link!("1", nil, "2", nil))
    assert_equal(l0, gfa.link("1", :E, "2", :B))
    assert_equal(l0, gfa.link!("1", :E, "2", :B))
    assert_equal(nil, gfa.link("1", :E, "2", :E))
    assert_raise(RuntimeError) { gfa.link!("1", :E, "2", :E) }
  end

end
