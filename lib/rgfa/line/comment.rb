# A comment line of a RGFA file
class RGFA::Line::Comment < RGFA::Line

  RECORD_TYPE = :"#"
  versions = [:"1.0", :"2.0", :generic]
  reqfields = {}
  versions.each {|v| reqfields[v] = [:content]}
  REQFIELDS = reqfields
  PREDEFINED_OPTFIELDS = []
  FIELD_ALIAS = {}
  DATATYPE = {
    :content => :any,
  }

  define_field_methods!

  def to_s
    "##{content}"
  end

end
