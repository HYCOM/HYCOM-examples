#!/bin/csh
set echo
set time=1
#
uname -a
#
# --- landfill a hycom topography.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
/bin/rm -f fort.[56]1*
#
setenv FOR051  fort.51
setenv FOR051A fort.51A
setenv FOR061  fort.61
setenv FOR061A fort.61A
#
/bin/ln -s ./depth_GOMb0.08_04.b fort.51
/bin/ln -s ./depth_GOMb0.08_04.a fort.51A
${TOOLS}/topo/src/topo_landfill
/bin/mv fort.61  ./depth_GOMb0.08_04check.b
/bin/mv fort.61A ./depth_GOMb0.08_04check.a
#
/bin/rm -f fort.[56]1*
