import gfapy
import unittest

class TestApiVersion(unittest.TestCase):

  def test_init_without_version_by_init(self):
    gfa = gfapy.Gfa()
    self.assertEqual(None, gfa.version)

  def test_init_GFA1(self):
    gfa = gfapy.Gfa(version="gfa1")
    self.assertEqual("gfa1", gfa.version)

  def test_init_GFA2(self):
    gfa = gfapy.Gfa(version="gfa2")
    self.assertEqual("gfa2", gfa.version)

  def test_init_invalid_version(self):
    self.assertRaises(gfapy.VersionError, gfapy.Gfa, version="x.x")

  def test_GFA1_header(self):
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    gfa = gfapy.Gfa()
    gfa.add_line(hother)
    self.assertEqual(None, gfa.version)
    gfa.add_line(hv1)
    self.assertEqual("gfa1", gfa.version)


  def test_GFA2_header(self):
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = gfapy.Gfa()
    gfa.add_line(hother)
    self.assertEqual(None, gfa.version)
    gfa.add_line(hv2)
    self.assertEqual("gfa2", gfa.version)


  def test_unknown_version_in_header(self):
    hother = "H\taa:A:a\tff:f:1.1"
    hvx = "H\tzz:Z:test\tVN:Z:x.x\tii:i:11"
    gfa = gfapy.Gfa()
    gfa.add_line(hother)
    self.assertEqual(None, gfa.version)
    self.assertRaises(gfapy.VersionError, gfa.add_line, hvx)


  def test_wrong_version_in_header(self):
    hother = "H\taa:A:a\tff:f:1.1"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = gfapy.Gfa(version="gfa1")
    gfa.add_line(hother)
    self.assertEqual("gfa1", gfa.version)
    self.assertRaises(gfapy.VersionError, gfa.add_line, hv2)

  def test_conflicting_versions_in_header(self):
    hother = "H\taa:A:a\tff:f:1.1"
    hv1 = "H\tzz:Z:test\tVN:Z:1.0\tii:i:11"
    hv2 = "H\tzz:Z:test\tVN:Z:2.0\tii:i:11"
    gfa = gfapy.Gfa()
    gfa.add_line(hother)
    gfa.add_line(hv1)
    self.assertRaises(gfapy.VersionError, gfa.add_line, hv2)

  def test_version_by_segment_GFA1_syntax(self):
    sv1 = "S\tA\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(sv1)
    self.assertEqual("gfa1", gfa.version)

  def test_version_by_segment_GFA2_syntax(self):
    sv2 = "S\tB\t100\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(sv2)
    self.assertEqual("gfa2", gfa.version)

  def test_GFA2_segment_in_GFA1(self):
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(sv1)
    self.assertRaises(gfapy.VersionError, gfa.add_line, sv2)

  def test_GFA1_segment_in_GFA2(self):
    sv1 = "S\tA\t*"
    sv2 = "S\tB\t100\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(sv2)
    self.assertRaises(gfapy.VersionError, gfa.add_line, sv1)

  def test_version_by_GFA2_specific_line_E(self):
    e = "E\t*\tA+\tB+\t0\t10\t20\t30\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(e)
    self.assertEqual("gfa2", gfa.version)

  def test_version_by_GFA2_specific_line_G(self):
    g = "G\t*\tA+\tB-\t1000\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(g)
    self.assertEqual("gfa2", gfa.version)

  def test_version_by_GFA2_specific_line_F(self):
    f = "F\tX\tID+\t10\t100\t0\t90$\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(f)
    self.assertEqual("gfa2", gfa.version)

  def test_version_by_GFA2_specific_line_O(self):
    o = "O\tX\tA+ B- C+"
    gfa = gfapy.Gfa()
    gfa.add_line(o)
    self.assertEqual("gfa2", gfa.version)

  def test_version_by_GFA2_specific_line_U(self):
    u = "U\tX\tA B C"
    gfa = gfapy.Gfa()
    gfa.add_line(u)
    self.assertEqual("gfa2", gfa.version)

  def test_version_guess_GFA1_specific_line_L(self):
    string = "L\tA\t-\tB\t+\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(string)
    gfa.process_line_queue()
    self.assertEqual("gfa1", gfa.version)

  def test_version_guess_GFA1_specific_line_C(self):
    string = "C\tA\t+\tB\t-\t10\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(string)
    gfa.process_line_queue()
    self.assertEqual("gfa1", gfa.version)

  def test_version_guess_GFA1_specific_line_P(self):
    string = "P\t1\ta-,b+\t*"
    gfa = gfapy.Gfa()
    gfa.add_line(string)
    gfa.process_line_queue()
    self.assertEqual("gfa1", gfa.version)

  def test_version_guess_default(self):
    gfa = gfapy.Gfa()
    gfa.process_line_queue()
    self.assertEqual("gfa2", gfa.version)

  def test_header_version(self):
    self.assertEqual("generic", gfapy.Line("H\tVN:Z:1.0").version)
    self.assertEqual("gfa1", gfapy.Line("H\tVN:Z:1.0", version="gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("H\tVN:Z:1.0", version="gfa2").version)

  def test_comment_version(self):
    self.assertEqual("generic", gfapy.Line("# VN:Z:1.0").version)
    self.assertEqual("gfa1", gfapy.Line("# VN:Z:1.0", version="gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("# VN:Z:1.0", version="gfa2").version)

  def test_segment_version(self):
    self.assertEqual("gfa1", gfapy.Line("S\tA\tNNNN").version)
    self.assertEqual("gfa2", gfapy.Line("S\tA\t1\tNNNN").version)
    self.assertEqual("gfa1", gfapy.Line("S\tA\tNNNN", version="gfa1").version)
    self.assertEqual("gfa2", gfapy.Line("S\tA\t1\tNNNN", version="gfa2").version)
    self.assertRaises(gfapy.FormatError,
      gfapy.Line, "S\tA\t1\tNNNN", version="gfa1")
    self.assertRaises(gfapy.FormatError,
      gfapy.Line, "S\tA\tNNNN", version="gfa2")

  def test_link_version(self):
    string = "L\tA\t+\tB\t-\t*"
    self.assertEqual("gfa1", gfapy.Line(string).version)
    self.assertEqual("gfa1", gfapy.Line(string, version="gfa1").version)
    self.assertRaises(gfapy.VersionError, gfapy.Line, string, version="gfa2")
    self.assertRaises(gfapy.VersionError,
      gfapy.line.edge.Link, ["A","+","B","-","*"], version="gfa2")

  def test_containment_version(self):
    string = "C\tA\t+\tB\t-\t10\t*"
    self.assertEqual("gfa1", gfapy.Line(string).version)
    self.assertEqual("gfa1", gfapy.Line(string,version="gfa1").version)
    self.assertRaises(gfapy.VersionError, gfapy.Line,string,version="gfa2")
    self.assertRaises(gfapy.VersionError, gfapy.line.edge.Containment,
                      ["A","+","B","-","10","*"], version="gfa2")

  def test_edge_version(self):
    self.assertEqual("gfa2", gfapy.Line("E\t*\tA-\tB+\t0\t100\t0\t100\t*").version)
    self.assertEqual("gfa2", gfapy.Line("E\t*\tA-\tB+\t0\t100\t0\t100\t*",version=\
                                                            "gfa2").version)
    self.assertRaises(gfapy.VersionError,
      gfapy.Line, "E\t*\tA-\tB+\t0\t100\t0\t100\t*", version="gfa1")
    self.assertRaises(gfapy.VersionError,
      gfapy.line.edge.GFA2, ["A-","B+", "0", "100", "0", "100", "*"],
                                 version="gfa1")

  def test_gap_version(self):
    self.assertEqual("gfa2", gfapy.Line("G\t*\tA-\tB+\t100\t*").version)
    self.assertEqual("gfa2", gfapy.Line("G\t*\tA-\tB+\t100\t*",
                               version="gfa2").version)
    self.assertRaises(gfapy.VersionError,
      gfapy.Line, "G\t*\tA-\tB+\t100\t*", version="gfa1")
    self.assertRaises(gfapy.VersionError,
      gfapy.line.Gap,["A-","B+", "100", "*"], version="gfa1")

  def test_fragment_version(self):
    self.assertEqual("gfa2", gfapy.Line("F\tA\tread1-\t0\t100\t0\t100\t*").version)
    self.assertEqual("gfa2", gfapy.Line("F\tA\tread1-\t0\t100\t0\t100\t*", version=\
                                                            "gfa2").version)
    self.assertRaises(gfapy.VersionError,
      gfapy.Line, "F\tA\tread1-\t0\t100\t0\t100\t*", version="gfa1")
    self.assertRaises(gfapy.VersionError,
      gfapy.line.Fragment,["A","read-", "0", "100", "0", "100", "*"],
                               version="gfa1")

  def test_custom_record_version(self):
    self.assertEqual("gfa2", gfapy.Line("X\tVN:Z:1.0").version)
    self.assertEqual("gfa2", gfapy.Line("X\tVN:Z:1.0", version="gfa2").version)
    self.assertRaises(gfapy.VersionError,
      gfapy.Line, "X\tVN:Z:1.0", version="gfa1")
    self.assertRaises(gfapy.VersionError,
      gfapy.line.CustomRecord, ["X","VN:Z:1.0"], version="gfa1")

  def test_path_version(self):
    string = "P\t1\tA+,B-\t*"
    self.assertEqual("gfa1", gfapy.Line(string).version)
    self.assertEqual("gfa1", gfapy.Line(string, version="gfa1").version)
    self.assertRaises(gfapy.VersionError, gfapy.Line, string, version="gfa2")
    string = "O\t1\tA+ B-"
    self.assertEqual("gfa2", gfapy.Line(string).version)
    self.assertEqual("gfa2", gfapy.Line(string, version="gfa2").version)
    self.assertRaises(gfapy.VersionError, gfapy.Line, string, version="gfa1")

  def test_set_version(self):
    string = "U\t1\tA B C"
    self.assertEqual("gfa2", gfapy.Line(string).version)
    self.assertEqual("gfa2", gfapy.Line(string, version="gfa2").version)
    self.assertRaises(gfapy.VersionError, gfapy.Line, string, version="gfa1")

  def test_unknown_record_version(self):
    self.assertEqual("gfa2", gfapy.line.Unknown([None, "A"]).version)
    self.assertEqual("gfa2", gfapy.line.Unknown([None, "A"], version="gfa2").version)
    self.assertRaises(gfapy.VersionError, gfapy.line.Unknown,["\n","A"], version="gfa1")
