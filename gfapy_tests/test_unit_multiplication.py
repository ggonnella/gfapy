import gfapy
import unittest

class TestUnitMultiplication(unittest.TestCase):

  def test_auto_select_distribute_end_lB_eq_lE(self):
    g = gfapy.Gfa()
    # lB == lE == 1
    self.assertEqual(None, g._auto_select_distribute_end( 4, 1, 1, False))
    # lB == lE == factor
    self.assertEqual("R", g._auto_select_distribute_end( 4, 4, 4, False))
    # lB == lE; </> factor
    self.assertEqual("R", g._auto_select_distribute_end( 4, 2, 2, False))
    self.assertEqual("L", g._auto_select_distribute_end( 4, 6, 6, False))

  def test_auto_select_distribute_end_l_1(self):
    g = gfapy.Gfa()
    # lB or lE == 1, other </==/> factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 2, 1, False))
    self.assertEqual("L", g._auto_select_distribute_end( 4, 4, 1, False))
    self.assertEqual("L", g._auto_select_distribute_end( 4, 6, 1, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 1, 2, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 1, 4, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 1, 6, False))

  def test_auto_select_distribute_end_eq_factor(self):
    g = gfapy.Gfa()
    # one =, one > factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 4, 5, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 5, 4, False))
    # one =, one < factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 4, 3, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 3, 4, False))

  def test_auto_select_distribute_end_diff_factor(self):
    g = gfapy.Gfa()
    # both > 1; both < factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 3, 2, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 2, 3, False))
    # both > 1; both > factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 5, 6, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 6, 5, False))
    # both > 1; one <, one > factor
    self.assertEqual("L", g._auto_select_distribute_end( 4, 3, 5, False))
    self.assertEqual("R", g._auto_select_distribute_end( 4, 5, 3, False))

