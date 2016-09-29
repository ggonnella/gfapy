import unittest
import gfapy

class TestPlaceholder(unittest.TestCase):

  def test_str(self):
    self.assertEqual("*", str(gfapy.Placeholder()))
