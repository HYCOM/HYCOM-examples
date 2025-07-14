#!/bin/csh -x
#PBS -N archv2restart_start_espc
#PBS -j oe
#PBS -o archv2restart_start_espc.log
#PBS -W umask=027
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122
#PBS -q serial
#
set echo
#
# --- Form a HYCOM restart file from a HYCOM archive file.
#
setenv R /p/work1/${user}/HYCOM-examples/GOMb0.08/expt_01.4/data/
setenv D /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/subregion/
setenv T 15 
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/
setenv O /p/work1/${user}/HYCOM-examples/GOMb0.08/expt_01.4/data/
#
setenv DY 01
setenv MN 09
setenv P  i
setenv YR 124
setenv YY `echo ${YR} | awk '{printf("%04d", $1+1900)}'`
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
# --- restart is at 00Z, archive might be at 12Z
setenv WD `echo ${YY} ${MN} ${DY} 00 | ~/HYCOM-tools/bin/hycom_ymdh_wind | cut -c 2-6`
echo $WD
touch   ${D}/archm.${YY}${MN}${DY}_restart.B
if ( -z ${D}/archm.${YY}${MN}${DY}_restart.B) then
  /bin/mv ${D}/archm.${YY}${MN}${DY}_restart.b ${D}/archm.${YY}${MN}${DY}_restart.B
  sed -e "s/${WD}.50/${WD}.00/g" ${D}/archm.${YY}${MN}${DY}_restart.B >! ${D}/archm.${YY}${MN}${DY}_restart.b
endif
#
# ---  input archive file
# ---  input restart file
# --- output restart file
/bin/rm -f ${O}/restart_${YR}${P}.a ${O}/restart_${YR}${P}.b
#aprun -n 1 ~/HYCOM-tools/archive/src/archv2restart <<E-o-D
~/HYCOM-tools/archive/src/archv2restart <<E-o-D
${D}/archm.${YY}${MN}${DY}_restart.a
${R}/restart_001b.a
${O}/restart_${YR}${P}.a
 014     'iexpt ' = experiment number x10 (000=from archive file)
  3     'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
263     'idm   ' = longitudinal array size
193     'jdm   ' = latitudinal  array size
  2     'kapref' = thermobaric ref. state (-1=input,0=none,1,2,3=constant)
 41     'kdm   ' = number of layers
 34.0   'thbase' = reference density (sigma units)
900.0   'baclin' = baroclinic time step (seconds), int. divisor of 86400
  1     'rmontg' = pbavg correction from relax.montg file  (0=F,1=T)
${R}/relax.montg.a
E-o-D
