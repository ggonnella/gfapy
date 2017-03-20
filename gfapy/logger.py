import sys
import gfapy
import time

class Logger:
  """
  This class allows to output a message to the standard error or a logfile and
  to keep track of the progress of long running methods.
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
    """
    Output a message

    Parameters
    ----------
    msg : String
      message to output
    min_verbose_level : Integer
    """
    if self._verbose_level >= min_verbose_level:
      self._channel.write("{} {}\n".format(self._pfx, msg))

  def enable_progress(self, part = 0.1):
    """
    Enable output from the Logger instance

    Parameters
    ----------
    part : float
      if part = 0, output at every call of {gfapy.Logger.progress_log};
      if 0 < part < 1, output once per part of the total progress
      (e.g. 0.001 = log every 0.1% progress);
      if part = 1, output only total elapsed time
    """
    if part < 0 or part > 1:
      raise gfapy.ArgumentError("part must be in range [0..1]")
    self._progress = True
    self._part = part
    if self._verbose_level > 0:
      self._channel.write("{} Progress logging enabled\n".format(self._pfx))

  def disable_progress(self):
    """
    Disable progress logging
    """
    self._progress = False
    if self._verbose_level > 0:
      self._channel.write("{} Progress logging disabled\n".format(self._pfx))

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
    """
    Completes progress logging for a computation
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
