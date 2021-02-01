#!/bin/csh -x
#
set echo
date
#
# --- form interpolated subregion fields, GLBp0.08 to GOMb0.08.
#
# --- RO is original region name.
# --- RT is target   region name.
#
# --- output is HYCOM .a files.
#
setenv RO GLBp0.08
setenv RT GOMb0.08

setenv DO ~/HYCOM-examples/${RO}/TPXO9atlas
setenv DT ~/HYCOM-examples/${RT}/TPXO9atlas
#
if (! -e ${DT} ) mkdir -p ${DT}
#
cd ~/HYCOM-examples/${RO}/subregion
#
ln -s ../topo/regional.grid.? .
#
/bin/rm -f ${DT}/tpxo9a_tide_hReIm_GLBp.a
/bin/rm -f ${DT}/tpxo9a_tide_hReIm_GLBp.b
~/HYCOM-tools/subregion/src/isuba_field <<E-o-D
../../${RT}/topo/regional.gmapi_${RO}.a
NONE
NONE
${DO}/tpxo9a_tide_hReIm.a
${DT}/tpxo9a_tide_hReIm_GLBp.a
  263     'idm   ' = target longitudinal array size
  193     'jdm   ' = target latitudinal  array size
   0      'khead ' = number of header lines at start of     .b files
   23      'kskip ' = number of characters before min,max in .b files
E-o-D
date
