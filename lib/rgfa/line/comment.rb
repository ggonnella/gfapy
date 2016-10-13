# A comment line of a RGFA file
class RGFA::Line::Comment < RGFA::Line

  RECORD_TYPE = :"#"
  REQFIELDS = [:content]
  PREDEFINED_OPTFIELDS = []
  DATATYPE = {
    :content => :any,
  }

  define_field_methods!

  def to_s
    "##{content}"
  end

end
