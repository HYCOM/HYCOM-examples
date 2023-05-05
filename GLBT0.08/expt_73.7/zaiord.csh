#
# --- extract time in seconds for zaiowr.
#
grep "zaiord   calls =      330" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'
