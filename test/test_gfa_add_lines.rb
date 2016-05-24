require_relative "../lib/gfa.rb"
require "test/unit"

class TestGFAAddLines < Test::Unit::TestCase

  def test_add_headers
    gfa = GFA.new
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
    assert_equal(["1", "2"], gfa.segment_names)
    assert_equal(s1, gfa.segment("1"))
    assert_equal(nil, gfa.segment("0"))
    assert_nothing_raised { gfa.segment!("1") }
    assert_raises(RuntimeError) { gfa.segment!("0") }
    assert_raises(ArgumentError) { gfa << s2 }
  end

  def test_add_links
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    l1 = "L\t1\t+\t2\t+\t12M".to_gfa_line
    l2 = "L\t1\t+\t3\t+\t12M"
    gfa = GFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << l1 }
    assert_equal([l1], gfa.links)
    assert_equal(l1, gfa.link("1", nil, "2", nil))
    assert_equal(nil, gfa.link("2", :E, "1", :B))
    assert_nothing_raised {gfa.link!("1", nil, "2", nil)}
    assert_raises(RuntimeError) {gfa.link!("2", :E, "1", :B)}
    assert_nothing_raised { gfa << l2 }
    gfa = GFA.new(segments_first_order: true)
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << l1 }
    assert_raises(RuntimeError) { gfa << l2 }
  end

  def test_add_containments
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    c1 = "C\t1\t+\t2\t+\t12\t12M".to_gfa_line
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    gfa = GFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << c1 }
    assert_equal([c1], gfa.containments)
    assert_equal(c1, gfa.containment("1", "2"))
    assert_nothing_raised {gfa.containment!("1",  "2")}
    assert_raises(RuntimeError) {gfa.containment!("2", "1")}
    assert_nothing_raised { gfa << c2 }
    gfa = GFA.new(segments_first_order: true)
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << c1 }
    assert_raises(RuntimeError) { gfa << c2 }
  end

  def test_add_paths
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    p1 = "P\t4\t1+,2+\t122M,120M".to_gfa_line
    p2 = "P\t1\t1+,2+\t122M,120M"
    p3 = "P\t5\t1+,3+\t122M,120M"
    gfa = GFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << p1 }
    assert_equal([p1], gfa.paths)
    assert_equal(["4"], gfa.path_names)
    assert_equal(p1, gfa.path("4"))
    assert_equal(nil, gfa.path("5"))
    assert_nothing_raised {gfa.path!("4")}
    assert_raises(RuntimeError) {gfa.path!("5")}
    assert_raises(ArgumentError) { gfa << p2 }
    assert_nothing_raised { gfa << p3 }
    gfa = GFA.new(segments_first_order: true)
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << p1 }
    assert_raises(ArgumentError) { gfa << p2 }
    assert_raises(RuntimeError) { gfa << p3 }
  end

end
