require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineDestructors < Test::Unit::TestCase

  def test_delete_headers
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    assert_equal(["H\tVN:Z:1.0"], gfa.headers.map(&:to_s))
    gfa.delete_headers
    assert_equal([], gfa.headers)
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    gfa.rm(:headers)
    assert_equal([], gfa.headers)
  end

  def test_delete_links
    gfa = RGFA.new
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    (s + [l,c]).each {|line| gfa << line }
    assert_equal([l], gfa.links.map(&:to_s))
    assert_equal(l, gfa.link(["1", :E], ["2", :B]).to_s)
    gfa.delete_link(gfa.link_from_to(["1", "+"], ["2", "+"]))
    assert_equal([], gfa.links)
    assert_equal(nil, gfa.link(["1", :E], ["2", :B]))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal(c, gfa.containment("1", "0").to_s)
    gfa << l
    assert_not_equal([], gfa.links)
    gfa.rm(gfa.link_from_to(["1","+"],["2","+"]))
    assert_equal([], gfa.links)
  end

  def test_delete_containments
    gfa = RGFA.new
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    (s + [l,c]).each {|line| gfa << line }
    gfa.delete_containment(gfa.containment("1", "0"))
    assert_equal([], gfa.containments)
    assert_equal(nil, gfa.containment("1", "0"))
    gfa << c
    assert_not_equal([], gfa.containments)
    assert_equal(c, gfa.containment("1", "0").to_s)
    gfa.rm(gfa.containment("1", "0"))
    assert_equal([], gfa.containments)
  end

  def test_unconnect_segments
    gfa = RGFA.new
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    (s + [l,c]).each {|line| gfa << line }
    gfa.unconnect_segments("0", "1")
    gfa.unconnect_segments("2", "1")
    assert_equal([], gfa.containments)
    assert_equal([], gfa.links)
  end

  def test_delete_segment
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    p = "P\t4\t2+,0-\t12M"
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal(s, gfa.segments.map(&:to_s))
    assert_equal([:"0", :"1", :"2"], gfa.segment_names)
    assert_equal([l], gfa.links.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal([p], gfa.paths.map(&:to_s))
    assert_equal([:"4"], gfa.path_names)
    gfa.delete_segment("0")
    assert_equal([s[1],s[2]], gfa.segments.map(&:to_s))
    assert_equal([:"1", :"2"], gfa.segment_names)
    assert_equal([l], gfa.links.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([], gfa.containments.map(&:to_s))
    assert_equal([], gfa.paths.map(&:to_s))
    assert_equal([], gfa.path_names)
    gfa.delete_segment("1")
    assert_equal([s[2]], gfa.segments.map(&:to_s))
    assert_equal([], gfa.links)
    gfa.rm("2")
    assert_equal([], gfa.segments)
  end

end
