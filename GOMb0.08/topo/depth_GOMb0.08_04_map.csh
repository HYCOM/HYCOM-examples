#!/bin/csh

set echo
#
# --- map a HYCOM bathymetry.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
setenv FOR051A fort.51A
/bin/rm -f fort.[5]1*
ln -s depth_GOMb0.08_04.b  fort.51
ln -s depth_GOMb0.08_04.a  fort.51A
if (-e landsea_GOMb0.08.a) then
  /bin/rm -f regional.mask.a
  /bin/ln -s landsea_GOMb0.08.a regional.mask.a
endif
setenv NO_STOP_MESSAGE
${TOOLS}/topo/src/topo_map
#
/bin/rm -f fort.[5]1*
