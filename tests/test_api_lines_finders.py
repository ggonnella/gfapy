import gfapy
import unittest

class TestAPILinesFinders(unittest.TestCase):

  l_gfa1_a = ["S\t1\t*",
              "S\t2\t*",
              "S\t3\t*",
              "S\t4\tCGAT",
              "L\t1\t+\t2\t+\t*",
              "L\t1\t-\t3\t+\t*",
              "C\t1\t-\t4\t-\t1\t*",
              "P\tp1\t1+,2+\t*"]
  l_gfa1 = [gfapy.Line(x) for x in l_gfa1_a]
  l_gfa2_a = ["S\t1\t100\t*",
              "S\t2\t110\t*",
              "E\te1\t1+\t2-\t0\t100$\t10\t110$\t*",
              "G\tg1\t1-\t2-\t1000\t*",
              "O\to1\t1+ 2-",
              "U\tu1\t1 e1",
              "F\t1\tread1-\t0\t10\t102\t122\t*",
              "F\t1\tread1-\t30\t100$\t180\t255\t*",
              "F\t2\tread1-\t40\t50\t52\t64\t*",
              "X\tx1\txx:Z:A",
              "X\tx2",
              "G\t*\t1+\t2+\t2000\t*"]
  l_gfa2 = [gfapy.Line(x) for x in l_gfa2_a]
  gfa1 = gfapy.Gfa(l_gfa1)
  gfa2 = gfapy.Gfa(l_gfa2)

  def test_segment_gfa1(self):
    # existing name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.segment("1"))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.try_get_segment("1"))
    # not existing name as argument
    self.assertEqual(None,TestAPILinesFinders.gfa1.segment("0"))
    with self.assertRaises(gfapy.NotFoundError): TestAPILinesFinders.gfa1.try_get_segment("0")
    # line as argument
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.segment(TestAPILinesFinders.l_gfa1[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.try_get_segment(TestAPILinesFinders.l_gfa1[0]))
    # connection to rgfa is not checked if argument is line
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa1.segment(TestAPILinesFinders.l_gfa2[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa1.try_get_segment(TestAPILinesFinders.l_gfa2[0]))

  def test_segment_gfa2(self):
    # existing name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.segment("1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.try_get_segment("1"))
    # not existing name as argument
    self.assertEqual(None,TestAPILinesFinders.gfa2.segment("0"))
    with self.assertRaises(gfapy.NotFoundError): TestAPILinesFinders.gfa2.try_get_segment("0")
    # line as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.segment(TestAPILinesFinders.l_gfa2[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.try_get_segment(TestAPILinesFinders.l_gfa2[0]))
    # connection to rgfa is not checked if argument is line
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa2.segment(TestAPILinesFinders.l_gfa1[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa2.try_get_segment(TestAPILinesFinders.l_gfa1[0]))

  def test_line_gfa1(self):
    # segment name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.line("1"))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.try_get_line("1"))
    # path name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa1[7],TestAPILinesFinders.gfa1.line("p1"))
    self.assertEqual(TestAPILinesFinders.l_gfa1[7],TestAPILinesFinders.gfa1.try_get_line("p1"))
    # not existing name as argument
    self.assertEqual(None,TestAPILinesFinders.gfa1.line("0"))
    with self.assertRaises(gfapy.NotFoundError): TestAPILinesFinders.gfa1.try_get_line("0")
    # line as argument
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.line(TestAPILinesFinders.l_gfa1[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa1.try_get_line(TestAPILinesFinders.l_gfa1[0]))
    # connection to rgfa is not checked if argument is line
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa1.line(TestAPILinesFinders.l_gfa2[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa1.try_get_line(TestAPILinesFinders.l_gfa2[0]))

  def test_line_gfa2(self):
    # segment name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.line("1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.try_get_line("1"))
    # edge name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[2],TestAPILinesFinders.gfa2.line("e1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[2],TestAPILinesFinders.gfa2.try_get_line("e1"))
    # gap name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[3],TestAPILinesFinders.gfa2.line("g1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[3],TestAPILinesFinders.gfa2.try_get_line("g1"))
    # path name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[4],TestAPILinesFinders.gfa2.line("o1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[4],TestAPILinesFinders.gfa2.try_get_line("o1"))
    # set name as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[5],TestAPILinesFinders.gfa2.line("u1"))
    self.assertEqual(TestAPILinesFinders.l_gfa2[5],TestAPILinesFinders.gfa2.try_get_line("u1"))
    # not existing name as argument
    self.assertIsNone(TestAPILinesFinders.gfa2.line("0"))
    with self.assertRaises(gfapy.NotFoundError): TestAPILinesFinders.gfa2.try_get_line("0")
    # line as argument
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.line(TestAPILinesFinders.l_gfa2[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa2[0],TestAPILinesFinders.gfa2.try_get_line(TestAPILinesFinders.l_gfa2[0]))
    # connection to rgfa is not checked if argument is line
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa2.line(TestAPILinesFinders.l_gfa1[0]))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0],TestAPILinesFinders.gfa2.try_get_line(TestAPILinesFinders.l_gfa1[0]))

  def test_fragments_for_external(self):
    self.assertEqual(TestAPILinesFinders.l_gfa2[6:9], TestAPILinesFinders.gfa2.fragments_for_external("read1"))
    self.assertEqual([], TestAPILinesFinders.gfa2.fragments_for_external("read2"))

  def test_select_by_hash_gfa1(self):
    # search segments
    self.assertEqual(set(TestAPILinesFinders.l_gfa1_a[0:4]),
        set([str(x) for x in TestAPILinesFinders.gfa1.select({"record_type":"S",
                                                "sequence":"CGAT"})]))
    self.assertEqual(TestAPILinesFinders.l_gfa1[0:1], TestAPILinesFinders.gfa1.select({"record_type":"S",
                                                "name":"1"}))
    # search links
    self.assertEqual(TestAPILinesFinders.l_gfa1[4:5], TestAPILinesFinders.gfa1.select({"record_type":"L",
                                                "from_segment":"1",
                                                "from_orient":"+"}))
    # search containments
    self.assertEqual(TestAPILinesFinders.l_gfa1[6:7], TestAPILinesFinders.gfa1.select({"record_type":"C",
                                                "from_segment":"1",
                                                "pos":1}))
    # search paths
    self.assertEqual(TestAPILinesFinders.l_gfa1[7:8], TestAPILinesFinders.gfa1.select({"record_type":"P",
                                                "segment_names":"1+,2+"}))
    # no record type specified
    self.assertEqual(TestAPILinesFinders.l_gfa1[0:1], TestAPILinesFinders.gfa1.select({"name":"1"}))
    self.assertEqual(TestAPILinesFinders.l_gfa1[4:7],
        TestAPILinesFinders.gfa1.select({"from_segment":"1"}))
    # reference as value
    self.assertEqual(TestAPILinesFinders.l_gfa1[4:7],
        TestAPILinesFinders.gfa1.select({"from_segment":TestAPILinesFinders.l_gfa1[0]}))
    # placeholder is equal to any value
    self.assertEqual(set(TestAPILinesFinders.l_gfa1_a[0:3]),
        set([str(x) for x in TestAPILinesFinders.gfa1.select({"sequence":"ACC"})]))

  def test_select_by_line_gfa1(self):
    for i in range(len(TestAPILinesFinders.l_gfa1)):
      self.assertEqual(TestAPILinesFinders.l_gfa1[i:i+1],
          TestAPILinesFinders.gfa1.select(TestAPILinesFinders.l_gfa1[i]))

  def test_select_by_hash_gfa2(self):
    # search segments
    self.assertEqual(set(TestAPILinesFinders.l_gfa2_a[0:2]),
        set([str(x) for x in TestAPILinesFinders.gfa2.select({"record_type":"S",
                                                "sequence":"CGAT"})]))
    self.assertEqual(TestAPILinesFinders.l_gfa2[1:2], TestAPILinesFinders.gfa2.select({"record_type":"S",
                                                "slen":110}))
    # search edges
    self.assertEqual(TestAPILinesFinders.l_gfa2[2:3], TestAPILinesFinders.gfa2.select({"record_type":"E",
                                                "sid1":gfapy.OrientedLine("1","+")}))
    # search gaps
    self.assertEqual(TestAPILinesFinders.l_gfa2[3:4], TestAPILinesFinders.gfa2.select({"record_type":"G",
                                                "sid1":gfapy.OrientedLine("1","-")}))
    self.assertEqual(TestAPILinesFinders.l_gfa2[11:12], TestAPILinesFinders.gfa2.select({"record_type":"G",
                                                "disp":2000}))
    # search paths
    self.assertEqual(TestAPILinesFinders.l_gfa2[4:5], TestAPILinesFinders.gfa2.select({"record_type":"O",
                                                "items":"1+ 2-"}))
    # search sets
    self.assertEqual(TestAPILinesFinders.l_gfa2[5:6], TestAPILinesFinders.gfa2.select({"record_type":"U",
                                                "name":"u1"}))
    # search fragments
    self.assertEqual(TestAPILinesFinders.l_gfa2[6:9], TestAPILinesFinders.gfa2.select({"record_type":"F",
                                                "external":"read1-"}))
    # search custom records
    self.assertEqual(TestAPILinesFinders.l_gfa2[9:10], TestAPILinesFinders.gfa2.select({"record_type":"X",
                                                "xx":"A"}))

  def test_select_by_line_gfa2(self):
    for i in range(len(TestAPILinesFinders.l_gfa2)):
      self.assertEqual(TestAPILinesFinders.l_gfa2[i:i+1],
          TestAPILinesFinders.gfa2.select(TestAPILinesFinders.l_gfa2[i]))

