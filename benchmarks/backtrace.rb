#!/bin/bash

# from: http://stackoverflow.com/questions/3955688/how-do-i-debug-ruby-scripts

# %-PURPOSE-%
# force a running ruby process to output the backtrace, then continue
echo 'call (void)rb_backtrace()' | gdb -p $(pgrep -nf ruby)
