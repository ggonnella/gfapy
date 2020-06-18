import gfapy
import builtins
from .validator import Validator
from .parser import Parser
from .writer import Writer
from . import alignment_gfa1                as field_alignment_gfa1
from . import alignment_gfa2                as field_alignment_gfa2
from . import alignment_list_gfa1           as field_alignment_list_gfa1
from . import byte_array                    as field_byte_array
from . import char                          as field_char
from . import comment                       as field_comment
from . import custom_record_type            as field_custom_record_type
from . import float                         as field_float
from . import generic                       as field_generic
from . import identifier_gfa2               as field_identifier_gfa2
from . import oriented_identifier_gfa2      as field_oriented_identifier_gfa2
from . import identifier_list_gfa2          as field_identifier_list_gfa2
from . import integer                       as field_integer
from . import json                          as field_json
from . import numeric_array                 as field_numeric_array
from . import optional_identifier_gfa2      as field_optional_identifier_gfa2
from . import optional_integer              as field_optional_integer
from . import orientation                   as field_orientation
from . import oriented_identifier_list_gfa1 as field_oriented_identifier_list_gfa1
from . import oriented_identifier_list_gfa2 as field_oriented_identifier_list_gfa2
from . import path_name_gfa1                as field_path_name_gfa1
from . import position_gfa1                 as field_position_gfa1
from . import position_gfa2                 as field_position_gfa2
from . import segment_name_gfa1             as field_segment_name_gfa1
from . import sequence_gfa1                 as field_sequence_gfa1
from . import sequence_gfa2                 as field_sequence_gfa2
from . import string                        as field_string

