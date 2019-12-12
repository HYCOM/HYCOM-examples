#
set echo
#
# --- extract river transports
#
grep -v '[A-Z]' rivers_allm.txt | grep -v '^ *$' | cut -c 41- >! rivers_tr.txt
