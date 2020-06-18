import gfapy
from types import MethodType

class DynamicField:
  def __init__(self, get, set):
    self.get = get
    self.set = set

class DynamicFields:
  """
  Methods are dynamically created for non-existing but valid tag names.
  Methods for predefined tags and positional fields
  are created dynamically for each subclass; methods for existing tags
  are created on instance initialization.
  """

  def __getattribute__(self, name):
    try:
      attr = super().__getattribute__(name)
      if not isinstance(attr, DynamicField):
        return attr
      else:
        return attr.get(self)
    except AttributeError as err:
      return self._get_dynamic_field(name, err)

  def __setattr__(self, name, value):
    try:
      attr = super().__getattribute__(name)
      if not isinstance(attr, DynamicField):
        return super().__setattr__(name, value)
      else:
        attr.set(self, value)
    except AttributeError:
      return self._set_dynamic_field(name, value)

  def _get_dynamic_field(self, name, err):
    if self.virtual:
      raise err
    if name.startswith("try_get_"):
      name = name[8:]
      try_get = True
    else:
      try_get = False
    if name in self._data:
      return (lambda : self.try_get(name)) if try_get else self.get(name)
    if (name in self.__class__.PREDEFINED_TAGS or
        self._is_valid_custom_tagname(name)):
      if not try_get:
        return None
      else:
        raise gfapy.NotFoundError(
          "No value defined for tag {}".format(name))
    else:
      raise err

  def _set_dynamic_field(self, name, value):
    try:
      virtual = super().__getattribute__("_virtual")
      data = super().__getattribute__("_data")
      if virtual:
        super().__setattr__(name, value)
      if name in data:
        self._set_existing_field(name, value)
      if (name in self.__class__.PREDEFINED_TAGS or
            self._is_valid_custom_tagname(name)):
        self.set(name, value)
      else:
        super().__setattr__(name, value)
    except AttributeError:
      super().__setattr__(name, value)

  def _define_field_methods(self, fieldname):
    """Define field methods for a single field"""
    def getter(self):
      return self.get(fieldname)
    def try_get(self):
      return self.try_get(fieldname)
    def setter(self, value):
      self._set_existing_field(fieldname, value)
    super().__setattr__(fieldname, DynamicField(getter, setter))
    super().__setattr__("try_get_" + fieldname, MethodType(try_get, self))

# XXX: class methods are missing
