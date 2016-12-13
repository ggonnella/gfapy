require_relative "../lib/rgfa.rb"
require "test/unit"

TestAPI ||= Module.new
TestAPI::Lines ||= Module.new
class TestAPI::Lines::Finders < Test::Unit::TestCase

  def test_segment
    s = ["S\t1\t*","S\t2\t*"]
    gfa = s.to_rgfa
    assert_equal(s[0],gfa.segment("1").to_s)
    assert_equal(s[0],gfa.segment!("1").to_s)
    assert_equal(nil,gfa.segment("0"))
    assert_raises(RGFA::NotFoundError) {gfa.segment!("0").to_s}
  end

  def test_path
    s = ["S\t1\t*","S\t2\t*", "S\t3\t*"]
    l = ["L\t1\t+\t2\t+\t122M", "L\t1\t+\t3\t+\t120M"]
    pt = ["P\t4\t1+,2+\t122M", "P\t5\t1+,3+\t120M"]
    gfa = (s+l+pt).to_rgfa
    assert_equal(pt[0],gfa.path("4").to_s)
    assert_equal(pt[0],gfa.path!("4").to_s)
    assert_equal(nil,gfa.path("6"))
    assert_raises(RGFA::NotFoundError) {gfa.path!("6").to_s}
  end

  def test_paths_with_segment
    gfa = RGFA.new
    s = (0..3).map{|i| "S\t#{i}\t*".to_rgfa_line}
    p = "P\t4\t2+,0-\t*"
    (s + [p]).each {|line| gfa << line }
    assert_equal([p], gfa.segment("0").paths.map(&:to_s))
    assert_equal([p], gfa.segment("2").paths.map(&:to_s))
    assert_equal([], gfa.segment("1").paths.map(&:to_s))
  end

  def test_containing
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*"
    gfa << c
    assert_equal([c], gfa.segment!("0").edges_to_containers.map(&:to_s))
    assert_equal([],  gfa.segment!("1").edges_to_containers)
    assert_equal([],  gfa.segment!("2").edges_to_containers)
  end

  def test_contained_in
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c = "C\t1\t+\t0\t+\t0\t*"
    gfa << c
    assert_equal([],  gfa.segment!("0").edges_to_contained)
    assert_equal([c], gfa.segment!("1").edges_to_contained.map(&:to_s))
    assert_equal([],  gfa.segment!("2").edges_to_contained)
  end

  def test_containments_between
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*"
    c2 = "C\t1\t+\t0\t+\t12\t*"
    gfa << c1
    gfa << c2
    assert_equal([], gfa.containments_between("0", "1"))
    assert_equal([c1,c2], gfa.containments_between("1", "0").map(&:to_s))
  end

  def test_containment
    gfa = RGFA.new
    (0..2).each{|i| gfa << "S\t#{i}\t*"}
    c1 = "C\t1\t+\t0\t+\t0\t*"
    c2 = "C\t1\t+\t0\t+\t12\t*"
    gfa << c1
    gfa << c2
    assert_equal([], gfa.containments_between("0", "1"))
    assert_equal([c1,c2], gfa.containments_between("1", "0").map(&:to_s))
  end

  def test_link
    gfa = RGFA.new
    (0..3).each{|i| gfa << "S\t#{i}\t*"}
    l0 = "L\t1\t+\t2\t+\t11M1D3M"; gfa << l0
    l1 = "L\t1\t+\t2\t+\t10M2D3M"; gfa << l1
    l2 = "L\t1\t+\t3\t+\t*"; gfa << l2
    assert_equal(l0, gfa.link(["1", :R], ["2", :L]).to_s)
    assert_equal(l0, gfa.link!(["1", :R], ["2", :L]).to_s)
    assert_equal(nil, gfa.link(["1", :R], ["2", :R]))
    assert_raise(RGFA::NotFoundError) { gfa.link!(["1", :R], ["2", :R]) }
  end

end
