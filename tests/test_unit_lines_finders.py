import unittest
import gfapy

class TestUnitLineFinders(unittest.TestCase):


  l_gfa1_str = ["S\t1\t*",
                "S\t2\t*",
                "S\t3\t*",
                "S\t4\tCGAT",
                "L\t1\t+\t2\t+\t*",
                "L\t1\t-\t3\t+\t10M",
                "C\t1\t-\t4\t-\t1\t*",
                "P\tp1\t1+,2+\t*"]
  l_gfa1 = [gfapy.Line(s) for s in l_gfa1_str]
  gfa1 = gfapy.Gfa(l_gfa1)

  l_gfa2_str = ["S\t5\t100\t*",
                "S\t6\t110\t*",
                "E\te1\t5+\t6-\t0\t100$\t10\t110$\t*",
                "G\tg1\t5-\t6-\t1000\t*",
                "O\to1\t5+ 6-",
                "U\tu1\t5 e1",
                "F\t5\tread1-\t0\t10\t102\t122\t*",
                "F\t5\tread1-\t30\t100$\t180\t255\t*",
                "F\t6\tread1-\t40\t50\t52\t64\t*",
                "X\tx1\txx:Z:A",
                "X\tx2",
                "G\t*\t5+\t6+\t2000\t*"]
  l_gfa2 = [gfapy.Line(s) for s in l_gfa2_str]
  gfa2 = gfapy.Gfa(l_gfa2)

  def test_search_link(self):
    # search using the direct link
    self.assertEqual(TestUnitLineFinders.l_gfa1[4], TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("1","+"), gfapy.OrientedLine("2","+"), "*"))
    # search using the complement link
    self.assertEqual(TestUnitLineFinders.l_gfa1[4], TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("2","-"), gfapy.OrientedLine("1","-"), "*"))
    # with cigar parameter, but placeholder in line
    self.assertEqual(TestUnitLineFinders.l_gfa1[4],
                 TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("1","+"), gfapy.OrientedLine("2","+"), "10M"))
    # with cigar parameter, and cigar in line
    self.assertEqual(TestUnitLineFinders.l_gfa1[5],
                 TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("1","-"), gfapy.OrientedLine("3","+"), "10M"))
    self.assertEqual(None,
                 TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("1","-"), gfapy.OrientedLine("3","+"), "12M"))
    # with placeholder parameter, and cigar in line
    self.assertEqual(TestUnitLineFinders.l_gfa1[5],
                 TestUnitLineFinders.gfa1._search_link(gfapy.OrientedLine("1","-"), gfapy.OrientedLine("3","+"), "*"))

  def test_search_duplicate_gfa1(self):
    # link
    self.assertEqual(TestUnitLineFinders.l_gfa1[4], TestUnitLineFinders.gfa1._search_duplicate(TestUnitLineFinders.l_gfa1[4]))
    # complement link
    self.assertEqual(TestUnitLineFinders.l_gfa1[4], TestUnitLineFinders.gfa1._search_duplicate(TestUnitLineFinders.l_gfa1[4].complement()))
    # containment
    self.assertEqual(None, TestUnitLineFinders.gfa1._search_duplicate(TestUnitLineFinders.l_gfa1[6]))
    # segment
    self.assertEqual(TestUnitLineFinders.l_gfa1[0], TestUnitLineFinders.gfa1._search_duplicate(TestUnitLineFinders.l_gfa1[0]))
    # path
    self.assertEqual(TestUnitLineFinders.l_gfa1[7], TestUnitLineFinders.gfa1._search_duplicate(TestUnitLineFinders.l_gfa1[7]))

  def test_search_duplicate_gfa2(self):
    # line with mandatory name
    self.assertEqual(TestUnitLineFinders.l_gfa2[0], TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[0]))
    # line with optional name, present
    self.assertEqual(TestUnitLineFinders.l_gfa2[2], TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[2]))
    self.assertEqual(TestUnitLineFinders.l_gfa2[3], TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[3]))
    self.assertEqual(TestUnitLineFinders.l_gfa2[4], TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[4]))
    self.assertEqual(TestUnitLineFinders.l_gfa2[5], TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[5]))
    # line with optional name, not present
    self.assertEqual(None, TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[11]))
    # line with no name
    self.assertEqual(None, TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[6]))
    self.assertEqual(None, TestUnitLineFinders.gfa2._search_duplicate(TestUnitLineFinders.l_gfa2[9]))
