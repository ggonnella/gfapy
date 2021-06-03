import gfapy
import unittest

class TestApiVersion(unittest.TestCase):

  def test_header_conversion(self):
    gfa1str = "H\tVN:Z:1.0"
    gfa2str = "H\tVN:Z:2.0"
    self.assertEqual(gfa1str, str(gfapy.Line(gfa2str).to_gfa1()))
    self.assertEqual(gfa1str, str(gfapy.Line(gfa2str).to_gfa1()))
    self.assertEqual(gfa2str, str(gfapy.Line(gfa1str).to_gfa2()))
    self.assertEqual(gfa2str, str(gfapy.Line(gfa2str).to_gfa2()))

  def test_comment_conversion(self):
    self.assertEqual("# comment",
                 str(gfapy.Line("# comment",version="gfa1").to_gfa1()))
    self.assertEqual("# comment",
                 str(gfapy.Line("# comment",version="gfa2").to_gfa1()))
    self.assertEqual("# comment",
                 str(gfapy.Line("# comment",version="gfa1").to_gfa2()))
    self.assertEqual("# comment",
                 str(gfapy.Line("# comment",version="gfa2").to_gfa2()))

  def test_segment_conversion(self):
    self.assertEqual("S\tA\tNNNN",
        str(gfapy.Line("S\tA\tNNNN").to_gfa1()))
    self.assertEqual("S\tA\t4\tNNNN",
        str(gfapy.Line("S\tA\tNNNN").to_gfa2()))
    self.assertEqual("S\tA\tNNNN\tLN:i:4",str(gfapy.Line("S\tA\t4\tNNNN").to_gfa1()))
    self.assertEqual("S\tA\t*\tLN:i:4",str(gfapy.Line("S\tA\t4\t*").to_gfa1()))
    self.assertEqual("S\tA\t4\tNNNN",str(gfapy.Line("S\tA\t4\tNNNN").to_gfa2()))
    # wrong sequence alphabet for GFA2->GFA1
    self.assertEqual("S\tA\t4\t[[]]",str(gfapy.Line("S\tA\t4\t[[]]").to_gfa2()))
    self.assertRaises(gfapy.RuntimeError,gfapy.Line("S\tA\t4\t[[]]").to_gfa1)
    # wrong identifier for GFA2->GFA1
    self.assertEqual("S\tA+,\t3\tNNN", str(gfapy.Line("S\tA+,\t3\tNNN").to_gfa2()))
    self.assertRaises(gfapy.RuntimeError,gfapy.Line("S\tA+,\t3\tNNN").to_gfa1)
    # sequence not available but LN for GFA1->GFA2
    self.assertEqual("S\tA\t4\t*",str(gfapy.Line("S\tA\t*\tLN:i:4").to_gfa2()))
    # both sequence and LN not available for GFA1->GFA2
    self.assertRaises(gfapy.RuntimeError,gfapy.Line("S\tA\t*").to_gfa2)

  def test_link_conversion(self):
    gfa1str = "L\tA\t+\tB\t-\t100M"
    gfa1str_noov = "L\tA\t+\tB\t+\t*"
    gfa2str = "E\t1\tA+\tB-\t100\t200$\t100\t200$\t100M"
    # not connected
    self.assertRaises(gfapy.RuntimeError,gfapy.Line(gfa1str).to_gfa2)
    # connected
    g = gfapy.Gfa()
    g.add_line("S\tA\t*\tLN:i:200")
    g.add_line("S\tB\t*\tLN:i:200")
    gfa1line = gfapy.Line(gfa1str)
    g.add_line(gfa1line)
    gfa1line_noov = gfapy.Line(gfa1str_noov)
    g.add_line(gfa1line_noov)
    self.assertEqual(gfa2str,str(gfa1line.to_gfa2()))
    self.assertEqual(gfa1str+"\tID:Z:1",str(gfa1line.to_gfa1()))
    # placeholder overlap
    self.assertRaises(gfapy.ValueError,gfa1line_noov.to_gfa2)
    # TODO check if the alignment is compatible with the segment length

  def test_containment_conversion(self):
    gfa1str = "C\tA\t+\tB\t-\t20\t100M"
    gfa1str_noov = "C\tA\t+\tB\t+\t20\t*"
    gfa2str = "E\t1\tA+\tB-\t20\t120\t0\t100$\t100M"
    # not connected
    self.assertRaises(gfapy.RuntimeError,gfapy.Line(gfa1str).to_gfa2)
    # connected
    g = gfapy.Gfa()
    g.add_line("S\tA\t*\tLN:i:200")
    g.add_line("S\tB\t*\tLN:i:100")
    gfa1line = gfapy.Line(gfa1str)
    g.add_line(gfa1line)
    gfa1line_noov = gfapy.Line(gfa1str_noov)
    g.add_line(gfa1line_noov)
    self.assertEqual(gfa2str,str(gfa1line.to_gfa2()))
    self.assertEqual(gfa1str+"\tID:Z:1",str(gfa1line.to_gfa1()))
    # placeholder overlap
    self.assertRaises(gfapy.ValueError,gfa1line_noov.to_gfa2)
    # TODO check if the alignment is compatible with the segment length

  def test_edge_conversion(self):
    dovetail         = "E\t*\tA+\tB-\t100\t200$\t100\t200$\t100M"
    dovetail_gfa1    = "L\tA\t+\tB\t-\t100M"
    containment      = "E\t*\tA+\tB-\t20\t120\t0\t100$\t100M"
    containment_gfa1 = "C\tA\t+\tB\t-\t20\t100M"
    internal         = "E\t*\tA+\tB-\t20\t110\t10\t100$\t90M"
    self.assertEqual(dovetail_gfa1,str( gfapy.Line(dovetail).to_gfa1()))
    self.assertEqual(containment_gfa1,str( gfapy.Line(containment).to_gfa1()))
    self.assertRaises(gfapy.RuntimeError,gfapy.Line(internal).to_gfa1)

  def test_L_to_E(self):
    g = gfapy.Gfa(version="gfa1")
    g.add_line("S\t1\t*\tLN:i:100")
    g.add_line("S\t2\t*\tLN:i:100")
    g.add_line("S\t3\t*\tLN:i:100")
    g.add_line("S\t4\t*\tLN:i:100")
    g.add_line("L\t1\t+\t2\t+\t10M")
    g.add_line("L\t1\t-\t2\t-\t20M")
    g.add_line("L\t3\t-\t4\t+\t30M")
    g.add_line("L\t3\t+\t4\t-\t40M")
    dovetails_gfa1 = g.dovetails
    dovetails_gfa2 = {dovetails_gfa1[0].to_gfa2_s(),
                      dovetails_gfa1[1].to_gfa2_s(),
                      dovetails_gfa1[2].to_gfa2_s(),
                      dovetails_gfa1[3].to_gfa2_s()}
    expected_dovetails_gfa2 = {
        "E	5	1+	2+	90	100$	0	10	10M",
        "E	6	1-	2-	0	20	80	100$	20M",
        "E	7	3-	4+	0	30	0	30	30M",
        "E	8	3+	4-	60	100$	60	100$	40M"}
    try:
      self.assertEqual(expected_dovetails_gfa2, dovetails_gfa2)
    except:
      # sometimes 7 and 8 are assigned with a different order
      # despite using a fixed hash seed in the tests
      expected_dovetails_gfa2 = {
          "E	5	1+	2+	90	100$	0	10	10M",
          "E	6	1-	2-	0	20	80	100$	20M",
          "E	8	3-	4+	0	30	0	30	30M",
          "E	7	3+	4-	60	100$	60	100$	40M"}
      self.assertEqual(expected_dovetails_gfa2, dovetails_gfa2)
    assert(isinstance(g.dovetails[0].to_gfa1(),gfapy.line.edge.Link))
    assert(isinstance(g.dovetails[0].to_gfa2(),gfapy.line.edge.GFA2))

  def test_E_to_L(self):
    e1 = gfapy.Line("E\t*\t1+\t2+\t90\t100$\t0\t10\t10M")
    l1 = "L\t1\t+\t2\t+\t10M"
    self.assertEqual(l1, e1.to_gfa1_s())
    e2 = gfapy.Line("E\t*\t1+\t2+\t0\t20\t80\t100$\t20M")
    l2 = "L\t2\t+\t1\t+\t20M"
    self.assertEqual(l2, e2.to_gfa1_s())
    e3 = gfapy.Line("E\t*\t3-\t4+\t0\t30\t0\t30\t30M")
    l3 = "L\t3\t-\t4\t+\t30M"
    self.assertEqual(l3, e3.to_gfa1_s())
    e4 = gfapy.Line("E\t*\t3+\t4-\t60\t100$\t60\t100$\t40M")
    l4 = "L\t3\t+\t4\t-\t40M"
    self.assertEqual(l4, e4.to_gfa1_s())

  def test_path_conversion(self):
    path_gfa1 = "P\t1\ta+,b-\t100M"
    path_gfa2 = "O\t1\ta+ a_to_b+ b-"
    # gfa1 => gfa2
    l1 = "L\ta\t+\tb\t-\t100M\tID:Z:a_to_b"
    g1 = gfapy.Gfa()
    path_gfa1_line = gfapy.Line(path_gfa1)
    g1.add_line(path_gfa1_line)
    g1.add_line(l1)
    g1.process_line_queue()
    # not connected
    self.assertRaises(gfapy.RuntimeError,
        gfapy.Line(path_gfa1).to_gfa2)
    # connected
    self.assertEqual(path_gfa1,str(path_gfa1_line.to_gfa1()))
    self.assertEqual(path_gfa2,str(path_gfa1_line.to_gfa2()))
    # gfa2 => gfa1
    e = "E\ta_to_b\ta+\tb-\t100\t200$\t100\t200$\t100M"
    sA = "S\ta\t200\t*"
    sB = "S\tb\t200\t*"
    g2 = gfapy.Gfa()
    path_gfa2_line = gfapy.Line(path_gfa2)
    g2.add_line(path_gfa2_line)
    g2.add_line(e)
    g2.add_line(sA)
    g2.add_line(sB)
    # not connected
    self.assertRaises(gfapy.RuntimeError,
        gfapy.Line(path_gfa2).to_gfa1)
    # connected
    self.assertEqual(path_gfa1,str( path_gfa2_line.to_gfa1()))
    self.assertEqual(path_gfa2,str( path_gfa2_line.to_gfa2()))

  def test_gap_conversion(self):
    s = "G\t*\tA-\tB+\t100\t*"
    self.assertEqual(s, str(gfapy.Line(s).to_gfa2()))
    self.assertRaises(gfapy.VersionError,gfapy.Line(s).to_gfa1)

  def test_fragment_conversion(self):
    s = "F\tA\tread1-\t0\t100\t0\t100\t*"
    self.assertEqual(s,str( gfapy.Line(s).to_gfa2()))
    self.assertRaises(gfapy.VersionError,gfapy.Line(s).to_gfa1)

  def test_set_conversion(self):
    s = "U\t1\tA B C"
    self.assertEqual(s,str( gfapy.Line(s).to_gfa2()))
    self.assertRaises(gfapy.VersionError,gfapy.Line(s).to_gfa1)

  def test_custom_record_conversion(self):
    s = "X\tx1\tA\tC"
    self.assertEqual(s,str( gfapy.Line(s).to_gfa2()))
    self.assertRaises(gfapy.VersionError,gfapy.Line(s).to_gfa1)

  def test_unknown_record_conversion(self):
    record = gfapy.line.Unknown([None, "A"])
    self.assertEqual(record, record.to_gfa2())
    self.assertRaises(gfapy.VersionError,record.to_gfa1)

  def test_gfa_conversion(self):
    gfa1_str ='''# comment
H\tVN:Z:1.0
S\tB\t*\tLN:i:200
S\tC\t*\tLN:i:100\txy:i:1
S\tA\t*\tLN:i:200
L\tA\t+\tB\t-\t100M\tID:Z:a_to_b
C\tA\t+\tC\t-\t20\t100M\tID:Z:2
P\t1\tA+,B-\t100M\txx:Z:valid\txy:i:1'''
    gfa2_str ='''# comment
H\tVN:Z:2.0
S\tB\t200\t*
S\tC\t100\t*\txy:i:1
S\tA\t200\t*
E\ta_to_b\tA+\tB-\t100\t200$\t100\t200$\t100M
E\t2\tA+\tC-\t20\t120\t0\t100$\t100M
O\t1\tA+ a_to_b+ B-\txx:Z:valid\txy:i:1'''
    self.assertEqual(gfa2_str, str(gfapy.Gfa(gfa1_str).to_gfa2()))
    self.assertEqual(gfa1_str, str(gfapy.Gfa(gfa2_str).to_gfa1()))
