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
    assert_equal(s1, gfa.get_segment("1"))
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
    assert_equal(l1, gfa.get_link("1", "+", "2", "+"))
    assert_equal(l1, gfa.get_link("1", nil, "2", nil))
    assert_equal(nil, gfa.get_link("1", "-", "2", nil))
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
    assert_equal(c1, gfa.get_containment("1", "+", "2", "+", "12"))
    assert_equal(c1, gfa.get_containment("1", nil, "2", nil, nil))
    assert_equal(nil, gfa.get_containment("1", "+", "2", "+", "10"))
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
    p2 = "P\t1\t1+,2+\t122M,120M"
    p3 = "P\t5\t1+,3+\t122M,120M"
    assert_raises(ArgumentError) { gfa << p2 }
    assert_raises(ArgumentError) { gfa << p3 }
  end

  def test_delete_connections
    gfa = GFA.new
    gfa << "H\tVN:Z:1.0"
    s = ["S\t0\t*".to_gfa_line, "S\t1\t*".to_gfa_line, "S\t2\t*".to_gfa_line]
    l = "L\t1\t+\t2\t+\t12M".to_gfa_line
    c = "C\t1\t+\t0\t+\t12\t12M".to_gfa_line
    p = "P\t4\t2+,0-\t12M,12M".to_gfa_line
    (s + [l,c,p]).each {|line| gfa << line }
    assert_equal([l], gfa.links)
    assert_equal(l, gfa.get_link("1", "+", "2", "+"))
    gfa.delete_link!("1","+","2","+")
    assert_equal([], gfa.links)
    assert_equal(nil, gfa.get_link("1", "+", "2", "+"))
    assert_equal([c], gfa.containments)
    assert_equal(c, gfa.get_containment("1", "+", "0", "+", "12"))
    gfa.delete_containment!("1", "+", "0", "+", "12")
    assert_equal([], gfa.containments)
    assert_equal(nil, gfa.get_containment("1", "+", "0", "+","12"))
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
    assert_equal(l, gfa.get_link("1", nil, "2", nil))
    assert_equal(c, gfa.get_containment("1", nil, "0", nil, nil))
    assert_equal(nil, gfa.get_link("5", nil, "2", nil))
    assert_equal(nil, gfa.get_containment("5", nil, "0", nil, nil))
    assert_equal(6000, gfa.get_segment("1").RC)
    gfa.duplicate_segment!("1","5")
    assert_equal(l, gfa.get_link("1", nil, "2", nil))
    assert_equal(c, gfa.get_containment("1", nil, "0", nil, nil))
    assert_not_equal(nil, gfa.get_link("5", nil, "2", nil))
    assert_not_equal(nil, gfa.get_containment("5", nil, "0", nil, nil))
    assert_equal(3000, gfa.get_segment("1").RC)
    assert_equal(3000, gfa.get_segment("5").RC)
    gfa.multiply_segment!("5",["6","7"])
    assert_equal(l, gfa.get_link("1", nil, "2", nil))
    assert_not_equal(nil, gfa.get_link("5", nil, "2", nil))
    assert_not_equal(nil, gfa.get_link("6", nil, "2", nil))
    assert_not_equal(nil, gfa.get_link("7", nil, "2", nil))
    assert_not_equal(nil, gfa.get_containment("5", nil, "0", nil, nil))
    assert_not_equal(nil, gfa.get_containment("6", nil, "0", nil, nil))
    assert_not_equal(nil, gfa.get_containment("7", nil, "0", nil, nil))
    assert_equal(3000, gfa.get_segment("1").RC)
    assert_equal(1000, gfa.get_segment("5").RC)
    assert_equal(1000, gfa.get_segment("6").RC)
    assert_equal(1000, gfa.get_segment("7").RC)
  end

end
