#!/bin/csh -x
#PBS -N restart_153_018a
#PBS -j oe
#PBS -o restart_153_018a.log
#PBS -W umask=027
# only need a single node
#PBS -l select=1:ncpus=32
#PBS -l place=scatter:excl
#PBS -l walltime=0:30:00
#PBS -A NRLSS03755018
#PBS -q debug
#
set echo
#
# --- Form a HYCOM restart file from a HYCOM archive file.
#
setenv R /p/work1/${user}/HYCOM-examples/GOMb0.08/expt_01.0/data/
setenv D /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/subregion/
setenv T 07
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/
setenv O /p/work1/${user}/HYCOM-examples/GOMb0.08/expt_01.1/data/

#
mkdir -p ${O}
cd       ${O}
#
touch regional.depth.a regional.depth.b
if (-z regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/ln -s ${DS}/topo/depth_GOMb0.08_${T}.a regional.depth.a
endif
if (-z regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/ln -s ${DS}/topo/depth_GOMb0.08_${T}.b regional.depth.b
endif
#
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/ln -s ${DS}/topo/regional.grid.a .
endif
if (-z regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/ln -s ${DS}/topo/regional.grid.b .
endif
#
# ---  input archive file
# ---  input restart file
# --- output restart file
#
/bin/rm -f ${O}/restart_094a.a ${O}/restart_094a.b
#aprun -n 1 ~/HYCOM-tools/archive/src/archv2restart <<E-o-D
~/HYCOM-tools/archive/src/archv2restart <<E-o-D
${D}/archm.1994_01.a
${R}/restart_001b.a
${O}/restart_094a.a
 010     'iexpt ' = experiment number x10 (000=from archive file)
  3     'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
263     'idm   ' = longitudinal array size
193     'jdm   ' = latitudinal  array size
  2     'kapref' = thermobaric ref. state (-1=input,0=none,1,2,3=constant)
 41     'kdm   ' = number of layers
 34.0   'thbase' = reference density (sigma units)
900.0   'baclin' = baroclinic time step (seconds), int. divisor of 86400
E-o-D
