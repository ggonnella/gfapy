require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
TestAPI::Lines ||= Module.new
class TestAPI::Lines::Destructors < Test::Unit::TestCase

  def test_delete_links
    gfa = RGFA.new
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    (s + [l,c]).each {|line| gfa << line }
    assert_equal([l], gfa.links.map(&:to_s))
    assert_equal([l],
                 gfa.segment(:"1").end_relations(:R, [:"2", :L]).map(&:to_s))
    gfa.segment(:"1").oriented_relations(:+, OL[:"2", :+]).map(&:disconnect)
    assert_equal([], gfa.links)
    assert_equal([], gfa.segment(:"1").end_relations(:R, [:"2", :L]))
    assert_equal([c], gfa.containments.map(&:to_s))
    assert_equal(c,
                 gfa.segment(:"1").relations_to(gfa.segment(:"0"),
                                    :edges_to_contained)[0].to_s)
    gfa << l
    assert_not_equal([], gfa.links)
    gfa.segment(:"1").oriented_relations(:+, OL[:"2", :+]).map(&:disconnect)
    assert_equal([], gfa.links)
  end

  def test_delete_containments
    gfa = RGFA.new
    s = ["S\t0\t*", "S\t1\t*", "S\t2\t*"]
    l = "L\t1\t+\t2\t+\t12M"
    c = "C\t1\t+\t0\t+\t12\t12M"
    (s + [l,c]).each {|line| gfa << line }
    gfa.segment(:"1").relations_to(gfa.segment(:"0"), :edges_to_contained).
                                   each(&:disconnect)
    assert_equal([], gfa.containments)
    assert_equal(nil, gfa.segment(:"1").relations_to(:"0",
                                                     :edges_to_contained)[0])
    gfa << c
    assert_not_equal([], gfa.containments)
    assert_equal(c, gfa.segment(:"1").relations_to(:"0",
                                                   :edges_to_contained)[0].to_s)
    gfa.segment(:"1").relations_to(gfa.segment(:"0"), :edges_to_contained).
                                   each(&:disconnect)
    assert_equal([], gfa.containments)
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
    gfa.segment("0").disconnect
    assert_equal([s[1],s[2]], gfa.segments.map(&:to_s))
    assert_equal([:"1", :"2"], gfa.segment_names)
    assert_equal([l], gfa.links.select{|n|!n.virtual?}.map(&:to_s))
    assert_equal([], gfa.containments.map(&:to_s))
    assert_equal([], gfa.paths.map(&:to_s))
    assert_equal([], gfa.path_names)
    gfa.segment("1").disconnect
    assert_equal([s[2]], gfa.segments.map(&:to_s))
    assert_equal([], gfa.links)
    gfa.rm(:"2")
    assert_equal([], gfa.segments)
  end

end
