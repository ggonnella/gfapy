# Allows to create comments by using a default single-space spacer
# or by adding a spacer as second string in the array passed to
# RGFA::Line::Comment.new
module RGFA::Line::Comment::Init

  private

  def initialize_positional_fields(strings)
    init_field_value(:content, :comment, strings[0], errmsginfo: strings)
    sp = strings.size > 1 ? strings[1] : " "
    init_field_value(:spacer, :comment, sp, errmsginfo: strings)
  end

  def initialize_tags(strings)
    if strings.size > 2
      raise RGFA::ValueError,
        "Comment lines do not support tags"
    end
  end

end
