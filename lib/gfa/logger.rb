class GFA::Logger

  ProgressData = Struct.new(:counter, :units, :partsize,
                            :lastpart, :total, :starttime,
                            :strlen)

  # Initialize a Logger instance
  #
  # *Arguments*:
  #   - channel: where to output (must provide a puts method, default: STDERR)
  #   - prefix: output prefix (default: "#")
  #   - verbose_level: (int) 0: no logging; >0: the higher, the more logging
  def initialize(verbose_level: 1, channel: STDERR, prefix: "#")
    @progress = false
    if !verbose_level.kind_of?(Integer)
      raise "verbose_level must be an Integer"
    end
    raise "channel must provide a puts method" if !channel.respond_to?(:puts)
    @channel = channel
    @pfx = prefix
    @verbose_level = verbose_level
    @data = {}
  end

  def log(msg, min_verbose_level=1)
    @channel.puts "#@pfx #{msg}" if @verbose_level >= min_verbose_level
  end

  # Enable output from the Logger instance
  #
  # *Arguments*:
  #   - channel: where to output (must provide a puts method, default: STDERR)
  #   - prefix: output prefix (default: "#")
  #   - part:
  #     - part = 0      => output at every call of Logger.prlog()
  #     - 0 < part < 1  => output once per part of the total progress
  #                        (e.g. 0.001 = log every 0.1% progress)
  #     - part = 1      => output only total elapsed time
  def enable_progress(part: 0.1)
    raise "part must be in range [0..1]" if part < 0 or part > 1
    @progress = true
    @part = part
    @channel.puts "#@pfx Progress logging enabled" if @verbose_level > 0
  end

  def disable
    @progress = false
    @channel.puts "#@pfx Progress logging disabled" if @verbose_level > 0
  end

  def progress_init(symbol, units, total, initmsg = nil)
    return if !@progress or total == 0
    str = "#@pfx 0.0% #{units} processed"
    @data[symbol] = ProgressData.new(0, units, (@part*total).to_i, 1, total,
                                     Time.now, str.size)
    @channel.puts "#@pfx #{initmsg}" if initmsg
    @channel.print str if @part != 1
  end

  def progress_log(symbol, progress=1)
    return if !@progress or @part == 1
    data = @data[symbol]
    return if data.nil?
    data.counter += progress
    if data.counter == data.total
      progress_end(symbol)
    elsif data.partsize == 0 or (data.counter / data.partsize) > data.lastpart
      data.lastpart = data.counter / data.partsize
      done = data.counter.to_f / data.total
      t = Time.now - data.starttime
      eta = (t / done) - t
      tstr= ("Elapsed: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
      etastr = ("ETA: %02dh %02dmin %02ds" % [eta/3600, eta/60%60, eta%60])
      donestr = "%.1f" % (done*100)
      str = "#@pfx #{donestr}% #{data.units} processed [#{tstr}; #{etastr}]"
      if str.size > data.strlen
        data.strlen = str.size
        spacediff = ""
      else
        spacediff = " "*(data.strlen-str.size)
      end
      @channel.print "\r#{str}#{spacediff}"
      @channel.flush
    end
  end

  def progress_end(symbol)
    return if !@progress
    data = @data[symbol]
    return if data.nil?
    t = Time.now - data.starttime
    tstr= ("Elapsed time: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
    quantity = @part == 1 ? data.total.to_s : "100.0%"
    str = "#@pfx #{quantity} #{data.units} processed [#{tstr}]"
    spacediff = " "*([data.strlen - str.size,0].max)
    @channel.print "\r" if @part != 1
    @channel.puts "#{str}#{spacediff}"
    @channel.flush
    @data.delete(symbol)
  end

end

module GFA::LoggerSupport

  # Activate logging of progress
  def enable_progress_logging(part: 0.1, channel: STDERR)
    @progress = GFA::Logger.new(channel: channel)
    @progress.enable_progress(part: part)
  end

  def progress_log_init(symbol, units, total, msg = nil)
    @progress.progress_init(symbol, units, total, msg) if @progress
  end

  def progress_log(symbol, progress=1)
    @progress.progress_log(symbol, progress) if @progress
  end

  def progress_log_end(symbol)
    @progress.progress_end(symbol) if @progress
  end

end
