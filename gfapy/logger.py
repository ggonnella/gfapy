import sys
import gfapy
import time

class Logger:
  """
  This class allows to output a message to the log file or STDERR and
  to keep track of the progress of a method which takes long time to complete.
  """

  class ProgressData:
    """
    Information about the progress of a computation
    """
    def __init__(self, counter, units, partsize, lastpart, total, starttime, strlen):
      self.counter = counter
      self.units = units
      self.partsize = partsize
      self.lastpart = lastpart
      self.total = total
      self.starttime = starttime
      self.strlen = strlen

  def __init__(self, verbose_level = 1, channel = sys.stdout, prefix = "#"):
    """
    Create a Logger instance

    Parameters
    ----------
    verbose_level : int, optional
      0: no logging; >0: the higher, the more logging
    channel : optional
      where to output (default: sys.stderr)
    prefix : str, optional
      output prefix (default: "#")

    Returns
    -------
    gfapy.Logger
    """
    self.progress = False
    if not isinstance(verbose_level, int):
      raise gfapy.ArgumentError("verbose_level must be an Integer")
    if not(getattr(channel, "write", None) and callable(channel.write)):
      raise gfapy.TypeError("channel must provide a 'write' method")
    self.channel = channel
    self.pfx = prefix
    self.verbose_level = verbose_level
    self.data = {}

  def log(self, msg, min_verbose_level=1):
    """
    Output a message

    Parameters
    ----------
    msg : String
      message to output
    min_verbose_level : Integer
    """
    if self.verbose_level >= min_verbose_level:
      self.channel.write("{} {}".format(self.pfx, msg))
    return

  def enable_progress(self, part = 0.1):
    """
    Enable output from the Logger instance

    Parameters
    ----------
    part : float
      - part = 0      => output at every call of {gfapy.Logger.progress_log}
      - 0 < part < 1  => output once per part of the total progress
      (e.g. 0.001 = log every 0.1% progress)
      - part = 1      => output only total elapsed time
    """
    if part < 0 or part > 1:
      raise gfapy.ArgumentError("part must be in range [0..1]")
    self.progress = True
    self.part = part
    if self.verbose_level > 0:
      self.channel.write("{} Progress logging enabled".format(pfx))

  def disable_progress(self):
    """
    Disable progress logging
    """
    self.progress = False
    if self.verbose_level > 0:
      self.channel.write("{} Progress logging disabled".format(self.pfx))

  def progress_init(self, symbol, units, total, initmsg = None):
    """
    Initialize progress logging for a computation

    Parameters
    ----------
    symbol : string
      a symbol assigned to the computation
    units : str
      a string with the name of the units, in plural
    total : int
      total number of units
    initmsg : str
      an optional message to output at the beginning
    """
    if not self.progress or total == 0:
      return
    string = "{} 0.0% {} processed".format(self.pfx, units)
    self.data[symbol] = ProgressData(0, units, int(self.part*total), 1, total,
                                     time.time(), len(string))
    if initmsg:
      self.channel.write("{} {}".format(self.pfx, initmsg))
    if self.part != 1:
      self.channel.write(string)
    return

  def progress_log(self, symbol, progress=1, **keyargs):
    """
    Updates progress logging for a computation

    Parameters
    ----------
    symbol : str
      the symbol assigned to the computation at
      init time
    keyargs : dict
      additional units to display, with their current
      value (e.g. segments_processed: 10000)
    progress : int
      how many units were processed
    """
    if not self.progress or self.part == 1:
      return
    data = self.data[symbol]
    if not data: return
    data.counter += progress
    if data.counter == data.total:
      self.progress_end(symbol)
    elif data.partsize == 0 or \
         int(data.counter / data.partsize) > data.lastpart:
      if data.partsize == 0 and self.part > 0:
        return
      # this means total is very small
      if data.partsize > 0:
        data.lastpart = data.counter / data.partsize
      done = float(data.counter) / data.total
      t = time.time - data.starttime
      eta = (t / done) - t
      tstr= ("Elapsed: {:02d}h {:02d}min {:02d}s"
             .format(t//3600, t//60%60, t%60))
      etastr = ("ETA: {:02d}h {:02d}min {:02d}s"
                .format(eta//3600, eta//60%60, eta%60))
      donestr = "{:.1f}".format(done*100)
      keystr = "".join([ "; {}: {}".format(k, v) for k,v in keyargs.items])
      string = "{} {}% {} processed " \
               .format(self.pfx, donestr, data.units) + \
               "[{}; {}{}]" \
               .format(tstr, etastr, keystr)
      if len(string) > data.strlen:
        data.strlen = len(string)
        spacediff = ""
      else:
        spacediff = " "*(data.strlen-len(string))
      self.channel.write("\r{}{}".format(string, spacediff))
      self.channel.flush()
    return

  def progress_end(self, symbol, **keyargs):
    """
    Completes progress logging for a computation
    """
    if not self.progress:
      return
    data = self.data[symbol]
    if not data:
      return
    t = time.time() - data.starttime
    tstr= ("Elapsed time: {:02d}h {:02d}min {:02d}s"
           .format(t//3600, t//60%60, t%60))
    quantity = str(data.total) if self.part == 1 else "100.0%"
    keystr = "".join([ "; {}: {}".format(k, v) for k,v in keyargs.items])
    string = "{} {} {} processed " \
             .format(self.pfx, quantity, data.units) + \
             "[{}{}]" \
             .format(tstr, keystr)
    spacediff = " " * (max(data.strlen - len(string),0))
    if self.part != 1:
      self.channel.write("\r")
    self.channel.write("{}{}".format(string, spacediff))
    self.channel.flush()
    self.data.delete(symbol)
    return


#TODO: Port to GFA class
## Progress logging related-methods for RGFA class
#module RGFA::LoggerSupport
#
#  # Activate logging of progress
#  # @return [RGFA] self
#  def enable_progress_logging(part: 0.1, channel: STDERR)
#    @progress = RGFA::Logger.new(channel: channel)
#    @progress.enable_progress(part: part)
#    return self
#  end
#
#  # @!macro progress_init
#  # @return [RGFA] self
#  # @api private
#  def progress_log_init(symbol, units, total, initmsg = None)
#    @progress.progress_init(symbol, units, total, initmsg) if @progress
#    return self
#  end
#
#  # @!macro progress_log
#  # @return [RGFA] self
#  # @api private
#  def progress_log(symbol, progress=1, **keyargs)
#    @progress.progress_log(symbol, progress) if @progress
#    return self
#  end
#
#  # @!macro progress_end
#  # @return [RGFA] self
#  # @api private
#  def progress_log_end(symbol, **keyargs)
#    @progress.progress_end(symbol) if @progress
#    return self
#  end
#
#end
