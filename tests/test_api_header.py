import unittest
import gfapy

class TestApiHeader(unittest.TestCase):

  def test_gfa_header(self):
    g = gfapy.Gfa()
    assert(isinstance(g.header, gfapy.line.Header))
    self.assertEqual([], g.header.tagnames)
    g.add_line("H\txx:i:1")
    self.assertEqual(["xx"], g.header.tagnames)

  def test_gfa_header_line_connect(self):
    g = gfapy.Gfa()
    line = gfapy.Line("H\txx:i:1")
    self.assertRaises(gfapy.RuntimeError, line.connect, g)
    g.add_line(line) # nothing raised

  def test_header_version_editing(self):
    standalone = gfapy.Line("H\txx:i:1\tVN:Z:1.0")
    standalone.VN = "2.0" # nothing raised
    g = gfapy.Gfa()
    g.add_line("H\txx:i:1\tVN:Z:1.0")
    g.header.xx = 2 # nothing raised
    with self.assertRaises(gfapy.RuntimeError):
      g.header.VN = "2.0"

  def test_error_inconsistent_definitions(self):
    g = gfapy.Gfa()
    g.add_line("H\txx:i:1")
    g.add_line("H\txx:i:2") # nothing raised
    g.add_line("H\tTS:i:120")
    g.add_line("H\tTS:i:120") # nothing raised
    self.assertRaises(gfapy.InconsistencyError, g.add_line, "H\tTS:i:122")

  def test_gfa_multiple_def_tags(self):
    g = gfapy.Gfa()
    for i in range(4):
      g.add_line("H\txx:i:{}".format(i))
    self.assertEqual(["xx"], g.header.tagnames)
    self.assertEqual([0,1,2,3], g.header.xx)
    self.assertEqual([0,1,2,3], g.header.get("xx"))
    self.assertEqual("i", g.header.get_datatype("xx"))
    g.header.validate_field("xx") # nothing raised
    for i in [0,2,3]:
      g.header.xx.remove(i)
    g.header.xx = [1, 4]
    self.assertRaises(gfapy.TypeError, g.header.validate_field, "xx")
    g.header.xx = gfapy.FieldArray("i", data = g.header.xx)
    g.header.validate_field("xx") # nothing raised
    self.assertEqual([1,4], g.header.get("xx"))
    self.assertEqual("1\t4", g.header.field_to_s("xx"))
    self.assertEqual("xx:i:1\txx:i:4", g.header.field_to_s("xx", tag=True))
    self.assertEqual(sorted(["H\txx:i:1","H\txx:i:4"]),
                     sorted([str(h) for h in g.headers]))
    g.header.add("xx", 12)
    g.header.add("yy", 13)
    self.assertEqual([1,4,12], g.header.xx)
    self.assertEqual(13, g.header.yy)

  def test_gfa_single_def_tags(self):
    g = gfapy.Gfa()
    g.add_line("H\txx:i:1")
    self.assertEqual(["xx"], g.header.tagnames)
    self.assertEqual(1, g.header.xx)
    g.header.set("xx", 12)
    self.assertEqual(12, g.header.xx)
    g.header.delete("xx")
    self.assertEqual(None, g.header.xx)
