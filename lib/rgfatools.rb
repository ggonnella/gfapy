require "rgfa"

#
# Module defining additional methods for the RGFA class.
#
# RGFATools is an extension to the RGFA library, which allow to perform further
# operations. Thereby additional conventions are required, with respect to the
# GFA specification, which are compatible with it.
#
# The methods defined here allow, e.g., to randomly orient a segment which has
# the same connections on both sides, to compute copy numbers and multiply or
# delete segments according to them, to distribute the links of copies after
# multipling a segment, or to eliminate edges in the graph which are
# incompatible with an hamiltonian path.
#
# Custom optional fields are defined, such as "cn" for the copy number of a
# segment, "or" for the original segment(s) of a duplicated or merged segment,
# "mp" for the starting position of original segments in a merged segment, "rp"
# for the position of possible inversions due to arbitrary orientation of some
# segments by the program.
#
# Furthermore a convention for the naming of the segments is introduced, which
# gives a special meaning to the characters "_^()".
#
# @developer
#   In the main file is only the method redefinition infrastructure
#   (private methods). The public methods are in the included modules.
#
module RGFATools
end

require_relative "rgfatools/artifacts"
require_relative "rgfatools/copy_number"
require_relative "rgfatools/invertible_segments"
require_relative "rgfatools/multiplication"
require_relative "rgfatools/superfluous_links"
require_relative "rgfatools/linear_paths"
require_relative "rgfatools/p_bubbles"

module RGFATools

  include RGFATools::Artifacts
  include RGFATools::CopyNumber
  include RGFATools::InvertibleSegments
  include RGFATools::Multiplication
  include RGFATools::SuperfluousLinks
  include RGFATools::LinearPaths
  include RGFATools::PBubbles

  private

  def self.included(klass)
    included_modules.each do |included_module|
      if included_module.const_defined?("Redefined")
        self.redefine_methods(included_module::Redefined, klass)
      end
      if included_module.const_defined?("ClassMethods")
        klass.extend(included_module::ClassMethods)
      end
    end
  end

  def self.redefine_methods(redefined_methods, klass)
    klass.class_eval do
      redefined_methods.each do |redefined_method|
        was_private = klass.private_instance_methods.include?(redefined_method)
        public redefined_method
        alias_method :"#{redefined_method}_without_rgfatools", redefined_method
        alias_method redefined_method, :"#{redefined_method}_with_rgfatools"
        if was_private
          private redefined_method,
                  :"#{redefined_method}_without_rgfatools",
                  :"#{redefined_method}_with_rgfatools"
        end
      end
    end
  end

  ProgramName = "RGFATools"

  def add_program_name_to_header
    set_header_field(:pn, RGFATools::ProgramName)
  end

end

class RGFA
  include RGFATools

  # Enable {RGFATools} extensions of RGFA methods
  # @return [void]
  def enable_extensions
    @extensions_enabled = true
  end

  # Disable {RGFATools} extensions of RGFA methods
  # @return [void]
  def disable_extensions
    @extensions_enabled = false
  end

end
