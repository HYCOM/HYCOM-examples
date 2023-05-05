#
# --- extract time in seconds for zaiowr.
#
grep "zaiowr   calls =     23" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'
