require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::VersionConversion < Test::Unit::TestCase

  def test_header_conversion
    assert_equal("H\tVN:Z:1.0", "H\tVN:Z:1.0".to_rgfa_line.to_gfa1.to_s)
    assert_equal("H\tVN:Z:1.0", "H\tVN:Z:2.0".to_rgfa_line.to_gfa1.to_s)
    assert_equal("H\tVN:Z:2.0", "H\tVN:Z:1.0".to_rgfa_line.to_gfa2.to_s)
    assert_equal("H\tVN:Z:2.0", "H\tVN:Z:2.0".to_rgfa_line.to_gfa2.to_s)
  end

  def test_comment_conversion
    assert_equal("# comment",
                 "# comment".to_rgfa_line(version: :gfa1).to_gfa1.to_s)
    assert_equal("# comment",
                 "# comment".to_rgfa_line(version: :gfa2).to_gfa1.to_s)
    assert_equal("# comment",
                 "# comment".to_rgfa_line(version: :gfa1).to_gfa2.to_s)
    assert_equal("# comment",
                 "# comment".to_rgfa_line(version: :gfa2).to_gfa2.to_s)
  end

  def test_segment_conversion
    assert_equal("S\tA\tNNNN", "S\tA\tNNNN".to_rgfa_line.to_gfa1.to_s)
    assert_equal("S\tA\t4\tNNNN", "S\tA\tNNNN".to_rgfa_line.to_gfa2.to_s)
    assert_equal("S\tA\tNNNN\tLN:i:4",
                 "S\tA\t4\tNNNN".to_rgfa_line.to_gfa1.to_s)
    assert_equal("S\tA\t4\tNNNN", "S\tA\t4\tNNNN".to_rgfa_line.to_gfa2.to_s)
    # XXX wrong sequence alphabet for GFA2->GFA1
    # XXX wrong identifier for GFA2->GFA1
    # XXX sequence not available but LN for GFA1->GFA2
    # XXX sequence and LN not available for GFA1->GFA2
  end

  def test_link_conversion
    # XXX
  end

  def test_containment_conversion
    # XXX
  end

  def test_edge_conversion
    # XXX dovetail
    # XXX containment
    # XXX internal
  end

  def test_path_conversion
    # XXX from GFA1 to GFA2
    # XXX from GFA2 to GFA1
  end

  def test_gap_conversion
    str = "G\t*\tA-\tB+\t100\t*"
    assert_equal(str, str.to_rgfa_line.to_gfa2.to_s)
    assert_raises(RGFA::VersionError){str.to_rgfa_line.to_gfa1}
  end

  def test_fragment_conversion
    str = "F\tA\tread1-\t0\t100\t0\t100\t*"
    assert_equal(str, str.to_rgfa_line.to_gfa2.to_s)
    assert_raises(RGFA::VersionError){str.to_rgfa_line.to_gfa1}
  end

  def test_set_conversion
    str = "U\t1\tA B C"
    assert_equal(str, str.to_rgfa_line.to_gfa2.to_s)
    assert_raises(RGFA::VersionError){str.to_rgfa_line.to_gfa1}
  end

  def test_custom_record_conversion
    str = "X\tx1\tA\tC"
    assert_equal(str, str.to_rgfa_line.to_gfa2.to_s)
    assert_raises(RGFA::VersionError){str.to_rgfa_line.to_gfa1}
  end

  def test_unknown_record_conversion
    record = RGFA::Line::Unknown.new(["A"])
    assert_equal(record, record.to_gfa2)
    assert_raises(RGFA::VersionError){record.to_gfa1}
  end

  def test_gfa_conversion
    # XXX
  end

#
#  def test_path_version
#    str = "P\t1\tA+,B-\t*"
#    assert_equal(:gfa1, str.to_rgfa_line.version)
#    assert_equal(:gfa1, str.to_rgfa_line(version: :gfa1).version)
#    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa2)}
#    str = "O\t1\tA+ B-"
#    assert_equal(:gfa2, str.to_rgfa_line.version)
#    assert_equal(:gfa2, str.to_rgfa_line(version: :gfa2).version)
#    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa1)}
#  end
#
#  def test_link_version
#    assert_equal(:gfa1, "L\tA\t+\tB\t-\t*".to_rgfa_line.version)
#    assert_equal(:gfa1,
#                 "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :gfa1).version)
#    l = "L\tA\t+\tB\t-\t*".to_rgfa_line(version: :gfa2)
#    assert_equal(RGFA::Line::CustomRecord, l.class)
#    assert_raises(RGFA::VersionError){
#      RGFA::Line::Edge::Link.new(["A","+","B","-","*"], version: :gfa2)}
#  end
#
#  def test_containment_version
#    assert_equal(:gfa1, "C\tA\t+\tB\t-\t10\t*".to_rgfa_line.version)
#    assert_equal(:gfa1,
#                 "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :gfa1).version)
#    c = "C\tA\t+\tB\t-\t10\t*".to_rgfa_line(version: :gfa2)
#    assert_equal(RGFA::Line::CustomRecord, c.class)
#    assert_raises(RGFA::VersionError){
#      RGFA::Line::Edge::Containment.new(["A","+","B","-","10","*"],
#                                        version: :gfa2)}
#  end
#
#  def test_edge_version
#    assert_equal(:gfa2, "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line.version)
#    assert_equal(:gfa2, "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line(version:
#                                                            :gfa2).version)
#    assert_raises(RGFA::TypeError){
#      "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line(version: :gfa1)}
#    assert_raises(RGFA::VersionError){
#      RGFA::Line::Edge::GFA2.new(["A-","B+", "0", "100", "0", "100", "*"],
#                                 version: :gfa1)}
#  end
#
#  def test_custom_record_version
#    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line.version)
#    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line(version: :gfa2).version)
#    assert_raises(RGFA::TypeError){
#      "X\tVN:Z:1.0".to_rgfa_line(version: :gfa1)}
#    assert_raises(RGFA::VersionError){
#      RGFA::Line::CustomRecord.new(["X","VN:Z:1.0"], version: :gfa1)}
#  end
#
#  def test_unknown_record_version
#    assert_equal(:gfa2, RGFA::Line::Unknown.new(["A"]).version)
#    assert_equal(:gfa2, RGFA::Line::Unknown.new(["A"], version: :gfa2).version)
#    assert_raises(RGFA::VersionError){
#      RGFA::Line::Unknown.new(["A"], version: :gfa1)}
#  end
#
end
