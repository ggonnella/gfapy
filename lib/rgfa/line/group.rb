# A group is a U O or P line
class RGFA::Line::Group < RGFA::Line
end
require_relative "group/unordered.rb"
require_relative "group/ordered.rb"
require_relative "group/path.rb"
