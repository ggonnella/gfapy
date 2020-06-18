from .artifacts import Artifacts
from .copy_number import CopyNumber
from .invertible_segments import InvertibleSegments
from .p_bubbles import PBubbles
from .linear_paths import LinearPaths
from .multiplication import Multiplication
from .redundant_linear_paths import RedundantLinearPaths
from .superfluous_links import SuperfluousLinks
from .topology import Topology
class GraphOperations(LinearPaths,Multiplication,RedundantLinearPaths,
    Topology,Artifacts,CopyNumber,InvertibleSegments,PBubbles,SuperfluousLinks):
  pass
