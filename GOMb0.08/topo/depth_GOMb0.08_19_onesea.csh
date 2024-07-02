#!/bin/csh -x
#
set echo
set time=1
#
# --- identify all small enclosed seas in a hycom topography.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools
#
cd $DS
#
setenv FOR051  fort.51
setenv FOR051A fort.51A
setenv FOR061  fort.61
setenv FOR061A fort.61A
#
/bin/ln -s depth_GOMb0.08_19.b fort.51
/bin/ln -s depth_GOMb0.08_19.a fort.51A
limit stacksize unlimited
limit
${TOOLS}/topo/src/topo_onesea
/bin/mv fort.61  depth_GOMb0.08_19_onesea.b
/bin/mv fort.61A depth_GOMb0.08_19_onesea.a
#
/bin/rm -f fort.[56]1*
