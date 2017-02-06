import unittest
from gfapy import *

class TestApiPlaceholders(unittest.TestCase):

  def test_str(self):
    self.assertEqual("*", str(Placeholder()))

  def test_is_placeholder(self):
    self.assertTrue(is_placeholder(Placeholder()))
    self.assertTrue(is_placeholder("*"))
    self.assertTrue(is_placeholder([]))
    self.assertFalse(is_placeholder("a"))
    self.assertFalse(is_placeholder("**"))
    self.assertFalse(is_placeholder(1))
    self.assertFalse(is_placeholder(1.0))
    self.assertFalse(is_placeholder(["x"]))

  def test_compatibility_methods(self):
    p = Placeholder()
    self.assertTrue(p.is_empty())
    self.assertTrue(is_placeholder(p))
    self.assertEqual(0, len(p))
    self.assertTrue(is_placeholder(p.rc()))
    self.assertTrue(is_placeholder(p + 1))
    self.assertTrue(is_placeholder(p[0]))
