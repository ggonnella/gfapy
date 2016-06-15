#
# This class allows to output a message to the log file or STDERR and
# to keep track of the progress of a method which takes long time to complete.
#
class GFA::Logger

  # Information about the progress of a computation
  ProgressData = Struct.new(:counter, :units, :partsize,
                            :lastpart, :total, :starttime,
                            :strlen)

  # Create a Logger instance
  #
  # @param channel [#puts]
  #    where to output (default: STDERR)
  # @param prefix [String]
  #   output prefix (default: "#")
  # @param verbose_level [Integer]
  #   0: no logging; >0: the higher, the more logging
  # @return [GFA::Logger]
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

  # Output a message
  #
  # @param msg [String] message to output
  # @param min_verbose_level [Integer]
  # @return [void]
  def log(msg, min_verbose_level=1)
    @channel.puts "#@pfx #{msg}" if @verbose_level >= min_verbose_level
    return nil
  end

  # Enable output from the Logger instance
  #
  # @param part [Float]
  #  - part = 0      => output at every call of {GFA::Logger.progress_log}
  #  - 0 < part < 1  => output once per part of the total progress
  #                     (e.g. 0.001 = log every 0.1% progress)
  #  - part = 1      => output only total elapsed time
  # @return [void]
  def enable_progress(part: 0.1)
    raise "part must be in range [0..1]" if part < 0 or part > 1
    @progress = true
    @part = part
    @channel.puts "#@pfx Progress logging enabled" if @verbose_level > 0
    return nil
  end

  # Disable progress logging
  # @return [void]
  def disable_progress
    @progress = false
    @channel.puts "#@pfx Progress logging disabled" if @verbose_level > 0
    return nil
  end

  # @!macro progress_init
  #   Initialize progress logging for a computation
  #   @param symbol [Symbol] a symbol assigned to the computation
  #   @param units [String] a string with the name of the units, in plural
  #   @param total [Integer] total number of units
  #   @param initmsg [String] an optional message to output at the beginning
  # @return [void]
  def progress_init(symbol, units, total, initmsg = nil)
    return nil if !@progress or total == 0
    str = "#@pfx 0.0% #{units} processed"
    @data[symbol] = ProgressData.new(0, units, (@part*total).to_i, 1, total,
                                     Time.now, str.size)
    @channel.puts "#@pfx #{initmsg}" if initmsg
    @channel.print str if @part != 1
    return nil
  end

  # @!macro [new] progress_log
  #   Updates progress logging for a computation
  #   @!macro [new] prlog
  #     @param symbol [Symbol] the symbol assigned to the computation at
  #       init time
  #     @param keyargs [Hash] additional units to display, with their current
  #       value (e.g. segments_processed: 10000)
  #   @param progress [Integer] how many units were processed
  # @return [void]
  def progress_log(symbol, progress=1, **keyargs)
    return nil if !@progress or @part == 1
    data = @data[symbol]
    return nil if data.nil?
    data.counter += progress
    if data.counter == data.total
      progress_end(symbol)
    elsif data.partsize == 0 or
        (data.counter / data.partsize).to_i > data.lastpart
      return nil if data.partsize == 0 and @part > 0
        # this means total is very small
      data.lastpart = data.counter / data.partsize if data.partsize > 0
      done = data.counter.to_f / data.total
      t = Time.now - data.starttime
      eta = (t / done) - t
      tstr= ("Elapsed: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
      etastr = ("ETA: %02dh %02dmin %02ds" % [eta/3600, eta/60%60, eta%60])
      donestr = "%.1f" % (done*100)
      keystr = ""
      keyargs.each {|k,v| keystr << "; #{k}: #{v}"}
      str = "#@pfx #{donestr}% #{data.units} processed "+
              "[#{tstr}; #{etastr}#{keystr}]"
      if str.size > data.strlen
        data.strlen = str.size
        spacediff = ""
      else
        spacediff = " "*(data.strlen-str.size)
      end
      @channel.print "\r#{str}#{spacediff}"
      @channel.flush
    end
    return nil
  end

  # @!macro [new] progress_end
  #   Completes progress logging for a computation
  #   @!macro prlog
  # @return [void]
  def progress_end(symbol, **keyargs)
    return if !@progress
    data = @data[symbol]
    return if data.nil?
    t = Time.now - data.starttime
    tstr= ("Elapsed time: %02dh %02dmin %02ds" % [t/3600, t/60%60, t%60])
    quantity = @part == 1 ? data.total.to_s : "100.0%"
    keystr = ""
    keyargs.each {|k,v| keystr << "; #{k}: #{v}"}
    str = "#@pfx #{quantity} #{data.units} processed [#{tstr}#{keystr}]"
    spacediff = " "*([data.strlen - str.size,0].max)
    @channel.print "\r" if @part != 1
    @channel.puts "#{str}#{spacediff}"
    @channel.flush
    @data.delete(symbol)
    return nil
  end

end

# Progress logging related-methods for GFA class
module GFA::LoggerSupport

  # Activate logging of progress
  # @return [GFA] self
  def enable_progress_logging(part: 0.1, channel: STDERR)
    @progress = GFA::Logger.new(channel: channel)
    @progress.enable_progress(part: part)
    return self
  end

  # @!macro progress_init
  # @return [GFA] self
  def progress_log_init(symbol, units, total, initmsg = nil)
    @progress.progress_init(symbol, units, total, initmsg) if @progress
    return self
  end

  # @!macro progress_log
  # @return [GFA] self
  def progress_log(symbol, progress=1)
    @progress.progress_log(symbol, progress) if @progress
    return self
  end

  # @!macro progress_end
  # @return [GFA] self
  def progress_log_end(symbol)
    @progress.progress_end(symbol) if @progress
    return self
  end

end
