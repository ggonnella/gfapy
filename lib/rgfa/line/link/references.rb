module RGFA::Line::Link::References

  private

  def process_not_unique(previous)
    if previous.complement?
      # do nothing
    else
      super
    end
  end

end
