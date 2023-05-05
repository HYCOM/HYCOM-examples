#
# --- extract time in seconds for barotp.
#
grep "barotp   calls =      720" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'
