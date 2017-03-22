import unittest
import gfapy

class TestLineEdge(unittest.TestCase):

  def test_to_gfa1(self):
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
