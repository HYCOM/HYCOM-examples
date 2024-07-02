#!/bin/csh -x
#
set echo
set time=1
#
# --- fill all small enclosed seas in a hycom topography,
# --- rescale below 6500m, clip to 5m depth, ands smooth once.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools
#
cd $DS
#
setenv FOR051  fort.51
setenv FOR051A fort.51A
setenv FOR061  fort.61
setenv FOR061A fort.61A
#
# --- input: minsea
# --- fill all seas smaller than minsea
#
/bin/ln -s depth_GOMb0.08_19.b fort.51
/bin/ln -s depth_GOMb0.08_19.a fort.51A
echo 3000 | ${TOOLS}/topo/src/topo_onesea_fill
/bin/mv fort.61  depth_GOMb0.08_19f.b
/bin/mv fort.61A depth_GOMb0.08_19f.a
/bin/rm -f fort.[56]1*
#
# --- input: bref,bscl
# --- change any values deeper than bref to bref+bscl*(b-bref)
#
/bin/ln -s depth_GOMb0.08_19f.b fort.51
/bin/ln -s depth_GOMb0.08_19f.a fort.51A
echo 6500.0 0.2 | ${TOOLS}/topo/src/topo_shrink
/bin/mv fort.61  depth_GOMb0.08_19fs.b
/bin/mv fort.61A depth_GOMb0.08_19fs.a
/bin/rm -f fort.[56]1*
#
# --- input: bmin,bmax
# --- clip any values outside bmin:bmax to bmin or bmax
#
/bin/ln -s depth_GOMb0.08_19fs.b fort.51
/bin/ln -s depth_GOMb0.08_19fs.a fort.51A
echo 5.0 8500.0 | ${TOOLS}/topo/src/topo_clip
#/bin/mv fort.61  depth_GOMb0.08_19fsc.b
head -n 3 fort.61 >! depth_GOMb0.08_19fsc.b
echo "Filled all small seas; Scaled by 0.2 below 6500m; Clip to 5m" >> depth_GOMb0.08_19fsc.b
echo " " >> depth_GOMb0.08_19fsc.b
tail -n 1 fort.61 >> depth_GOMb0.08_19fsc.b
/bin/mv fort.61A depth_GOMb0.08_19fsc.a
/bin/rm -f fort.[56]1*
#
# --- input: nsmth,nskip
# --- nsmth smoothing passes, except within nskip of land
#
/bin/ln -s depth_GOMb0.08_19fsc.b fort.51
/bin/ln -s depth_GOMb0.08_19fsc.a fort.51A
echo 1 2 | ${TOOLS}/topo/src/topo_smooth_skip
/bin/mv fort.61  depth_GOMb0.08_20.b
/bin/mv fort.61A depth_GOMb0.08_20.a
/bin/rm -f fort.[56]1*
