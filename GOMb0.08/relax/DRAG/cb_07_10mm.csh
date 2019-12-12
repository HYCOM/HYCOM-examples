#!/bin/csh

set echo
#
# --- variable cb for z0=10mm, background=0.0025
#
source ~/HYCOM-examples/GOMb0.08/relax/EXPT.src

cd ${DS}/relax/
mkdir -p DRAG/
cd DRAG/

#
setenv T 07
#
setenv IDM  `grep idm ${DS}/topo/regional.grid.b | awk '{print $1}'`
setenv JDM  `grep jdm ${DS}/topo/regional.grid.b | awk '{print $1}'`
#
/bin/rm -f cb_${T}_10mm.a
~/HYCOM-tools/bin/hycom_botfric ${DS}/topo/depth_${R}_${T}.a $IDM $JDM 0.010 0.0025 cb_${T}_10mm.a >! cb_${T}_10mm.b