class Field(Validator, Parser, Writer):
  """
  Support for the decoding, validation and encoding of data in GFA fields.

  Classes are defined (and imported here) for each type of field (positional and
  tags) defined in the GFA specifications. The field definition classes
  implement the following methods:

  * ``decode(str)``: decodes the content of a GFA field into a Python object
      which represents the value; the content of the field is validated and
      the returned object is guaranteed to be valid
  * ``unsafe_decode(str)``: an optional method, which decodes the content
      of the string faster than decode(), but does not perform validations
  * ``validate_encoded(str)``: validates the content of a GFA field, when this
      is in its string form; it can be called by the decode() method
  * ``validate_decoded(obj)``: validates the content of a GFA field, when this
      is in a non-string form; it can be called by the encode() method
  * ``encode(obj)``: takes a non-string content of a GFA field and converts it
      in its string representation according to the GFA specification; the
      returned string is guaranteed to be valid
  * ``unsafe_encode(obj)``: an optional method, which encodes the content
      of a non-string field faster than encode(), but does not perform
      validations

  Notes:
    The library user does not call these methods directly, as the interaction
    is done using the interface of the `~gfapy.line.line.Line` class.
    However, an user may define classes for custom datatypes, to be used with
    custom record types.
  """

  _default_tag_datatypes = [
    (builtins.int , "i"),
    (builtins.float , "f"),
    (builtins.dict , "J"),
    (builtins.list , "J"),
    (builtins.object , "Z")
  ]
  """Default tag datatype to be used if the value is of a built-in class.

  For non build-in classes, the _default_gfa_tag_datatype() method of the
  class is called instead.
  """

  GFA1_POSFIELD_DATATYPE = [
                             "alignment_gfa1",
                             "alignment_list_gfa1",
                             "oriented_identifier_list_gfa1",
                             "position_gfa1",
                             "segment_name_gfa1",
                             "sequence_gfa1",
                             "path_name_gfa1",
                           ]
  """The names of the GFA1-specific datatypes for positional fields."""

  GFA2_POSFIELD_DATATYPE = [
                             "alignment_gfa2",
                             "generic",
                             "identifier_gfa2",
                             "oriented_identifier_gfa2",
                             "identifier_list_gfa2",
                             "oriented_identifier_list_gfa2",
                             "optional_identifier_gfa2",
                             "position_gfa2",
                             "custom_record_type",
                             "sequence_gfa2",
                             "optional_integer",
                           ]
  """The names of the GFA2-specific datatypes for positional fields."""

  GFAX_POSFIELD_DATATYPE = [ "comment", "orientation" ]
  """The names of the non version-specific datatypes for positional fields."""

  POSFIELD_DATATYPE = GFA1_POSFIELD_DATATYPE + \
                      GFA2_POSFIELD_DATATYPE + \
                      GFAX_POSFIELD_DATATYPE
  """The names of all datatypes for positional fields."""

  TAG_DATATYPE = ["A", "i", "f", "Z", "J", "H", "B"]
  """The names of all datatypes for tags."""

  FIELD_DATATYPE = TAG_DATATYPE + POSFIELD_DATATYPE
  """The names of all datatypes for positional fields and tags."""

  FIELD_MODULE = {
    "alignment_gfa1"                 : field_alignment_gfa1,
    "alignment_gfa2"                 : field_alignment_gfa2,
    "alignment_list_gfa1"            : field_alignment_list_gfa1,
    "byte_array"                     : field_byte_array,
    "char"                           : field_char,
    "comment"                        : field_comment,
    "custom_record_type"             : field_custom_record_type,
    "float"                          : field_float,
    "generic"                        : field_generic,
    "identifier_gfa2"                : field_identifier_gfa2,
    "oriented_identifier_gfa2"       : field_oriented_identifier_gfa2,
    "identifier_list_gfa2"           : field_identifier_list_gfa2,
    "integer"                        : field_integer,
    "json"                           : field_json,
    "numeric_array"                  : field_numeric_array,
    "optional_identifier_gfa2"       : field_optional_identifier_gfa2,
    "optional_integer"               : field_optional_integer,
    "orientation"                    : field_orientation,
    "oriented_identifier_list_gfa1"  : field_oriented_identifier_list_gfa1,
    "oriented_identifier_list_gfa2"  : field_oriented_identifier_list_gfa2,
    "path_name_gfa1"                 : field_path_name_gfa1,
    "position_gfa1"                  : field_position_gfa1,
    "position_gfa2"                  : field_position_gfa2,
    "segment_name_gfa1"              : field_segment_name_gfa1,
    "sequence_gfa1"                  : field_sequence_gfa1,
    "sequence_gfa2"                  : field_sequence_gfa2,
    "string"                         : field_string,
    "H"    : field_byte_array,
    "A"    : field_char,
    "f"    : field_float,
    "i"    : field_integer,
    "J"    : field_json,
    "B"    : field_numeric_array,
    "Z"    : field_string,
  }
  """Assignment of a class for the parsing, validation and encoding of data.

  The dictionary contains keys for each GFA datatype; the value is a class name,
  which provides the encoding, decoding and validation methods.

  For simplicity of use, tag datatypes are present twice, once with a
  one-letter symbol (such as i) and once with a longer labe; (such as integer).
  """

  # Returns the default GFA tag for the given object.
  @staticmethod
  def _get_default_gfa_tag_datatype(obj):
    """Default GFA tag datatype for a given object

    Parameters:
      obj : an object of any Python class

    Returns:
      str : the identifier of a datatype (one of the keys of FIELD_MODULE)
        to be used for a tag with obj as value, if a datatype has not
        been specified by the user
    """
    if getattr(obj, "_default_gfa_tag_datatype",None):
      return obj._default_gfa_tag_datatype()
    else:
      if isinstance(obj, list) and\
             (all([isinstance(v, builtins.int) for v in obj]) or
              all([isinstance(v, builtins.float) for v in obj])):
        return "B"
      for k,v in gfapy.Field._default_tag_datatypes:
        if isinstance(obj, k):
          return v
      return "J"

  @classmethod
  def register_datatype(cls, name, klass):
    """Register a custom-defined datatype class

    Parameters:
      name (str) : the identifier to be used for the datatype. This is
        to be used in the field datatype declaration of extensions
        definining custom records, which use this custom datatype
      klass (class) : the class which provide the decode, encode,
        validate_encoded and validate_decoded methods for handling
        data of the custom datatype
    """
    cls.GFA2_POSFIELD_DATATYPE.append(name)
    cls.FIELD_MODULE[name] = klass

