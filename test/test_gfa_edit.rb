require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAEdit < Test::Unit::TestCase

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
    assert_equal(l, gfa.link("1", nil, "2", nil))
    assert_equal(c, gfa.containment("1", "0"))
    assert_equal(nil, gfa.link("5", nil, "2", nil))
    assert_equal(nil, gfa.containment("5", "0"))
    assert_equal(6000, gfa.segment("1").RC)
    gfa.duplicate_segment("1","5")
    assert_equal(l, gfa.link("1", nil, "2", nil))
    assert_equal(c, gfa.containment("1", "0"))
    assert_not_equal(nil, gfa.link("5", nil, "2", nil))
    assert_not_equal(nil, gfa.containment("5", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(3000, gfa.segment("5").RC)
    gfa.multiply_segment("5",["6","7"])
    assert_equal(l, gfa.link("1", nil, "2", nil))
    assert_not_equal(nil, gfa.link("5", nil, "2", nil))
    assert_not_equal(nil, gfa.link("6", nil, "2", nil))
    assert_not_equal(nil, gfa.link("7", nil, "2", nil))
    assert_not_equal(nil, gfa.containment("5", "0"))
    assert_not_equal(nil, gfa.containment("6", "0"))
    assert_not_equal(nil, gfa.containment("7", "0"))
    assert_equal(3000, gfa.segment("1").RC)
    assert_equal(1000, gfa.segment("5").RC)
    assert_equal(1000, gfa.segment("6").RC)
    assert_equal(1000, gfa.segment("7").RC)
  end

end
