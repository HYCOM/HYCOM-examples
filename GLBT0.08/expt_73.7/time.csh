#/bin/csh -f
#
# --- extract time in minutes from date commands.
#
egrep '[CT] 20[0-2][0-9]$' *.log* /dev/null | awk -f ../time.awk
