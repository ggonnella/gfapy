require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFALineGetters < Test::Unit::TestCase

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
