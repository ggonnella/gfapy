import gfapy
import builtins
import re
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


class Field:

  # Decoding, validation and encoding of GFA fields.
  #
  # For each datatype a module under field/ exists, which defines
  # the following methods as module functions:
  #
  # unsafe_decode => parses an ASSUMED VALID string representation to
  #                  an appropriate Ruby object
  #                  - faster or as fast as decode()
  #                  - if the assumption is not met, sometimes it will
  #                  raise an exception, sometimes it will return an
  #                  invalid object
  #
  # decode => parses a string representation to an appropriate Ruby object
  #           - if the string is invalid, an exception is raised
  #           - the returned object is guaranteed to be valid
  #
  # validate_encoded => validates a string representation
  #                     - raises FormatError if invalid
  #
  # validate_decoded => validates a non-string field content
  #                     - raises exception if its state is invalid
  #
  # unsafe_encode => encodes an ASSUMED VALID field to the string representation;
  #                  - faster or as fast as encode()
  #                  - if the assumption is not met, sometimes it will
  #                  raise an exception, sometimes it will return an
  #                  invalid string representation
  #
  # encode => encodes a field to its string representation;
  #           - raises an exception if the field content is invalid
  #           - the string representation is guaranteed to be valid;
  #
  # Everything in the Field module is API private. The user will not call
  # these methods directly, and use instead methods of Line.
  # Also: code in line.rb should not call the functions of the submodules
  # defined in the field/* files directly, but rather call the functions of
  # the submodules defined in this file, ie Field Parser,
  # Field Validator, Field Writer.
  #

  # Default tags for built-in datatypes.
  # Custom classes should implement the default_gfa_tag_datatype() function.
  _default_tag_datatypes = [
    (builtins.int , "i"),
    (builtins.float , "f"),
    (builtins.dict , "J"),
    (builtins.list , "J"),
    (builtins.object , "Z")
  ]

  # Symbol representing a GFA1-specific datatype for positional fields
  GFA1_POSFIELD_DATATYPE = [
                             "alignment_gfa1",
                             "alignment_list_gfa1",
                             "oriented_identifier_list_gfa1",
                             "position_gfa1",
                             "segment_name_gfa1",
                             "sequence_gfa1",
                             "path_name_gfa1",
                           ]

  # Symbol representing a GFA2-specific datatype for positional fields
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

  # Symbol representing a datatype for positional fields common to GFA1 and GFA2
  GFAX_POSFIELD_DATATYPE = [ "comment", "orientation" ]

  # Symbol representing a datatype for positional fields
  POSFIELD_DATATYPE = GFA1_POSFIELD_DATATYPE + \
                      GFA2_POSFIELD_DATATYPE + \
                      GFAX_POSFIELD_DATATYPE

  # A symbol representing a datatype for tags
  TAG_DATATYPE = ["A", "i", "f", "Z", "J", "H", "B"]

  # A symbol representing a valid datatype
  FIELD_DATATYPE = TAG_DATATYPE + POSFIELD_DATATYPE

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

  # Returns the default GFA tag for the given object.
  def get_default_gfa_tag_datatype(obj):
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

  from .parser import parse_gfa_field
  from .parser import parse_gfa_tag
  from .writer import to_gfa_field
  from .writer import to_gfa_tag
  from .validator.decoded import validate_decoded_gfa_field
  from .validator.encoded import validate_encoded_gfa_field

  def validate_gfa_field(obj, datatype, fieldname = None):
    if isinstance(obj, str):
      gfapy.Field.validate_encoded_gfa_field(obj, datatype, fieldname)
    else:
      gfapy.Field.validate_decoded_gfa_field(obj, datatype, fieldname)

  @classmethod
  def register_datatype(cls, name, klass):
    cls.GFA2_POSFIELD_DATATYPE.append(name)
    cls.FIELD_MODULE[name] = klass

