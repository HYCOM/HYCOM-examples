#
set echo
set time=1
#
# --- form subregion grid array index map file, GLBb0.08 to GOMb0.08.
#
setenv R /p/work1/abozec/HYCOM-examples/GOMb0.08/datasets/topo
#
ln -s /p/work1/abozec/HYCOM-examples/GLBb0.08/datasets/topo/regional.grid.? .
#
touch   ${R}/regional.gmapi_GLBb0.08.a
/bin/rm ${R}/regional.gmapi_GLBb0.08.[ab]
~/HYCOM-tools/subregion/src/isuba_gmapi <<E-o-D
${R}/regional.grid.a
${R}/regional.gmapi_GLBb0.08.a
GLBb0.08  (4500x3298) to GOMb0.08 (maxinc=3)
  263     'idm   ' = target longitudinal array size
  193     'jdm   ' = target latitudinal  array size
    3     'maxinc' = maximum input array index jump on target grid
E-o-D
