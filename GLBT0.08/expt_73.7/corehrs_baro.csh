#/bin/csh -f
#
# ---- calculate cores * barotp wall time
#
egrep "barotp   calls =.*   time = |timer statistics, processor" *.log* /dev/null | sed -e 's/.... *time.call.*$//g' -e 's/ of/ of /g' | awk -f ../corehrs_baro.awk | sed -e 's/   calls =      720//g'
