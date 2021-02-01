#
set echo
set time=1
#
# --- form subregion grid array index map file, GLBp0.08 to GOMb0.08.
#
#
setenv R ~/HYCOM-examples/GOMb0.08/topo
#
# --- link to GLBp0.08 grid
ln -s ../topo/regional.grid.? .
#
touch   ${R}/regional.gmapi_GLBp0.08.a
/bin/rm ${R}/regional.gmapi_GLBp0.08.[ab]
~/HYCOM-tools/subregion/src/isuba_gmapi <<E-o-D
${R}/regional.grid.a
${R}/regional.gmapi_GLBp0.08.a
GLBp0.08 (4500x2251) to GOMb0.08 (maxinc=3)
  263     'idm   ' = target longitudinal array size
  193     'jdm   ' = target latitudinal  array size
    3     'maxinc' = maximum input array index jump on target grid
E-o-D
