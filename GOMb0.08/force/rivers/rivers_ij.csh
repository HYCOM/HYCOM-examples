#
set echo
#
# --- find i,j locations of rivers
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets
grep "[A-Z]" rivers_allm.txt | cut -c 33-55 >! rivers_names.txt
grep "[A-Z]" rivers_allm.txt | cut -c 11-30 >! rivers_lonlat.txt
~/HYCOM-tools/bin/hycom_lonlat2ij ${DS}/topo/regional.grid.a < rivers_lonlat.txt > ! rivers_ij.txt
paste rivers_ij.txt rivers_lonlat.txt rivers_names.txt
