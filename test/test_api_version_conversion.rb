require_relative "../lib/rgfa.rb"
require "test/unit"
TestAPI ||= Module.new

class TestAPI::VersionConversion < Test::Unit::TestCase

  def test_header_conversion
    gfa1str = "H\tVN:Z:1.0"
    gfa2str = "H\tVN:Z:2.0"
    assert_equal(gfa1str, gfa2str.to_rgfa_line.to_gfa1.to_s)
    assert_equal(gfa1str, gfa2str.to_rgfa_line.to_gfa1.to_s)
    assert_equal(gfa2str, gfa1str.to_rgfa_line.to_gfa2.to_s)
    assert_equal(gfa2str, gfa2str.to_rgfa_line.to_gfa2.to_s)
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
    # wrong sequence alphabet for GFA2->GFA1
    assert_equal("S\tA\t4\t[[]]", "S\tA\t4\t[[]]".to_rgfa_line.to_gfa2.to_s)
    assert_raise(RGFA::FormatError){"S\tA\t4\t[[]]".to_rgfa_line.to_gfa1}
    # wrong identifier for GFA2->GFA1
    assert_equal("S\tA+,\t3\tNNN", "S\tA+,\t3\tNNN".to_rgfa_line.to_gfa2.to_s)
    assert_raise(RGFA::FormatError){"S\tA+,\t3\tNNN".to_rgfa_line.to_gfa1}
    # sequence not available but LN for GFA1->GFA2
    assert_equal("S\tA\t4\t*", "S\tA\t*\tLN:i:4".to_rgfa_line.to_gfa2.to_s)
    # both sequence and LN not available for GFA1->GFA2
    assert_raise(RGFA::NotFoundError){"S\tA\t*".to_rgfa_line.to_gfa2}
  end

  def test_link_conversion
    gfa1str = "L\tA\t+\tB\t-\t100M"
    gfa1str_noov = "L\tA\t+\tB\t+\t*"
    gfa2str = "E\t*\tA+\tB-\t100\t200$\t100\t200$\t100M"
    # not connected
    assert_raise(RGFA::RuntimeError) {gfa1str.to_rgfa_line.to_gfa2}
    # connected
    g = RGFA.new
    g << "S\tA\t*\tLN:i:200"
    g << "S\tB\t*\tLN:i:200"
    g << (gfa1line = gfa1str.to_rgfa_line)
    g << (gfa1line_noov = gfa1str_noov.to_rgfa_line)
    assert_equal(gfa2str, gfa1line.to_gfa2.to_s)
    assert_equal(gfa1str, gfa1line.to_gfa1.to_s)
    # placeholder overlap
    assert_raise(RGFA::ValueError) {gfa1line_noov.to_rgfa_line.to_gfa2}
    # TODO check if the alignment is compatible with the segment length
  end

  def test_containment_conversion
    gfa1str = "C\tA\t+\tB\t-\t20\t100M"
    gfa1str_noov = "C\tA\t+\tB\t+\t20\t*"
    gfa2str = "E\t*\tA+\tB-\t20\t120\t0\t100$\t100M"
    # not connected
    assert_raise(RGFA::RuntimeError) {gfa1str.to_rgfa_line.to_gfa2}
    # connected
    g = RGFA.new
    g << "S\tA\t*\tLN:i:200"
    g << "S\tB\t*\tLN:i:100"
    g << (gfa1line = gfa1str.to_rgfa_line)
    g << (gfa1line_noov = gfa1str_noov.to_rgfa_line)
    assert_equal(gfa2str, gfa1line.to_gfa2.to_s)
    assert_equal(gfa1str, gfa1line.to_gfa1.to_s)
    # placeholder overlap
    assert_raise(RGFA::ValueError) {gfa1line_noov.to_rgfa_line.to_gfa2}
    # TODO check if the alignment is compatible with the segment length
  end

  def test_edge_conversion
    dovetail         = "E\t*\tA+\tB-\t100\t200$\t100\t200$\t100M"
    dovetail_gfa1    = "L\tA\t+\tB\t-\t100M"
    containment      = "E\t*\tA+\tB-\t20\t120\t0\t100$\t100M"
    containment_gfa1 = "C\tA\t+\tB\t-\t20\t100M"
    internal         = "E\t*\tA+\tB-\t20\t110\t10\t100$\t90M"
    assert_equal(dovetail_gfa1, dovetail.to_rgfa_line.to_gfa1.to_s)
    assert_equal(containment_gfa1, containment.to_rgfa_line.to_gfa1.to_s)
    assert_raise(RGFA::ValueError){internal.to_rgfa_line.to_gfa1}
  end

  def test_L_to_E
    g = RGFA.new(version: :gfa1)
    g << "S\t1\t*\tLN:i:100"
    g << "S\t2\t*\tLN:i:100"
    g << "S\t3\t*\tLN:i:100"
    g << "S\t4\t*\tLN:i:100"
    g << "L\t1\t+\t2\t+\t10M"
    g << "L\t1\t-\t2\t-\t20M"
    g << "L\t3\t-\t4\t+\t30M"
    g << "L\t3\t+\t4\t-\t40M"
    assert_equal("E	*	1+	2+	90	100$	0	10	10M",
                 g.links[0].to_gfa2_s)
    assert_equal("E	*	1-	2-	0	20	80	100$	20M",
                 g.links[1].to_gfa2_s)
    assert_equal("E	*	3-	4+	0	30	0	30	30M",
                 g.links[2].to_gfa2_s)
    assert_equal("E	*	3+	4-	60	100$	60	100$	40M",
                 g.links[3].to_gfa2_s)
    assert_equal(RGFA::Line::Edge::Link, g.links[0].to_gfa1.class)
    assert_equal(RGFA::Line::Edge::GFA2, g.links[0].to_gfa2.class)
  end

  def test_E_to_L
    e1 = "E\t*\t1+\t2+\t90\t100$\t0\t10\t10M".to_rgfa_line
    l1 = "L\t1\t+\t2\t+\t10M"
    assert_equal(l1, e1.to_gfa1_s)
    e2 = "E\t*\t1+\t2+\t0\t20\t80\t100$\t20M".to_rgfa_line
    l2 = "L\t2\t+\t1\t+\t20M"
    assert_equal(l2, e2.to_gfa1_s)
    e3 = "E\t*\t3-\t4+\t0\t30\t0\t30\t30M".to_rgfa_line
    l3 = "L\t3\t-\t4\t+\t30M"
    assert_equal(l3, e3.to_gfa1_s)
    e4 = "E\t*\t3+\t4-\t60\t100$\t60\t100$\t40M".to_rgfa_line
    l4 = "L\t3\t+\t4\t-\t40M"
    assert_equal(l4, e4.to_gfa1_s)
  end

  def test_path_conversion
    path_gfa1 = "P\t1\ta+,b-\t100M"
    path_gfa2 = "O\t1\ta+ a_to_b+ b-"
    # gfa1 => gfa2
    l1 = "L\ta\t+\tb\t-\t100M\tid:Z:a_to_b"
    g1 = RGFA.new
    g1 << (path_gfa1_line = path_gfa1.to_rgfa_line)
    g1 << l1
    g1.process_line_queue
    # not connected
    assert_raise(RGFA::RuntimeError) {path_gfa1.to_rgfa_line.to_gfa2}
    # connected
    assert_equal(path_gfa1, path_gfa1_line.to_gfa1.to_s)
    assert_equal(path_gfa2, path_gfa1_line.to_gfa2.to_s)
    # gfa2 => gfa1
    e = "E\ta_to_b\ta+\tb-\t100\t200$\t100\t200$\t100M"
    sA = "S\ta\t200\t*"
    sB = "S\tb\t200\t*"
    g2 = RGFA.new
    g2 << (path_gfa2_line = path_gfa2.to_rgfa_line)
    g2 << e
    g2 << sA
    g2 << sB
    # not connected
    assert_raise(RGFA::RuntimeError) {path_gfa2.to_rgfa_line.to_gfa1}
    # connected
    assert_equal(path_gfa1, path_gfa2_line.to_gfa1.to_s)
    assert_equal(path_gfa2, path_gfa2_line.to_gfa2.to_s)
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
    gfa1_str =<<-END
# comment
H\tVN:Z:1.0
S\tA\t*\tLN:i:200
S\tB\t*\tLN:i:200
S\tC\t*\tLN:i:100
C\tA\t+\tC\t-\t20\t100M
L\tA\t+\tB\t-\t100M\tid:Z:a_to_b
P\t1\tA+,B-\t100M
    END
    gfa2_str =<<-END
# comment
H\tVN:Z:2.0
S\tA\t200\t*
S\tB\t200\t*
S\tC\t100\t*
E\ta_to_b\tA+\tB-\t100\t200$\t100\t200$\t100M
E\t*\tA+\tC-\t20\t120\t0\t100$\t100M
O\t1\tA+ a_to_b+ B-
    END
    assert_equal(gfa2_str, gfa1_str.to_rgfa.to_gfa2_s)
    assert_equal(gfa1_str, gfa2_str.to_rgfa.to_gfa1_s)
  end

end
