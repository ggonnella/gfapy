# Output the spacer before the content
# @tested_in api_comments
module RGFA::Line::Comment::Writer

  # @return [String] a string representation of self
  def to_s
    "##{spacer}#{content}"
  end

  alias_method :to_gfa1_s, :to_s
  alias_method :to_gfa2_s, :to_s

  # @api private
  module API_PRIVATE

    def to_a
      ["#", content, spacer]
    end

  end
  include API_PRIVATE

end
