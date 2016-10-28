# A comment line of a RGFA file
class RGFA::Line::Comment < RGFA::Line

  RECORD_TYPE = :"#"
  POSFIELDS = [:content]
  PREDEFINED_TAGS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :content => :comment,
  }

  define_field_methods!

  def to_s
    "##{content}"
  end

end
