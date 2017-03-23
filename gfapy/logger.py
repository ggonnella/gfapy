import sys
import gfapy
import time

class Logger:
  """
  Output messages to the standard error or a logfile and
  keep track of the progress of long running methods.

  Parameters:
    verbose_level (int) : 0: no logging; >0: the higher, the more logging
      (default: 1); messages output using the log() method can be provided
      with a min_verbose_level, and are output only if that value is equal
      or higher than verbose_level
    channel : where to output (default: sys.stderr), it must provide a
      write() method.
    prefix (str) : output prefix (default: ```#```)

  Returns:
    gfapy.Logger
  """

  class ProgressData:
    """
    Information about the progress of a computation
    """
    def __init__(self, counter, units, partsize, lastpart, total, starttime,
                 strlen):
      self._counter = counter
      self._units = units
      self._partsize = partsize
      self._lastpart = lastpart
      self._total = total
      self._starttime = starttime
      self._strlen = strlen

  def __init__(self, verbose_level = 1, channel = sys.stderr, prefix = "#"):
    self._progress = False
    if not isinstance(verbose_level, int):
      raise gfapy.ArgumentError("verbose_level must be an Integer")
    if not(getattr(channel, "write", None) and callable(channel.write)):
      raise gfapy.TypeError("channel must provide a 'write' method")
    self._channel = channel
    self._pfx = prefix
    self._verbose_level = verbose_level
    self._data = {}

  def log(self, msg, min_verbose_level=1):
    """Output a log message to the logger output channel.

    Parameters:
      msg (str) : message to output
      min_verbose_level (int) : output the message only if the
        verbose level of the logger is at least the specified one
        (default: 1)
    """
    if self._verbose_level >= min_verbose_level:
      self._channel.write("{} {}\n".format(self._pfx, msg))

  def enable_progress(self, part = 0.1):
    """Enable output of progress of long running methods.

    Parameters
      part (float between 0 and 1) : if part = 0, output at every call of
         progress_log(); if 0 < part < 1, output once per part of the total
         progress (e.g. 0.001 = log every 0.1% progress); if part = 1, output
         only total elapsed time at the end of the computation.
    """
    if part < 0 or part > 1:
      raise gfapy.ArgumentError("part must be in range [0..1]")
    self._progress = True
    self._part = part
    if self._verbose_level > 0:
      self._channel.write("{} Progress logging enabled\n".format(self._pfx))

  def disable_progress(self):
    """Disable output of progress of long running methods."""
    self._progress = False
    if self._verbose_level > 0:
      self._channel.write("{} Progress logging disabled\n".format(self._pfx))

  def progress_init(self, symbol, units, total, initmsg = None):
    """Initialize progress logging for a long running computation.

    Parameters:
      symbol (str) : an identifier assigned to the computation
      units (str) : the name of the units of computation, in plural, for the
                    output messages
      total (int) : the total number of units of the computation
      initmsg (str) : an optional message to output at the beginning of the
                      computation
    """
    if not self._progress or total == 0:
      return
    string = "{} 0.0% {} processed".format(self._pfx, units)
    self._data[symbol] = Logger.ProgressData(0, units, int(self._part*total),
                                             1, total, time.time(), len(string))
    if initmsg:
      self._channel.write("{} {}\n".format(self._pfx, initmsg))
    if self._part != 1:
      self._channel.write(string)

  def progress_log(self, symbol, progress=1, **keyargs):
    """Updates progress of a computation.

    A logging message is output or not, depending on the part parameter
    (see the `enable_progress` method).

    Parameters:
      symbol (str) : the identifier assigned to the computation when
                    `progress_init` was called
      progress (int) : how many units of computations were completed
                       in the last interaction (default: 1)
      **keyargs (dict) : additional units of computation to display (keys),
                       together with their current progress value (values);
                       (e.g. segments_processed: 10000)
    """
    if not self._progress or self._part == 1:
      return
    data = self._data.get(symbol, None)
    if data is None:
      return
    data._counter += progress
    if data._counter == data._total:
      self.progress_end(symbol)
    elif data._partsize == 0 or \
         int(data._counter / data._partsize) > data._lastpart:
      if data._partsize == 0 and self._part > 0:
        return
      # this means total is very small
      if data._partsize > 0:
        data._lastpart = data._counter / data._partsize
      done = data._counter / data._total
      t = int(time.time() - data._starttime)
      eta = int((t / done) - t)
      tstr= ("Elapsed: {:02d}h {:02d}min {:02d}s"
             .format(t//3600, t//60%60, t%60))
      etastr = ("ETA: {:02d}h {:02d}min {:02d}s"
                .format(eta//3600, eta//60%60, eta%60))
      donestr = "{:.1f}".format(done*100)
      keystr = "".join([ "; {}: {}".format(k, v) for k,v in keyargs.items()])
      string = "{} {}% {} processed " \
               .format(self._pfx, donestr, data._units) + \
               "[{}; {}{}]" \
               .format(tstr, etastr, keystr)
      if len(string) > data._strlen:
        data._strlen = len(string)
        spacediff = ""
      else:
        spacediff = " "*(data._strlen-len(string))
      self._channel.write("\r{}{}".format(string, spacediff))
      self._channel.flush()

  def progress_end(self, symbol, **keyargs):
    """Completes progress logging for a computation.

    A message is always output. The progress is set to 100%.

    Parameters:
      symbol (str) : the identifier assigned to the computation when
                    `progress_init` was called
      **keyargs (dict) : additional units of computation to display (keys),
                       together with their final value (values);
                       (e.g. segments_processed: 100000)
    """
    if not self._progress:
      return
    data = self._data.get(symbol, None)
    if data is None:
      return
    t = int(time.time() - data._starttime)
    tstr= ("Elapsed time: {:02d}h {:02d}min {:02d}s"
           .format(t//3600, t//60%60, t%60))
    quantity = str(data._total) if self._part == 1 else "100.0%"
    keystr = "".join([ "; {}: {}".format(k, v) for k,v in keyargs.items()])
    string = "{} {} {} processed " \
             .format(self._pfx, quantity, data._units) + \
             "[{}{}]" \
             .format(tstr, keystr)
    spacediff = " " * (max(data._strlen - len(string),0))
    if self._part != 1:
      self._channel.write("\r")
    self._channel.write("{}{}\n".format(string, spacediff))
    self._channel.flush()
    self._data.pop(symbol)
