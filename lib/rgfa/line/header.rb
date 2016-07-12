# A header line of a RGFA file
class RGFA::Line::Header < RGFA::Line

  RECORD_TYPE = "H"
  REQFIELDS = []
  PREDEFINED_OPTFIELDS = [:VN]
  DATATYPE = {
    :VN => :Z
  }

end
