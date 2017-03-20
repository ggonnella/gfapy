class Error(Exception):
  """Parent class for library-specific errors"""
  pass

class VersionError(Error):
  """Unknown/wrong version of the specification"""
  pass

class RuntimeError(Error):
  """The user tried to do something not allowed"""
  pass

class ValueError(Error):
  """An object has the right type/form, but an invalid content

  e.g. number out-of-range; string/array too big/small
  """
  pass

class FormatError(Error):
  """The format of an object is invalid

  e.g. a line contains too many/few fields;
       a tagname has the wrong format
  """
  pass

class TypeError(Error):
  """A wrong type has been used or specified

  e.g. a field contains an array instead of an integer;
       an invalid record type or datatype is found by parsing
  """
  pass

class ArgumentError(Error):
  """The argument of a method has the wrong type"""
  pass

class NotUniqueError(Error):
  """An element which should have been unique is not unique

  e.g. a tag name is duplicated in a line; a duplicated record ID is found
  """
  pass

class InconsistencyError(Error):
  """Contradictory information has been provided

  e.g. GFA1 segment LN and sequence length differ;
       a GFA2-only record is added to a GFA1 file
  """
  pass

class NotFoundError(Error):
  """An element which has been required is not found

  e.g. a tag or record which is required is not found
  """
  pass

class AssertionError(Error):
  """An assertion has failed

  An error of this kind indicates a probable bug.
  """
  pass
