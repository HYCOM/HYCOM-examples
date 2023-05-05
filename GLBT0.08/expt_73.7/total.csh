#/usr/bin/csh -f
#
# --- extract time in seconds for main computation.
# --- 2 lines per .log file, 2nd is the main computation.
#
grep "total    calls =.*   time =" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'  | awk -f ../total.awk
