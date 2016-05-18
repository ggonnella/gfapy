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
    assert_equal(l1, gfa.link("1", "+", "2", "+"))
    assert_equal(l1, gfa.link("1", nil, "2", nil))
    assert_equal(nil, gfa.link("1", "-", "2", nil))
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
    assert_equal(c1, gfa.containment("1", "+", "2", "+", "12"))
    assert_equal(c1, gfa.containment("1", nil, "2", nil, nil))
    assert_equal(nil, gfa.containment("1", "+", "2", "+", "10"))
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

end
