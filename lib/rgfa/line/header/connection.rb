module RGFA::Line::Header::Connection

  def connect(rgfa)
    raise RGFA::RuntimeError,
      "RGFA::Line::Header instances cannot be connected\n"+
      "Use RGFA#header.merge(this_line) to add the information\n"+
      "contained in this header line to the header of a RGFA instance."
  end

end
