#/bin/csh -f
#
# ---- calculate cores * total wall time for each timer
#
egrep "   time = |timer statistics, processor" $1 /dev/null | sed -e 's/.... *time.call.*$//g' -e 's/ of/ of /g' -e 's/processor/processor /g' | awk -f ../corehrs_all.awk | sed -e 's/calls =.*time/time/g'
