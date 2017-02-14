import unittest
from copy import deepcopy
import gfapy

class TestApiAlignment(unittest.TestCase):

  cigar_1 = gfapy.CIGAR([
      gfapy.CIGAR.Operation(12,"M"),
      gfapy.CIGAR.Operation(1,"D"),
      gfapy.CIGAR.Operation(2,"I"),
      gfapy.CIGAR.Operation(0,"M"),
      gfapy.CIGAR.Operation(1,"P")])
  cigar_1_s = "12M1D2I0M1P"

  cigar_gfa1_1_s = "1S2M3I4=5X6D7P8N9H"
  cigar_gfa1_1_c_s = "9H8I7P6I5X4=3D2M1D"
  cigar_gfa1_1_rlen = 2+4+5+6+8
  cigar_gfa1_1_qlen = 1+2+3+4+5

  cigar_gfa2_1_s = "1M2I3D4P"
  cigar_gfa2_1_c_s = "4P3I2D1M"
  cigar_gfa2_1_rlen = 1+3
  cigar_gfa2_1_qlen = 1+2

  trace_1 = gfapy.Trace([12,12,0])
  trace_1_s = "12,12,0"

  cigar_invalid_value_1 = gfapy.CIGAR([
      gfapy.CIGAR.Operation(-12,"M"),
      gfapy.CIGAR.Operation(1,"D"),
      gfapy.CIGAR.Operation(2,"I")])
  cigar_invalid_value_2 = gfapy.CIGAR([
      gfapy.CIGAR.Operation(12, "Y"),
      gfapy.CIGAR.Operation(1,"D"),
      gfapy.CIGAR.Operation(2,"I")])
  cigar_invalid_type_1 = gfapy.CIGAR([
      "x",
      gfapy.CIGAR.Operation(1,"D"),
      gfapy.CIGAR.Operation(2,"I")])

  trace_invalid_value_1 = gfapy.Trace([-2,1,12])
  trace_invalid_type_1 = gfapy.Trace([12.0,1,12])

  cigar_empty = gfapy.CIGAR([])
  trace_empty = gfapy.Trace([])
  placeholder = gfapy.AlignmentPlaceholder()
  placeholder_s = "*"

  string_invalid = [
    "-12M1D2I", "12Y1D2I", "x1D2I",
    "-2,1,12", "12.0,1,12", "*x",
  ]

  cigar_op_1 = gfapy.CIGAR.Operation(1,"D")
  cigar_op_1_s = "1D"
  cigar_op_1_len = 1
  cigar_op_1_code = "D"
  cigar_op_2 = gfapy.CIGAR.Operation(2,"I")
  cigar_op_2_s = "2I"
  cigar_op_2_len = 2
  cigar_op_2_code = "I"

  def test_to_s(self):
    self.assertEqual(TestApiAlignment.cigar_1_s,     str(TestApiAlignment.cigar_1_s))
    self.assertEqual(TestApiAlignment.cigar_1_s,     str(TestApiAlignment.cigar_1))
    self.assertEqual(TestApiAlignment.trace_1_s,     str(TestApiAlignment.trace_1))
    self.assertEqual(TestApiAlignment.placeholder_s, str(TestApiAlignment.placeholder))
    self.assertEqual(TestApiAlignment.placeholder_s, str(TestApiAlignment.cigar_empty))
    self.assertEqual(TestApiAlignment.placeholder_s, str(TestApiAlignment.trace_empty))

  def test_cigar_clone(self):
    cigar1_clone = deepcopy(gfapy.Alignment(TestApiAlignment.cigar_1))
    self.assertEqual(TestApiAlignment.cigar_1_s, str(cigar1_clone))
    cigar1_clone[0].code = "="
    # copy is deep, only the clone has changed:
    self.assertNotEqual(TestApiAlignment.cigar_1_s, str(cigar1_clone))
    self.assertEqual(TestApiAlignment.cigar_1_s, str(TestApiAlignment.cigar_1))

  def test_to_alignment(self):
    self.assertEqual(TestApiAlignment.cigar_1,     gfapy.Alignment(TestApiAlignment.cigar_1_s))
    self.assertEqual(TestApiAlignment.trace_1,     gfapy.Alignment(TestApiAlignment.trace_1_s))
    self.assertEqual(TestApiAlignment.placeholder, gfapy.Alignment(TestApiAlignment.placeholder_s))
    for alignment in [TestApiAlignment.cigar_1, TestApiAlignment.trace_1, TestApiAlignment.cigar_empty,
        TestApiAlignment.trace_empty, TestApiAlignment.placeholder]:
      self.assertEqual(alignment, gfapy.Alignment(alignment))
    for string in TestApiAlignment.string_invalid:
      self.assertRaises(gfapy.FormatError, gfapy.Alignment, string)

  def test_decode_encode_invariant(self):
    for string in [TestApiAlignment.trace_1_s, TestApiAlignment.cigar_1_s, TestApiAlignment.placeholder_s]:
      self.assertEqual(string, str(gfapy.Alignment(string)))

  def test_is_placeholder(self):
    for a in [TestApiAlignment.cigar_empty, TestApiAlignment.trace_empty, TestApiAlignment.placeholder, TestApiAlignment.placeholder_s]:
      assert(gfapy.is_placeholder(a))
    for a in [TestApiAlignment.cigar_1, TestApiAlignment.cigar_1_s, TestApiAlignment.trace_1, TestApiAlignment.trace_1_s]:
      assert(not gfapy.is_placeholder(a))

  def test_validate(self):
    TestApiAlignment.trace_1.validate() # nothing raised
    TestApiAlignment.trace_empty.validate() # nothing raised
    TestApiAlignment.cigar_1.validate() # nothing raised
    TestApiAlignment.cigar_empty.validate() # nothing raised
    TestApiAlignment.placeholder.validate() # nothing raised
    self.assertRaises(gfapy.ValueError,TestApiAlignment.trace_invalid_value_1.validate)
    self.assertRaises(gfapy.ValueError,TestApiAlignment.cigar_invalid_value_1.validate)
    self.assertRaises(gfapy.ValueError,TestApiAlignment.cigar_invalid_value_2.validate)
    self.assertRaises(gfapy.TypeError,TestApiAlignment.trace_invalid_type_1.validate)
    self.assertRaises(gfapy.TypeError,TestApiAlignment.cigar_invalid_type_1.validate)

  def test_version_specific_validate(self):
    gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_s,
        version="gfa1", valid=False) # nothing raised
    self.assertRaises(gfapy.FormatError, gfapy.Alignment,
        TestApiAlignment.cigar_gfa1_1_s, version="gfa2", valid=False)
    gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_s,
        version="gfa1", valid=False) # nothing raised
    gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_s,
        version="gfa2", valid=False) # nothing raised

  def test_array_methods(self):
    for a in [TestApiAlignment.cigar_empty, TestApiAlignment.trace_empty]:
      assert(not a)
    for a in [TestApiAlignment.cigar_1, TestApiAlignment.trace_1]:
      assert(a)
    self.assertEqual(gfapy.CIGAR.Operation(1,"D"), TestApiAlignment.cigar_1[1])
    self.assertEqual(12, TestApiAlignment.trace_1[1])


  def test_cigar_operation_methods(self):
    self.assertEqual(TestApiAlignment.cigar_op_1_len, TestApiAlignment.cigar_op_1.length)
    self.assertEqual(TestApiAlignment.cigar_op_1_code, TestApiAlignment.cigar_op_1.code)
    self.assertEqual(TestApiAlignment.cigar_op_1_s, str(TestApiAlignment.cigar_op_1))
    TestApiAlignment.cigar_op_1.length =  TestApiAlignment.cigar_op_2_len
    TestApiAlignment.cigar_op_1.code = TestApiAlignment.cigar_op_2_code
    self.assertEqual(TestApiAlignment.cigar_op_2, TestApiAlignment.cigar_op_1)
    self.assertEqual(TestApiAlignment.cigar_op_2_len, TestApiAlignment.cigar_op_1.length)
    self.assertEqual(TestApiAlignment.cigar_op_2_code, TestApiAlignment.cigar_op_1.code)
    self.assertEqual(TestApiAlignment.cigar_op_2_s, str(TestApiAlignment.cigar_op_2))

  def test_cigar_operation_validation(self):
    TestApiAlignment.cigar_op_1.validate() # nothing raised
    TestApiAlignment.cigar_op_1.validate(version="gfa2") # nothing raised
    TestApiAlignment.cigar_op_2.validate() # nothing raised
    TestApiAlignment.cigar_op_2.validate(version="gfa2") # nothing raised
    self.assertRaises(gfapy.VersionError, TestApiAlignment.cigar_op_1.validate, version="gfaX")
    stringlen = gfapy.CIGAR.Operation("1", "M")
    stringlen.validate() # nothing raised
    stringcode = gfapy.CIGAR.Operation(1, "M")
    stringcode.validate() # nothing raised
    malformed1 = gfapy.CIGAR.Operation([1], "M")
    self.assertRaises(gfapy.TypeError, malformed1.validate)
    malformed2 = gfapy.CIGAR.Operation(-1, "M")
    self.assertRaises(gfapy.ValueError, malformed2.validate)
    malformed3 = gfapy.CIGAR.Operation(1, "L")
    self.assertRaises(gfapy.ValueError, malformed3.validate)
    gfa1only = gfapy.CIGAR.Operation(1, "X")
    gfa1only.validate() # nothing raised
    self.assertRaises(gfapy.ValueError, gfa1only.validate, version="gfa2")

  def test_cigar_complement(self):
    self.assertEqual(TestApiAlignment.cigar_gfa1_1_c_s,
                 str(gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_s, version="gfa1").complement()))
    self.assertEqual(TestApiAlignment.cigar_gfa2_1_c_s,
                 str(gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_s).complement()))

  def test_cigar_length_on(self):
    self.assertEqual(TestApiAlignment.cigar_gfa1_1_rlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_s,version="gfa1").
                 length_on_reference())
    self.assertEqual(TestApiAlignment.cigar_gfa1_1_qlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_s,version="gfa1").
                 length_on_query())
    self.assertEqual(TestApiAlignment.cigar_gfa1_1_qlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_c_s,version="gfa1").
                 length_on_reference())
    self.assertEqual(TestApiAlignment.cigar_gfa1_1_rlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa1_1_c_s,version="gfa1").
                 length_on_query())
    self.assertEqual(TestApiAlignment.cigar_gfa2_1_rlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_s).length_on_reference())
    self.assertEqual(TestApiAlignment.cigar_gfa2_1_qlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_s).length_on_query())
    self.assertEqual(TestApiAlignment.cigar_gfa2_1_qlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_c_s).length_on_reference())
    self.assertEqual(TestApiAlignment.cigar_gfa2_1_rlen,
                 gfapy.Alignment(TestApiAlignment.cigar_gfa2_1_c_s).length_on_query())

