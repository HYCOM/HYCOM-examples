#!/bin/csh
#
set echo
set time = 1
C
C
C --- Generate HYCOM spacially varying veldf2, constant diffa2
C --- Script has idm and jdm values hardwired.
C
C --- set copy command
if (-e ~${user}/bin/pget) then
C --- remote copy
  setenv pget ~${user}/bin/pget
  setenv pput ~${user}/bin/pput
else
C --- local copy
  setenv pget cp
  setenv pput cp
endif

C
C --- E is experiment number, from EXPT.src
C --- R is region identifier, from EXPT.src
C --- T is topog. identifier, from EXPT.src
C
C --- P is primary path,
C --- S is scratch directory,
C
source EXPT.src
C
setenv P relax/${E}
setenv S ${DS}/${P}/
setenv IDM    `grep idm ${DS}/topo/regional.grid.b | awk '{print $1}'`
setenv JDM    `grep jdm ${DS}/topo/regional.grid.b | awk '{print $1}'`
C
C
mkdir -p $S
cd       $S
C
touch   regional.grid.a regional.grid.b
/bin/rm regional.grid.a regional.grid.b
C
C --- Input.
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
wait
C
C --- A2=20 everywhere. dx=8000 and so veldf2=0.00250.
C --- Use min dx and dy in calculating A2.  
C --- Note that HYCOM will use maximum, so A2 is larger for non-square grids.
C --- diffa2 is diagnostic, to confirm spacial variation in diffusion.
C
/bin/rm -f veldf2_dmin.a veldf2_dmax.a veldf2_dxdy.a veldf2_20.a diffa2_20.a
hycom_min regional.grid.a 263 193 1 10 1 2 veldf2_dmin.a
hycom_max regional.grid.a 263 193 1 10 1 2 veldf2_dmax.a
# not needed for GOM, inherited from GLB
hycom_clip veldf2_dmin.a     263 193 5000.0 10000.0 veldf2_dxdy.a
hycom_expr veldf2_dxdy.a INV 263 193    1.0    20.0 veldf2_20.a | grep "min" | sed -e "s/min, max =/veldf2: range =/g" >! veldf2_20.b
hycom_zonal   veldf2_20.a   263 193  1 >! veldf2_20.zonal
#
hycom_expr    veldf2_20.a veldf2_dmax.a 263 193 0.0 0.0 diffa2_20.a | grep "min" | sed -e "s/min, max =/diffa2: range =/g" >! diffa2_20.b
hycom_zonal   diffa2_20.a 263 193 1 >! diffa2_20.zonal
