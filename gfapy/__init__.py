VERSIONS = ["gfa1", "gfa2"]
DIALECTS = ["rgfa", "standard"]
from gfapy.error import *
from gfapy.placeholder import Placeholder
from gfapy.placeholder import is_placeholder
from gfapy.byte_array import ByteArray
from gfapy.field_array import FieldArray
from gfapy.alignment import Alignment
from gfapy.alignment.cigar import CIGAR
from gfapy.alignment.placeholder import AlignmentPlaceholder
from gfapy.alignment.trace import Trace
from gfapy.numeric_array import NumericArray
from gfapy.lastpos import LastPos
from gfapy.lastpos import isfirstpos, islastpos, posvalue
from gfapy.symbol_invert import invert
from gfapy.field import Field
from gfapy.line import Line
from gfapy.logger import Logger
from gfapy.segment_end_path import SegmentEndsPath
from gfapy.segment_end import *
from gfapy.oriented_line import OrientedLine
from gfapy.lines import Lines
from gfapy.graph_operations import GraphOperations
from gfapy.gfa import Gfa
import gfapy.sequence
import gfapy.field
