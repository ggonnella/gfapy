import unittest
import gfapy

class TestUnitAlignment(unittest.TestCase):

  cigar_1 = gfapy.CIGAR([
      gfapy.CIGAR.Operation(12,"M"),
      gfapy.CIGAR.Operation(1,"D"),
      gfapy.CIGAR.Operation(2,"I"),
      gfapy.CIGAR.Operation(0,"M"),
      gfapy.CIGAR.Operation(1,"P")])

  cigar_1_a = [
     gfapy.CIGAR.Operation(12,"M"),
     gfapy.CIGAR.Operation(1,"D"),
     gfapy.CIGAR.Operation(2,"I"),
     gfapy.CIGAR.Operation(0,"M"),
     gfapy.CIGAR.Operation(1,"P")]

  cigar_1_s = "12M1D2I0M1P"

  trace_1 = gfapy.Trace([12,12,0])
  trace_1_s = "12,12,0"
  trace_1_a = [12,12,0]

  def test_list_to_alignment(self):
    assert(isinstance(gfapy.Alignment([]),gfapy.AlignmentPlaceholder))
    self.assertEqual(TestUnitAlignment.cigar_1, gfapy.Alignment(TestUnitAlignment.cigar_1_a))
    self.assertRaises(gfapy.VersionError, gfapy.Alignment, TestUnitAlignment.trace_1_a, version="gfa1")
    self.assertEqual(TestUnitAlignment.trace_1, gfapy.Alignment(TestUnitAlignment.trace_1_a, version="gfa2"))
    self.assertRaises(gfapy.VersionError, gfapy.Alignment, TestUnitAlignment.cigar_1_a, version="gfaX")
    self.assertRaises(gfapy.FormatError, gfapy.Alignment, ["x",2,1])
    # only the first element is checked, therefore:
    malformed1 = [1,2,"x"]
    gfapy.Alignment(malformed1, version="gfa2") # nothing raised
    assert(isinstance(gfapy.Alignment(malformed1, version="gfa2"), gfapy.Trace))
    self.assertRaises(gfapy.TypeError, gfapy.Alignment(malformed1, version="gfa2").validate)
    malformed2 = [gfapy.CIGAR.Operation(12,"M"),2,"x"]
    gfapy.Alignment(malformed2) # nothing raised
    assert(isinstance(gfapy.Alignment(malformed2),gfapy.CIGAR))
    self.assertRaises(gfapy.TypeError, gfapy.Alignment(malformed2).validate)

  def test_cigar_from_string(self):
    self.assertEqual(TestUnitAlignment.cigar_1,
        gfapy.CIGAR._from_string(TestUnitAlignment.cigar_1_s))
    assert(isinstance(gfapy.CIGAR._from_string("*"),
      gfapy.AlignmentPlaceholder))
    self.assertEqual(TestUnitAlignment.cigar_1,
        gfapy.CIGAR(TestUnitAlignment.cigar_1_a))

  def test_trace_from_string(self):
    self.assertEqual(TestUnitAlignment.trace_1,
        gfapy.Trace._from_string(TestUnitAlignment.trace_1_s))
    self.assertRaises(gfapy.FormatError, gfapy.Trace._from_string, "A,1,2")

