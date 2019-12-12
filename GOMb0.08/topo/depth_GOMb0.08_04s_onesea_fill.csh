#!/bin/csh
set echo
set time=1
#
uname -a
#
# --- fill all small enclosed seas in a hycom topography.
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
/bin/ln -s depth_GOMb0.08_94m.b fort.51
/bin/ln -s depth_GOMb0.08_94m.a fort.51A
limit stacksize unlimited
limit
${TOOLS}/topo/src/topo_onesea_fill<<'E-o-D'
100
'E-o-D'
/bin/mv fort.61  depth_GOMb0.08_04s.b
/bin/mv fort.61A depth_GOMb0.08_04s.a
#
/bin/rm -f fort.[56]1*
