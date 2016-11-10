module RGFA::Line::Edge::Link::References

  private

  def process_not_unique(previous)
    if complement?(previous)
      # do nothing
    else
      super
    end
  end

end
