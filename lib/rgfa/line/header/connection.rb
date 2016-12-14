module RGFA::Line::Header::Connection

  # @api private
  module API_PRIVATE

    # Connect is not allowed for header lines except for the single header
    # instance created during initialization of the RGFA
    #
    # @raise [RGFA::RuntimeError] always, except during RGFA initialization
    #
    # @return [nil]
    def connect(rgfa)
      unless rgfa.header.eql?(self)
        raise RGFA::RuntimeError,
          "RGFA::Line::Header instances cannot be connected\n"+
          "Use RGFA#add_line(this_line) to add the information\n"+
          "contained in this header line to the header of a RGFA instance."
      else
        @rgfa = rgfa
      end
      return nil
    end

  end

  include API_PRIVATE

end
