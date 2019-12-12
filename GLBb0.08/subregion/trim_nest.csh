#! /bin/csh -x
#PBS -N Rnest_GOMb0.08
#PBS -j oe
#PBS -o Rnest_GOMb0.08.log
#PBS -W umask=027 
#PBS -l select=1:ncpus=48
#PBS -l place=scatter:excl
#PBS -l walltime=1:30:00
#PBS -A ONRDC10855122
#PBS -q standard
#
module list
set echo
set time = 1
hostname
date
#
# --- form interpolated subregion daily mean archive files, GLBb0.08 to GOMb0.08.
#
# --- R  is the original region
# --- U  is the target   region
# --- E  is the experiment number
# --- Y  is year
# --- P  is month
# --- S  is the location to run from
# --- D  is the location of the original   archive files
# --- N  is the location of the subregion  archive files
# --- TR is the location of the original  topo    files
# --- TU is the location of the subregion topo    files
# --- VR is the original  depth version (${TR}/depth_${R}_${VR}.[ab])
# --- VU is the subregion depth version (${TU}/depth_${U}_${VU}.[ab])
#
setenv R GLBb0.08 
setenv U GOMb0.08
setenv E 153
setenv Y 094
setenv P a
#
setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
setenv X  `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'`
#
setenv S  /p/work1/abozec/HYCOM-examples/${U}/datasets/subregion/36L
setenv TR /p/work1/abozec/HYCOM-examples/${R}/datasets/topo
setenv TU /p/work1/abozec/HYCOM-examples/${U}/datasets/topo
setenv VR 09m11
setenv VU 09m11
setenv D  /p/work1/${user}/HYCOM-examples/datasets/nest_test/GLBb0.08_53.X/subregion
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
# determine start and end days, one day overlap for mean files
#
foreach P ( 01 02 03 04 05 06 07 08 09 10 11 12 )
#
# --- reduce any resulting 41-layer archive files (*_L41.[ab]) to
# --- 36-layers using ALL/archive/src/trim_archm.
#
      cd $S
      ln -sf ${TU}/regional.grid.a    regional.grid.a
      ln -sf ${TU}/regional.grid.b    regional.grid.b
      ln -sf ${TU}/depth_${U}_${VU}.a regional.depth.a
      ln -sf ${TU}/depth_${U}_${VU}.b regional.depth.b
    if (-e ${N}/archm.1994_${P}_2015_${P}.b) then
      touch   archm.1994_${P}_2015_${P}_36L.a
      /bin/rm archm.1994_${P}_2015_${P}_36L.[ab]
#      /usr/bin/time ${BINRUN} ${TOOLS}/archive/src/trim_archv <<E-o-D
${BINRUN} ${TOOLS}/archive/src/trim_archv <<E-o-D
${N}/archm.1994_${P}_2015_${P}.b
archm.1994_${P}_2015_${P}_36L.b
${E}    'iexpt ' = experiment number x10 (000=from archive file)
  3     'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
263     'idm   ' = longitudinal array size
193     'jdm   ' = latitudinal  array size
 41     'kdmold' = original number of layers
 36     'kdmnew' = target   number of layers
 34.0   'thbase' = reference density (sigma units)
  17.00   'sigma ' = layer  1 isopycnal target density (sigma units)
  18.00   'sigma ' = layer  2 isopycnal target density (sigma units)
  19.00   'sigma ' = layer  3 isopycnal target density (sigma units)
  20.00   'sigma ' = layer  4 isopycnal target density (sigma units)
  21.00   'sigma ' = layer  5 isopycnal target density (sigma units)
  22.00   'sigma ' = layer  6 isopycnal target density (sigma units)
  23.00   'sigma ' = layer  7 isopycnal target density (sigma units)
  24.00   'sigma ' = layer  8 isopycnal target density (sigma units)
  25.00   'sigma ' = layer  9 isopycnal target density (sigma units)
  26.00   'sigma ' = layer 10 isopycnal target density (sigma units)
  27.00   'sigma ' = layer 11 isopycnal target density (sigma units)
  28.00   'sigma ' = layer 12 isopycnal target density (sigma units)
  29.00   'sigma ' = layer 13 isopycnal target density (sigma units)
  29.90   'sigma ' = layer 14 isopycnal target density (sigma units)
  30.65   'sigma ' = layer  A isopycnal target density (sigma units)
  31.35   'sigma ' = layer  B isopycnal target density (sigma units)
  31.95   'sigma ' = layer  C isopycnal target density (sigma units)
  32.55   'sigma ' = layer  D isopycnal target density (sigma units)
  33.15   'sigma ' = layer  E isopycnal target density (sigma units)
  33.75   'sigma ' = layer  F isopycnal target density (sigma units)
  34.30   'sigma ' = layer  G isopycnal target density (sigma units)
  34.80   'sigma ' = layer  H isopycnal target density (sigma units)
  35.20   'sigma ' = layer  I isopycnal target density (sigma units)
  35.50   'sigma ' = layer 15 isopycnal target density (sigma units)
  35.80   'sigma ' = layer 16 isopycnal target density (sigma units)
  36.04   'sigma ' = layer 17 isopycnal target density (sigma units)
  36.20   'sigma ' = layer 18 isopycnal target density (sigma units)
  36.38   'sigma ' = layer 19 isopycnal target density (sigma units)
  36.52   'sigma ' = layer 20 isopycnal target density (sigma units)
  36.62   'sigma ' = layer 21 isopycnal target density (sigma units)
  36.70   'sigma ' = layer 22 isopycnal target density (sigma units)
  36.77   'sigma ' = layer 23 isopycnal target density (sigma units)
  36.83   'sigma ' = layer 24 isopycnal target density (sigma units)
  36.89   'sigma ' = layer 25 isopycnal target density (sigma units)
  36.97   'sigma ' = layer 26 isopycnal target density (sigma units)
  37.02   'sigma ' = layer 27 isopycnal target density (sigma units)
E-o-D
  endif
  date
end

\rm region*
