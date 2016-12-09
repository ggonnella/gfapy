require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::Version < Test::Unit::TestCase

  def test_init_without_version_by_init
    gfa = RGFA.new()
    assert_equal(nil, gfa.version)
  end

  def test_init_GFA1
    gfa = RGFA.new(version: :gfa1)
    assert_equal(:gfa1, gfa.version)
  end

  def test_init_GFA2
    gfa = RGFA.new(version: :gfa2)
    assert_equal(:gfa2, gfa.version)
  end

  def test_init_invalid_version
    assert_raises(RGFA::VersionError) { RGFA.new(version: :"x.x") }
  end

  def test_GFA1_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    gfa << hv1
    assert_equal(:gfa1, gfa.version)
  end

  def test_GFA2_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    gfa << hv2
    assert_equal(:gfa2, gfa.version)
  end

  def test_unknown_version_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hvx = "H\tzz:Z:test\tVN:Z:x.x\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    assert_equal(nil, gfa.version)
    assert_raises(RGFA::VersionError) { gfa << hvx }
  end

  def test_wrong_version_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new(version: :gfa1)
    gfa << hother
    assert_equal(:gfa1, gfa.version)
    assert_raises(RGFA::VersionError) { gfa << hv2 }
  end

  def test_conflicting_versions_in_header
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = RGFA.new()
    gfa << hother
    gfa << hv1
    assert_raises(RGFA::VersionError) { gfa << hv2 }
  end

  def test_version_by_segment_GFA1_syntax
    sv1 = "S\tA\t*"
    gfa = RGFA.new()
    gfa << sv1
    assert_equal(:gfa1, gfa.version)
  end

  def test_version_by_segment_GFA2_syntax
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv2
    assert_equal(:gfa2, gfa.version)
  end

  def test_GFA2_segment_in_GFA1
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv1
    assert_raises(RGFA::VersionError) { gfa << sv2 }
  end

  def test_GFA1_segment_in_GFA2
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = RGFA.new()
    gfa << sv2
    assert_raises(RGFA::VersionError) { gfa << sv1 }
  end

  def test_version_by_GFA2_specific_line_E
    e = "E\t*\tA+\tB+\t0\t10\t20\t30\t*"
    gfa = RGFA.new()
    gfa << e
    assert_equal(:gfa2, gfa.version)
  end

  def test_version_by_GFA2_specific_line_G
    g = "G\t*\tA+\tB-\t1000\t*"
    gfa = RGFA.new()
    gfa << g
    assert_equal(:gfa2, gfa.version)
  end

  def test_version_by_GFA2_specific_line_F
    f = "F\tX\tID+\t10\t100\t0\t90$\t*"
    gfa = RGFA.new()
    gfa << f
    assert_equal(:gfa2, gfa.version)
  end

  def test_version_by_GFA2_specific_line_O
    o = "O\tX\tA+ B- C+"
    gfa = RGFA.new()
    gfa << o
    assert_equal(:gfa2, gfa.version)
  end

  def test_version_by_GFA2_specific_line_U
    u = "U\tX\tA B C"
    gfa = RGFA.new()
    gfa << u
    assert_equal(:gfa2, gfa.version)
  end

  def test_version_guess_GFA1_specific_line_L
    str = "L\tA\t-\tB\t+\t*"
    gfa = RGFA.new()
    gfa << str
    gfa.process_line_queue
    assert_equal(:gfa1, gfa.version)
  end

  def test_version_guess_GFA1_specific_line_C
    str = "C\tA\t+\tB\t-\t10\t*"
    gfa = RGFA.new()
    gfa << str
    gfa.process_line_queue
    assert_equal(:gfa1, gfa.version)
  end

  def test_version_guess_GFA1_specific_line_P
    str = "P\t1\ta-,b+\t*"
    gfa = RGFA.new()
    gfa << str
    gfa.process_line_queue
    assert_equal(:gfa1, gfa.version)
  end

  def test_version_guess_default
    gfa = RGFA.new()
    gfa.process_line_queue
    assert_equal(:gfa2, gfa.version)
  end

  def test_header_version
    assert_equal(:generic, "H\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa1, "H\tVN:Z:1.0".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "H\tVN:Z:1.0".to_rgfa_line(version: :gfa2).version)
  end

  def test_comment_version
    assert_equal(:generic, "# VN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa1, "# VN:Z:1.0".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "# VN:Z:1.0".to_rgfa_line(version: :gfa2).version)
  end

  def test_segment_version
    assert_equal(:gfa1, "S\tA\tNNNN".to_rgfa_line.version)
    assert_equal(:gfa2, "S\tA\t1\tNNNN".to_rgfa_line.version)
    assert_equal(:gfa1, "S\tA\tNNNN".to_rgfa_line(version: :gfa1).version)
    assert_equal(:gfa2, "S\tA\t1\tNNNN".to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::FormatError){
      "S\tA\t1\tNNNN".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::FormatError){
      "S\tA\tNNNN".to_rgfa_line(version: :gfa2)}
  end

  def test_link_version
    str = "L\tA\t+\tB\t-\t*"
    assert_equal(:gfa1, str.to_rgfa_line.version)
    assert_equal(:gfa1, str.to_rgfa_line(version: :gfa1).version)
    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa2)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::Edge::Link.new(["A","+","B","-","*"], version: :gfa2)}
  end

  def test_containment_version
    str = "C\tA\t+\tB\t-\t10\t*"
    assert_equal(:gfa1, str.to_rgfa_line.version)
    assert_equal(:gfa1, str.to_rgfa_line(version: :gfa1).version)
    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa2)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::Edge::Containment.new(["A","+","B","-","10","*"],
                                        version: :gfa2)}
  end

  def test_edge_version
    assert_equal(:gfa2, "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line.version)
    assert_equal(:gfa2, "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line(version:
                                                            :gfa2).version)
    assert_raises(RGFA::VersionError){
      "E\t*\tA-\tB+\t0\t100\t0\t100\t*".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::Edge::GFA2.new(["A-","B+", "0", "100", "0", "100", "*"],
                                 version: :gfa1)}
  end

  def test_gap_version
    assert_equal(:gfa2, "G\t*\tA-\tB+\t100\t*".to_rgfa_line.version)
    assert_equal(:gfa2, "G\t*\tA-\tB+\t100\t*".to_rgfa_line(version:
                                                            :gfa2).version)
    assert_raises(RGFA::VersionError){
      "G\t*\tA-\tB+\t100\t*".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::Gap.new(["A-","B+", "100", "*"], version: :gfa1)}
  end

  def test_fragment_version
    assert_equal(:gfa2, "F\tA\tread1-\t0\t100\t0\t100\t*".to_rgfa_line.version)
    assert_equal(:gfa2, "F\tA\tread1-\t0\t100\t0\t100\t*".to_rgfa_line(version:
                                                            :gfa2).version)
    assert_raises(RGFA::VersionError){
      "F\tA\tread1-\t0\t100\t0\t100\t*".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::Fragment.new(["A","read-", "0", "100", "0", "100", "*"],
                               version: :gfa1)}
  end

  def test_custom_record_version
    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line.version)
    assert_equal(:gfa2, "X\tVN:Z:1.0".to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::VersionError){
      "X\tVN:Z:1.0".to_rgfa_line(version: :gfa1)}
    assert_raises(RGFA::VersionError){
      RGFA::Line::CustomRecord.new(["X","VN:Z:1.0"], version: :gfa1)}
  end

  def test_path_version
    str = "P\t1\tA+,B-\t*"
    assert_equal(:gfa1, str.to_rgfa_line.version)
    assert_equal(:gfa1, str.to_rgfa_line(version: :gfa1).version)
    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa2)}
    str = "O\t1\tA+ B-"
    assert_equal(:gfa2, str.to_rgfa_line.version)
    assert_equal(:gfa2, str.to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa1)}
  end

  def test_set_version
    str = "U\t1\tA B C"
    assert_equal(:gfa2, str.to_rgfa_line.version)
    assert_equal(:gfa2, str.to_rgfa_line(version: :gfa2).version)
    assert_raises(RGFA::VersionError){str.to_rgfa_line(version: :gfa1)}
  end

  def test_unknown_record_version
    assert_equal(:gfa2, RGFA::Line::Unknown.new(["A"]).version)
    assert_equal(:gfa2, RGFA::Line::Unknown.new(["A"], version: :gfa2).version)
    assert_raises(RGFA::VersionError){
      RGFA::Line::Unknown.new(["A"], version: :gfa1)}
  end

end
