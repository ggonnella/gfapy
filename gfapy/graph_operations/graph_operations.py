import gfapy
from .linear_paths import LinearPaths
from .multiplication import Multiplication
from .redundant_linear_paths import RedundantLinearPaths
from .topology import Topology
class GraphOperations(LinearPaths,Multiplication,RedundantLinearPaths,Topology):
  pass
