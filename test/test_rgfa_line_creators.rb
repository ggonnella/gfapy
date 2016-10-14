require_relative "../lib/rgfa.rb"
require "test/unit"

class TestRGFALineCreators < Test::Unit::TestCase

  def test_add_headers
    gfa = RGFA.new
    h = "H\tVN:Z:1.0"
    assert_nothing_raised { gfa << h }
    assert_equal([h], gfa.headers.map(&:to_s))
  end

  def test_add_comments
    gfa = RGFA.new
    c1 = "#this is a comment"
    c2 = "# this is also a comment"
    c3 = "#and \tthis too!"
    assert_nothing_raised { gfa << c1 }
    assert_nothing_raised { gfa << c2 }
    assert_nothing_raised { gfa << c3 }
    assert_equal([c1,c2,c3], gfa.comments.map(&:to_s))
  end

  def test_add_custom_records
    gfa = RGFA.new(version: :"2.0")
    x1 = "X\tthis is a custom record"
    assert_nothing_raised { gfa << x1 }
    assert_equal([:X], gfa.custom_records.keys)
    assert_equal([x1], gfa.custom_records[:X].map(&:to_s))
  end

  def test_add_segments
    gfa = RGFA.new
    s1 = "S\t1\t*".to_rgfa_line
    s2 = "S\t2\t*".to_rgfa_line
    assert_nothing_raised { gfa << s1 }
    assert_nothing_raised { gfa << s2 }
    assert_equal([s1, s2], gfa.segments)
    assert_equal([:"1", :"2"], gfa.segment_names)
    assert_equal(s1, gfa.segment("1"))
    assert_equal(nil, gfa.segment("0"))
    assert_nothing_raised { gfa.segment!("1") }
    assert_raises(RGFA::LineMissingError) { gfa.segment!("0") }
    assert_raises(RGFA::DuplicatedLabelError) { gfa << s2 }
  end

  def test_add_links
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    l1 = "L\t1\t+\t2\t+\t12M".to_rgfa_line
    l2 = "L\t1\t+\t3\t+\t12M"
    gfa = RGFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << l1 }
    assert_equal([l1], gfa.links)
    assert_equal(l1, gfa.link(["1", :E], ["2", :B]))
    assert_equal(l1, gfa.link(["2", :B], ["1", :E]))
    assert_equal(nil, gfa.link(["2", :E], ["1", :B]))
    assert_nothing_raised {gfa.link!(["1", :E], ["2", :B])}
    assert_raises(RGFA::LineMissingError) {gfa.link!(["2", :E], ["1", :B])}
    assert_nothing_raised { gfa << l2 }
  end

  def test_add_containments
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    c1 = "C\t1\t+\t2\t+\t12\t12M".to_rgfa_line
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    gfa = RGFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << c1 }
    assert_equal([c1], gfa.containments)
    assert_equal(c1, gfa.containment("1", "2"))
    assert_nothing_raised {gfa.containment!("1",  "2")}
    assert_raises(RGFA::LineMissingError) {gfa.containment!("2", "1")}
    assert_nothing_raised { gfa << c2 }
  end

  def test_add_paths
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    p1 = "P\t4\t1+,2+\t122M".to_rgfa_line
    p2 = "P\t1\t1+,2+\t122M"
    p3 = "P\t5\t1+,2+,3+\t122M,120M"
    gfa = RGFA.new
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << p1 }
    assert_equal([p1], gfa.paths)
    assert_equal([:"4"], gfa.path_names)
    assert_equal(p1, gfa.path("4"))
    assert_equal(nil, gfa.path("5"))
    assert_nothing_raised {gfa.path!("4")}
    assert_raises(RGFA::LineMissingError) {gfa.path!("5")}
    assert_raises(RGFA::DuplicatedLabelError) { gfa << p2 }
    assert_nothing_raised { gfa << p3 }
  end

  def test_segments_first_order
    s1 = "S\t1\t*"
    s2 = "S\t2\t*"
    l1 = "L\t1\t+\t2\t+\t122M"
    l2 = "L\t1\t+\t3\t+\t122M"
    c1 = "C\t1\t+\t2\t+\t12\t12M"
    c2 = "C\t1\t+\t3\t+\t12\t12M"
    p1 = "P\t4\t1+,2+\t122M"
    p2 = "P\t1\t1+,2+\t122M"
    p3 = "P\t5\t1+,3+\t122M"
    gfa = RGFA.new
    gfa.require_segments_first_order
    gfa << s1
    gfa << s2
    assert_nothing_raised { gfa << l1 }
    assert_raises(RGFA::LineMissingError) { gfa << l2 }
    assert_nothing_raised { gfa << c1 }
    assert_raises(RGFA::LineMissingError) { gfa << c2 }
    assert_nothing_raised { gfa << p1 }
    assert_raises(RGFA::DuplicatedLabelError) { gfa << p2 }
    assert_raises(RGFA::LineMissingError) { gfa << p3 }
  end

  def test_header_add
    gfa = RGFA.new
    gfa << "H\tVN:Z:1.0"
    gfa << "H\taa:i:12\tab:Z:test1"
    gfa << "H\tac:Z:test2"
    gfa.header.add(:aa, 15)
    assert_equal(
      [
        "H\tVN:Z:1.0",
        "H\taa:i:12",
        "H\taa:i:15",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ],
      gfa.headers.map(&:to_s).sort)
    gfa.header.add(:aa, 16)
    assert_equal(
      [
        "H\tVN:Z:1.0",
        "H\taa:i:12",
        "H\taa:i:15",
        "H\taa:i:16",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ],
      gfa.headers.map(&:to_s).sort)
    gfa.header.delete(:aa)
    gfa.header.aa = 26
    assert_equal(
      [
        "H\tVN:Z:1.0",
        "H\taa:i:26",
        "H\tab:Z:test1",
        "H\tac:Z:test2",
      ],
      gfa.headers.map(&:to_s).sort)
  end

end
