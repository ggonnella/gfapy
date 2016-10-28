# A comment line of a RGFA file
class RGFA::Line::Comment < RGFA::Line

  RECORD_TYPE = :"#"
  versions = [:"1.0", :"2.0", :generic]
  posfields = {}
  versions.each {|v| posfields[v] = [:content]}
  POSFIELDS = posfields
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
