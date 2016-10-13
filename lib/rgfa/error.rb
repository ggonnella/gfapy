# Parent class for library-specific errors
class RGFA::Error < StandardError; end

# unknown version of the specification
class RGFA::VersionError < RGFA::Error; end
