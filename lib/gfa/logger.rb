module GFA::Logger

  ProgressData = Struct.new(:counter, :units, :partsize,
                            :lastpart, :total, :starttime,
                            :strlen)

  # Activate logging of progress
  def enable_progress_logging(part: 0.1, channel: STDERR)
    @progress = true
    @progress_part = part
    @progress_file = channel
    @progress_file.puts "# Progress logging enabled"
    @progress_data = {}
  end

  private

  def progress_log_init(symbol, units, total, msg = nil)
    if @progress and total > 0
      str = "# 0.0% #{units} processed"
      @progress_data[symbol] =
        ProgressData.new(0, units, (@progress_part*total).to_i, 1, total,
                         Time.now, str.size)
      @progress_file.puts "# #{msg}" if msg
      @progress_file.print str
    end
  end

  def progress_log(symbol, progress=1)
    if @progress
      data = @progress_data[symbol]
      return if data.nil?
      data.counter += progress
      if data.counter == data.total
        progress_log_end(symbol)
      elsif data.partsize == 0 or (data.counter / data.partsize) > data.lastpart
        data.lastpart = data.counter / data.partsize
        done = data.counter.to_f / data.total
        t = Time.now - data.starttime
        eta = (t / done) - t
        tstr= ("Elapsed: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
        etastr = ("ETA: %02dh %02dmin %02ds" % [eta/3600, eta/60%60, eta%60])
        donestr = "%.1f" % (done*100)
        str = "# #{donestr}% #{data.units} processed [#{tstr}; #{etastr}]"
        if str.size > data.strlen
          data.strlen = str.size
          spacediff = ""
        else
          spacediff = " "*(data.strlen-str.size)
        end
        @progress_file.print "\r#{str}#{spacediff}"
        @progress_file.flush
      end
    end
  end

  def progress_log_end(symbol)
    if @progress
      data = @progress_data[symbol]
      return if data.nil?
      t = Time.now - data.starttime
      tstr= ("Elapsed time: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
      str = "# 100.0% #{data.units} processed [#{tstr}]"
      spacediff = " "*([data.strlen - str.size,0].max)
      @progress_file.puts "\r#{str}#{spacediff}"
      @progress_file.flush
      @progress_data.delete(symbol)
    end
  end

end
