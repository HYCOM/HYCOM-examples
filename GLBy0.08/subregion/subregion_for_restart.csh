#! /bin/csh -x
#PBS -N Rsubregion_for_restart
#PBS -j oe
#PBS -o subregion_for_restart.log
#PBS -W umask=027 
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122
#PBS -q serial
#
module list
set echo
set time = 1
hostname
date
#
# --- form interpolated subregion monthly mean archive files, GLBy0.08 to GOMb0.08.
#
# --- R  is the original region
# --- U  is the target   region
# --- E  is the experiment number
# --- Y  is year
# --- P  is date of the initial condition
# --- S  is the location to run from
# --- D  is the location of the original   archive files
# --- N  is the location of the subregion  archive files
# --- TR is the location of the original  topo    files
# --- TU is the location of the subregion topo    files
# --- VR is the original  depth version (${TR}/depth_${R}_${VR}.[ab])
# --- VU is the subregion depth version (${TU}/depth_${U}_${VU}.[ab])
#
setenv R GLBy0.08 
setenv U GOMb0.08
setenv E 530 
setenv Y 125
setenv P 20240901 
#
setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
setenv X  `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'`
#
setenv S  /p/work1/${user}/HYCOM-examples/${U}/datasets/subregion/
setenv TR /p/work1/${user}/HYCOM-examples/${R}/datasets/topo
setenv TU /p/work1/${user}/HYCOM-examples/${U}/datasets/topo
setenv VR 27
setenv VU 15 
setenv D  /p/work1/${user}/HYCOM-examples/datasets/nest/GLBy0.08/ 
setenv N  /p/work1/${user}/HYCOM-examples/${U}/datasets/subregion/
#
setenv TOOLS  ~/HYCOM-tools
#setenv BINRUN ""
#Cray XC40
#setenv BINRUN "aprun -n 1"
setenv BINRUN ""
#
mkdir -p $N
#
mkdir -p $S
cd       $S
#
/bin/rm   regional.depth.a regional.depth.b
touch     regional.depth.a regional.depth.b
if (-z    regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/ln -s ${TR}/depth_${R}_${VR}.a regional.depth.a
endif
if (-z    regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/ln -s ${TR}/depth_${R}_${VR}.b regional.depth.b
endif
#
touch     regional.grid.a regional.grid.b
if (-z    regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/ln -s ${TR}/regional.grid.a .
endif
if (-z    regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/ln -s ${TR}/regional.grid.b .
endif
#
#

#   no leading expt number for nesting files
    touch   ${N}/archm.${P}_restart.b
    /bin/rm ${N}/archm.${P}_restart.[ab]
    /usr/bin/time ${BINRUN} ${TOOLS}/subregion/src/isubaregion <<E-o-D
${TU}/regional.grid.a
${TU}/regional.gmapi_${R}.a
${TU}/depth_${U}_${VU}.a
regional.depth.a
${D}/US058GCOM-OPSnce.espc-d-031-hycom_fcst_glby008_${P}12_M0000_archm.a
${N}/archm.${P}_restart.a
${R} interpolated to ${U}
 263	  'idm   ' = target longitudinal array size
 193	  'jdm   ' = target latitudinal  array size
   0	  'iceflg' = ice in output archive flag (0=none,1=energy loan model)
   0	  'smooth' = smooth interface depths    (0=F,1=T)
E-o-D

    touch  ${N}/archm.${P}_restart.b
    if (-z ${N}/archm.${P}_restart.b) then
      echo "missing archive file: " ${N}/archm.${P}_restart.b
      exit (2)
    endif

    cd ${S}
  date

\rm region*
