#!/bin/csh
set echo
#
# --- external gravity wave speed and barotropic cfl.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
setenv FOR051  depth_GOMb0.08_07.b
setenv FOR051A depth_GOMb0.08_07.a
setenv FOR061  depth_GOMb0.08_07_batrop.b
setenv FOR061A depth_GOMb0.08_07_batrop.a
#
${TOOLS}/topo/src/topo_batrop
