import json
from copy import deepcopy

class Cloning:

  def clone(self):
    """Copy of a gfapy.Line instance.
    The copy will be disconnected, ie do not belong to the GFA and do not
    contain cross-references to other lines. This allows to edit the line
    (eg. changing the unique ID) before adding it.
    To achieve this, all reference fields are copied in their string
    representation.
    All other fields are copied as they are, and a deep copy is done for
    arrays, strings and JSON fields.

    Returns
    -------
    gfapy.Line
    """
    data_cpy = {}
    for k,v in self._data.items():
      if k in self.__class__.REFERENCE_FIELDS:
        data_cpy[k] = self.field_to_s(k)
      elif self._field_datatype(k) == "J":
        data_cpy[k] = json.loads(json.dumps(v))
      elif isinstance(v, list) or isinstance(v, str):
        data_cpy[k] = deepcopy(v)
      else:
        data_cpy[k] = v
    cpy = self.__class__(data_cpy, vlevel = self.vlevel,
                         virtual = self.virtual, version = self.version)
    cpy._datatype = self._datatype.copy()
    # cpy._refs and cpy._gfa are not set, so that the cpy is disconnected
    return cpy
