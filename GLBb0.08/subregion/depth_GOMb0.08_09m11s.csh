#!/bin/csh
set echo
set time=1
#
uname -a 
#
# --- form subregion bathymetry file, GLBb0.08_09m11 to GOMb0.08
#
setenv R /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo
setenv DS /p/work1/${user}/HYCOM-examples/GLBb0.08/datasets
#
ln -s ${DS}/topo/regional.grid.? .
#
touch   ${R}/depth_GOMb0.08_09m11s.b
/bin/rm ${R}/depth_GOMb0.08_09m11s.[ab]
~/hycom/ALL/subregion/src/isuba_topog <<E-o-D
${R}/regional.gmapi_GLBb0.08.a
${DS}/topo/depth_GLBb0.08_09m11.b
${R}/depth_GOMb0.08_09m11s.b
depth_GLBb0.08_09m11 subregioned to GOMb0.08 via isuba_topog
  263	  'idm   ' = target longitudinal array size
  193	  'jdm   ' = target latitudinal  array size
E-o-D
