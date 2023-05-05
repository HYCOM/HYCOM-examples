#/bin/csh -f
#
# ---- subtract I/O and MPI time from total to get compuational time.
#
egrep "total    calls =.*   time = .[0-9]|xc\*\*\*\*   calls =.*   time = .[0-9]|zaiowr   calls =      726|zaiord   calls =       99" *.log* /dev/null | sed -e 's/.... *time.call.*$//g'
