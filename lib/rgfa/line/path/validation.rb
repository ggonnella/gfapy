module RGFA::Line::Path::Validation

  private

  def validate_lists_size!
    n_overlaps = self.overlaps.size
    n_segments = self.segment_names.size
    if n_overlaps == n_segments - 1
      # case 1: linear path
      return true
    elsif n_overlaps == 1 and self.overlaps[0].empty?
      # case 2: linear path, single "*" to represent overlaps which are all "*"
      return true
    elsif n_overlaps == n_segments
      # case 3: circular path
    else
      raise RGFA::InconsistencyError,
        "Path has #{n_segments} oriented segments, "+
        "but #{n_overlaps} overlaps"
    end
  end

  def validate_record_type_specific_info!
    validate_lists_size!
  end

end
