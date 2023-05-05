#/bin/csh -f
#
# ---- calculate cores * total wall time
#
egrep "total    calls =.*   time = |timer statistics, processor" *.log* /dev/null | sed -e 's/.... *time.call.*$//g' -e 's/ of/ of /g' -e 's/processor/processor /g' | awk -f ../corehrs.awk | sed -e 's/    calls =        1//g'
