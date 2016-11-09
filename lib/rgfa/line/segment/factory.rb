#
# Factory of instances of the classes
# RGFA::Line::Segment::GFA1 and
# RGFA::Line::Segment::GFA2
#
class RGFA::Line::Segment::Factory < RGFA::Line::Segment

  def self.new(data, validate: 2, virtual: false, version: nil)
    if version == :"1.0"
      return RGFA::Line::Segment::GFA1.new(data,
               validate: validate, virtual: virtual, version: version)
    elsif version == :"2.0"
      return RGFA::Line::Segment::GFA2.new(data,
               validate: validate, virtual: virtual, version: version)
    elsif version.nil?
      begin
        return RGFA::Line::Segment::GFA1.new(data,
                 validate: validate, virtual: virtual, version: :"1.0")
      rescue => err_gfa1
        begin
          return RGFA::Line::Segment::GFA2.new(data,
                   validate: validate, virtual: virtual, version: :"2.0")
        rescue => err_gfa2
          raise RGFA::FormatError,
            "The segment line has an invalid format for both GFA1 and GFA2\n"+
            "GFA1 Error: #{err_gfa1.class}\n"+
          "#{err_gfa1.message}\n"+
          "GFA2 Error: #{err_gfa2.class}\n"+
          "#{err_gfa2.message}\n"
        end
      end
    else
      raise RGFA::VersionError,
        "GFA specification version unknown (#{version})"
    end
  end

end
