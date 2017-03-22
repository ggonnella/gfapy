import unittest
import gfapy

class TestUnitHeader(unittest.TestCase):

  def test_new(self):
    gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"])

  def test_string_to_gfa_line(self):
    gfapy.Line("H\tVN:Z:1.0")
    assert(isinstance(gfapy.Line("H\tVN:Z:1.0"),gfapy.line.Header))
    self.assertEqual(gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"]),
      gfapy.Line("H\tVN:Z:1.0\txx:i:11"))
    self.assertRaises(gfapy.FormatError,
      gfapy.Line, "H\tH2\tVN:Z:1.0")
    self.assertRaises(gfapy.TypeError,
      gfapy.Line, "H\tVN:i:1.0")

  def test_to_s(self):
    try:
      self.assertEqual("H\tVN:Z:1.0\txx:i:11",
        str(gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"])))
    except:
      self.assertEqual("H\txx:i:11\tVN:Z:1.0",
        str(gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"])))

  def test_tag_reading(self):
    self.assertEqual("1.0",
      gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"]).VN)

  def test_tag_writing(self):
    gfapy.line.Header(["H", "VN:Z:1.0", "xx:i:11"]).VN = "2.0"

  def test_connection(self):
    assert(not gfapy.line.Header(["H"]).is_connected())
    assert(gfapy.Gfa().header.is_connected())
    self.assertRaises(gfapy.RuntimeError,
      gfapy.line.Header(["H"]).connect, gfapy.Gfa())

  def test_to_gfa1_a(self):
    line = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    self.assertEqual("H", line._to_gfa1_a()[0])
    self.assertEqual(sorted(["VN:Z:1.0", "xx:i:1"]), sorted(line._to_gfa1_a()[1:]))
    line = gfapy.Line("H\tVN:Z:2.0\txx:i:1")
    self.assertEqual("H", line._to_gfa1_a()[0])
    self.assertEqual(sorted(["VN:Z:1.0", "xx:i:1"]), sorted(line._to_gfa1_a()[1:]))

  def test_to_gfa2_a(self):
    line = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    self.assertEqual("H", line._to_gfa2_a()[0])
    self.assertEqual(sorted(["VN:Z:2.0", "xx:i:1"]), sorted(line._to_gfa2_a()[1:]))
    line = gfapy.Line("H\tVN:Z:2.0\txx:i:1")
    self.assertEqual("H", line._to_gfa2_a()[0])
    self.assertEqual(sorted(["VN:Z:2.0", "xx:i:1"]), sorted(line._to_gfa2_a()[1:]))

  def test_add(self):
    line = gfapy.Line("H\tVN:Z:2.0\txx:i:1")
    line.add("yy", "test")
    self.assertEqual("test", line.yy)
    line.add("yy", "test")
    self.assertEqual(["test","test"], line.yy)
    line.add("yy", "test")
    self.assertEqual(["test","test","test"], line.yy)
    line.add("VN", "2.0")
    self.assertEqual("2.0", line.VN)
    self.assertRaises(gfapy.InconsistencyError, line.add, "VN", "1.0")
    line.add("TS", "120")
    self.assertEqual(120, line.TS)
    line.add("TS", 120)
    line.add("TS", "120")
    self.assertRaises(gfapy.InconsistencyError, line.add, "TS", 130)
    self.assertRaises(gfapy.InconsistencyError, line.add, "TS", "140")

  def test_field_to_s(self):
    line = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    line.add("xx", 2)
    self.assertEqual("1.0", line.field_to_s("VN"))
    self.assertEqual("1\t2", line.field_to_s("xx"))
    self.assertEqual("VN:Z:1.0", line.field_to_s("VN", tag=True))
    self.assertEqual("xx:i:1\txx:i:2", line.field_to_s("xx", tag=True))

  def test_n_duptags(self):
    line = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    self.assertEqual(0, line._n_duptags())
    line.add("xx", 2)
    self.assertEqual(1, line._n_duptags())
    line.add("xx", 2)
    self.assertEqual(1, line._n_duptags())
    line.add("zz", 2)
    self.assertEqual(1, line._n_duptags())
    line.add("zz", 2)
    self.assertEqual(2, line._n_duptags())

  def test_split(self):
    line = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    line.add("xx", 2)
    self.assertEqual(3, len(line._split()))
    for s in line._split():
      assert(isinstance(s, gfapy.line.Header))
    self.assertEqual(sorted(["H\tVN:Z:1.0", "H\txx:i:1", "H\txx:i:2"]),
                     sorted([str(x) for x in line._split()]))

  def test_merge(self):
    line1 = gfapy.Line("H\tVN:Z:1.0\txx:i:1")
    line2 = gfapy.Line("H\txx:i:2\tyy:f:1.0")
    line1._merge(line2)
    self.assertEqual("1.0", line1.VN)
    self.assertEqual([1,2], line1.xx)
    self.assertEqual(1.0, line1.yy)

