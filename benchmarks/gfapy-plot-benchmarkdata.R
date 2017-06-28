#!/usr/bin/env Rscript
# (c) Giorgio Gonnella, ZBH, Uni Hamburg, 2017

script.name = "./gfapy-plot-benchmarkdata.R"
args <- commandArgs(trailingOnly=TRUE)
if (is.na(args[3])) {
  cat("Usage: ",script.name, " <inputfile> <outpfx> <variable>", "\n")
  cat("variable: either 'segments' or 'connectivity'\n")
  stop("Too few command-line parameters")
}
infname <- args[1]
cat("input data: ",infname,"\n")
outpfx <- args[2]
cat("output prefix:", outpfx, "\n")
xvar <- args[3]
if (xvar != 'segments' && xvar != 'connectivity') {
  stop("variable must be one of: segments, connectivity")
}

library("ggplot2")

#
# The following function is described here:
# http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/#Helper%20functions
# Licence: CC0 (https://creativecommons.org/publicdomain/zero/1.0/)
#
## Gives count, mean, standard deviation, standard error of the mean, and
## confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the var to be summariezed
##   groupvars: a vector containing names of columns that contain grouping vars
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)

  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }

  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                     )
                 },
                 measurevar
                 )

  # Rename the "mean" column
  datac <- rename(datac, c("mean" = measurevar))

  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult

  return(datac)
}

data <- read.table(infname, header=T, sep="\t")

if (xvar == "segments") {
  xvarname = "lines"
  xlab="Lines (segments 1/3; dovetails 2/3)"
} else {
  xvarname = "mult"
  xlab="Dovetails/segment (segments=4000)"
  data[c("lines")] = (data[c("mult")]+1)*4000
}

time.data <- summarySE(data, measurevar="time", groupvars=c(xvarname))
outfname = paste0(outpfx,"_time.log")
sink(outfname)
print(time.data)
time.lm <- lm(time ~ lines, data=data)
summary(time.lm)
time.nls <- nls(time ~ b + a * lines,
                data=data, start=list(a=0,b=0),
                algorithm="port", lower=c(0,0))
print(time.nls)
sink()

outfname = paste0(outpfx,"_space.log")
sink(outfname)
space.data <- summarySE(data, measurevar="space", groupvars=c(xvarname))
print(space.data)
space.lm <- lm(space ~ lines, data=data)
summary(space.lm)
space.nls <- nls(space ~ b + a * lines,
                 data=data, start=list(a=0,b=0),
                 algorithm="port", lower=c(0,0))
print(space.nls)
sink()

outfname = paste0(outpfx,"_time.pdf")
pdf(outfname)
print(ggplot(time.data, aes_string(x=xvarname, y="time")) +
    geom_errorbar(aes(ymin=time-se, ymax=time+se), width=2) +
        geom_line(size=0.2) + geom_point(size=3) +
        ylab("Total elapsed time (s)") +
        xlab(xlab))
outfname = paste0(outpfx,"_space.pdf")
pdf(outfname)
print(ggplot(space.data, aes_string(x=xvarname, y="space")) +
    geom_errorbar(aes(ymin=space-se, ymax=space+se), width=2) +
        geom_line(size=0.2) + geom_point(size=3) +
        ylab("Memory peak (MB)") +
        xlab(xlab))
dev.off()

