#
# --- extract time in seconds for zaiowr.
#
grep "zaiow.   calls =" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'
