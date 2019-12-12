#
set echo
#
# --- find rivers in region
# --- edit rivers_all.txt to produce final list in rivers_allm.txt
#
~/HYCOM-tools/bin/hycom_rivers -98 -80 18 32 >! rivers_all.txt
/bin/cp rivers_all.txt rivers_allm.txt
