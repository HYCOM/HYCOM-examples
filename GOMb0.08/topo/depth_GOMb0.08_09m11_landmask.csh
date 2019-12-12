#!/bin/csh

set echo
set time=1
#
uname -a
#
# --- landmask a hycom topography.
# --- set nreg negative to switch of automatic arctic domain detection
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
/bin/ln -s ./depth_GOMb0.08_09m11s.b fort.51
/bin/ln -s ./depth_GOMb0.08_09m11s.a fort.51A
${TOOLS}/topo/src/topo_landmask<<'E-o-D'
landmask N and E edges
-8
125 128   1   4
247 251   1   2
216 263 193 193
263 263   1 193
262 262 106 116
260 262  94  95
262 262  48  48
262 262  32  33
'E-o-D'
/bin/mv fort.61  ./depth_GOMb0.08_09m11.b
/bin/mv fort.61A ./depth_GOMb0.08_09m11.a
#
/bin/rm -f fort.[56]1*
