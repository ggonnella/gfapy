#
# Version attribute and support of the conversion of GFA1 lines to GFA2 and
# vice-versa.
#
# @tested_in api_version, api_version_conversion
#
module RGFA::Line::Common::VersionConversion

  # @!attribute [r] version
  #   @return [RGFA::VERSIONS, nil] GFA specification version
  attr_reader :version

  [:gfa1, :gfa2].each do |shall_version|
    # @note RGFA::Line subclasses do not usually redefine this method, but
    #   the corresponding versioned to_a method
    # @return [String] a string representation of self
    define_method :"to_#{shall_version}_s" do
      send(:"to_#{shall_version}_a").join(RGFA::Line::SEPARATOR)
    end

    # @return [RGFA::Line] convertion to the selected version
    define_method :"to_#{shall_version}" do
      v = (shall_version == :gfa1) ? :gfa1 : :gfa2
      if (v == version)
        return self
      else
        send(:"to_#{shall_version}_a").to_rgfa_line(version: v, vlevel: @vlevel)
      end
    end
  end

  # @api private
  module API_PRIVATE
    [:gfa1, :gfa2].each do |shall_version|

      # @note RGFA::Line subclasses can redefine this method to convert
      #   between versions
      # @return [Array<String>] an array of string representations of the fields
      define_method :"to_#{shall_version}_a" do
        send(:to_a)
      end

    end
  end
  include API_PRIVATE
end
