#
set echo
set time=1
#
uname -a
#
# --- create a standard uniform lon,lat regional.grid.[ab]
#
cd ~/HYCOM-examples/GLBp0.08/topo
#
touch      fort.61
/bin/rm -f fort.61*
#
# --- temporary regional.grid.b
#
cat >! regional.grid.b <<'E-o-D'
4500	  'idm   ' = longitudinal array size
2251	  'jdm   ' = latitudinal  array size
'E-o-D'
setenv FOR061  fort.61
setenv FOR061A fort.61A
~wallcraf/hycom/ALL/topo/src/grid_mercator<<'E-o-D'
4500	'idm   ' = longitudinal array size
2251	'jdm   ' = latitudinal  array size
   2	'mapflg' = map flag (0=mercator,2=uniform,4=f-plane)
   1.0	'pntlon' = longitudinal reference grid point on pressure grid
-180.0	'reflon' = longitude of reference grid point on pressure grid
   0.08 'grdlon' = longitudinal grid size (degrees)
   1.0	'pntlat' = latitudinal  reference grid point on pressure grid
 -90.0	'reflat' = latitude of  reference grid point on pressure grid
  0.08  'grdlat' = latitudinal  grid size at the equator (degrees)
'E-o-D'
/bin/mv fort.61  regional.grid.b
/bin/mv fort.61A regional.grid.a
#
cat regional.grid.b
