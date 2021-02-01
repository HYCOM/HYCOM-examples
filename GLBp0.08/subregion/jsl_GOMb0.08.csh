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

setenv DO ~/HYCOM-examples/${RO}/relax/DRAG
setenv DT ~/HYCOM-examples/${RT}/relax/DRAG
#
if (! -e ${DT} ) mkdir -p ${DT}
#
cd ~/HYCOM-examples/${RO}/subregion
#
ln -s ../topo/regional.grid.? .
#
/bin/rm -f ${DT}/JSL.a
/bin/rm -f ${DT}/JSL.b
~/HYCOM-tools/subregion/src/isuba_field <<E-o-D
../../${RT}/topo/regional.gmapi_${RO}.a
NONE
NONE
${DO}/JSL.a
${DT}/JSL.a
  263     'idm   ' = target longitudinal array size
  193     'jdm   ' = target latitudinal  array size
   0      'khead ' = number of header lines at start of     .b files
  10      'kskip ' = number of characters before min,max in .b files
E-o-D
date
##
## --- if target is a global tripole grid enforce top boundary, 
## ---  only needed due to round off differences
##
#hycom_arctic ${DTR}/JSL.a 263 193 1 ${DTR}/JSL.A
#/bin/mv      ${DTR}/JSL.A ${DTR}/JSL.a
