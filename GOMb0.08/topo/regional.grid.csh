#!/bin/csh -f
set echo
#
# --- create a standard mercator regional.grid.[ab]
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
touch      fort.61
/bin/rm -f fort.61*
#
# --- temporary regional.grid.b
#
cat >! regional.grid.b <<'E-o-D'
  263	  'idm   ' = longitudinal array size
  193	  'jdm   ' = latitudinal  array size
'E-o-D'
echo 'regional.grid.b'
#
setenv FOR061  fort.61
setenv FOR061A fort.61A
${TOOLS}/topo/src/grid_mercator<<'E-o-D'
 263	'idm   ' = longitudinal array size
 193	'jdm   ' = latitudinal  array size
  0	'mapflg' = map flag (0=mercator,2=uniform,4=f-plane)
  1.0	'pntlon' = longitudinal reference grid point on pressure grid
-98.0	'reflon' = longitude of reference grid point on pressure grid
0.08    'grdlon' = longitudinal grid size (degrees)
-229.0	'pntlat' = latitudinal  reference grid point on pressure grid
  0.0	'reflat' = latitude of  reference grid point on pressure grid
0.08    'grdlat' = latitudinal  grid size at the equator (degrees)
'E-o-D'
mv fort.61  regional.grid.b
mv fort.61A regional.grid.a
#
cat regional.grid.b
