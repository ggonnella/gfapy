RGFATools = Module.new

require "rgfa"
require_relative "rgfatools/artifacts"
require_relative "rgfatools/copy_number"
require_relative "rgfatools/error"
require_relative "rgfatools/invertible_segments"
require_relative "rgfatools/multiplication"
require_relative "rgfatools/superfluous_links"
require_relative "rgfatools/linear_paths"
require_relative "rgfatools/p_bubbles"

#
# Module defining additional methods for the RGFA class.
# In the main file is only the method redefinition infrastructure
# (private methods). The public methods are in the included modules.
#
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

# The main class of RGFA. See the RGFA API documentation.
class RGFA
  include RGFATools

  # Enable RGFATools extensions of RGFA methods
  def enable_extensions
    @extensions_enabled = true
  end

  # Disable RGFATools extensions of RGFA methods
  def disable_extensions
    @extensions_enabled = false
  end

end
