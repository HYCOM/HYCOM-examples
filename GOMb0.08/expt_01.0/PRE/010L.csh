#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
# single node
#PBS -l select=1:ncpus=24
#PBS -l walltime=04:00:00
#PBS -l application=hycom
#PBS -A NRLSS03755018
#PBS -q standard
#
set echo
set time = 1
set timestamp
date +"START  %c"
C
C --- Create model interpolated lwdflx for HYCOM.
C --- From NWP NRL .nc files.
C
C --- prebuild this script similar to a model script
# --- awk -f 284.awk y01=098 ab=a 284L.csh > 284l098a.csh
C
C --- EX is experiment directory
C
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.0
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C --- N is data-set name, e.g. cfsr.
C --- W is permanent NWP NRL .nc files directory.
C
source ${EX}/EXPT.src
C
C --- System Type
C
switch ($OS)
case 'SunOS':
C   assumes /usr/5bin is before /bin and /usr/bin in PATH.
    setenv BINRUN   ""
    breaksw
case 'Linux':
case 'OSF1':
case 'IRIX64':
case 'AIX':
    setenv BINRUN   ""
    breaksw
case 'HPE':
#   load modules
    unset echo
    source ~/HYCOM-tools/Make_ncdf.src
    set echo
    setenv BINRUN   ""
    breaksw
case 'XC30':
case 'XC40':
# --- ~/HYCOM-tools/bin is for CNL (ftn)
    setenv BINRUN   "aprun -n 1"
    breaksw
default:
    echo 'Unknown Operating System: ' $OS
    exit (1)
endsw
C
C --- pget, pput "copy" files between scratch and permanent storage.
C --- Can both be cp if the permanent filesystem is mounted locally.
C
switch ($OS)
case 'SunOS':
case 'Linux':
case 'HPE':
case 'XT4':
case 'OSF1':
case 'AIX':
case 'unicos':
case 'unicosmk':
    if (-e        ~${user}/bin/pget) then
      setenv pget ~${user}/bin/pget
      setenv pput ~${user}/bin/pput
    else
      setenv pget /bin/cp
      setenv pput /bin/cp
    endif
    breaksw
default:
      setenv pget /bin/cp
      setenv pput /bin/cp
endsw
C
switch ($OS)
case 'XT4':
case 'XC30':
case 'XC40':
    mkdir -p      $S
    lfs setstripe $S -S 1048576 -i -1 -c 8
    breaksw
endsw
C
mkdir -p $S/lrad
cd       $S/lrad
C
C --- For whole year runs.
C ---   ymx number of years per model run.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 initial model year of this run.
C ---   YXX year at end of this part year run.
C ---   ymx is 1.
C --- Note that these variables and the .awk generating script must
C ---  be consistant to get a good run script.
C
C --- One year spin-up run.
C
@ ymx =  1
C
setenv A "a"
setenv B "b"
setenv Y01 "001"
C
switch ("${B}")
case "${A}":
    setenv YXX `echo $Y01 $ymx | awk '{printf("%03d", $1+$2)}'`
    breaksw
case "a":
    setenv YXX `echo $Y01 | awk '{printf("%03d", $1+1)}'`
    breaksw
default:
    setenv YXX $Y01
endsw
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}
C
C --- time limits.
C
if (-e ${D}/../${E}y${Y01}${A}.limits) then
  setenv TS `sed -e "s/-/ /g" ${D}/../${E}y${Y01}${A}.limits | awk '{print $1}'`
  setenv TM `cat              ${D}/../${E}y${Y01}${A}.limits | awk '{print $2}'`
else
# use "LIMITI" when starting a run after day zero.
# use "LIMITS9" (say) for a 9-day run.
  setenv TS `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $1}'`
  setenv TM `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $2}'`
endif
C
echo "TS =" $TS "TM =" $TM
C
C --- input files from file server.
C
touch  regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
setenv YC1 `echo $Y01 | awk '{printf("%04d\n",$1+1900)}'`
setenv YCX `echo $YXX | awk '{printf("%04d\n",$1+1900)}'`
setenv CDF071 ${N}-sec_${YC1}_01hr_dlwsfc.nc
setenv CDF072 ${N}-sec_${YCX}_01hr_dlwsfc.nc
## use sea version like GLBb0.08 15.3
#setenv CDF071 ${N}-sea_${YC1}_01hr_dlwsfc.nc
#setenv CDF072 ${N}-sea_${YCX}_01hr_dlwsfc.nc
C
touch  $CDF071
if (-z $CDF071) then
  ${pget} ${W}/$CDF071 . &
endif
C
if ($CDF071 != $CDF072) then
  touch  $CDF072
  if (-z $CDF072) then
    ${pget} ${W}/$CDF072 . &
  endif
endif
C
C --- executable
C
/bin/cp ~/HYCOM-tools/force/src/kp_nc . &
wait
chmod ug+rx kp_nc
ls -laFq
C
C --- NAMELIST input.
C
touch   fort.05i
/bin/rm fort.05i
cat <<E-o-D  > fort.05i
 &AFTITL
  CTITLE = '1234567890123456789012345678901234567890',
  CTITLE = '${N}, 1-hrly, sea-only, W/m^2',
  CTITLE = '${N}, 1-hrly, sec-CERES, W/m^2',
  CNAME  = 'dlwflx',
 /
 &AFTIME
  FSTART = ${TS},
  TSTART = ${TS},
  TMAX   = ${TM},
  PARMIN = -9999.0,  !disable parmin
  PARMAX =  9999.0,  !disable parmax
  PAROFF =     0.0,  !no offset
 /
 &AFFLAG
  IFFILE =   5,  !3:monthly; 5:actual day;
  INTERP =   0,  !0:bilinear; 1:cubic spline; 2:piecewise bessel; 3:piecewise bi-cubic;
  INTMSK =   0,  !0:no mask; 1:land/sea=0/1; 2:land/sea=1/0;
 /
E-o-D
C
C --- run the lwdflx interpolation.
C
date +"lwdflx %c"
touch      fort.10 fort.10a
/bin/rm -f fort.10 fort.10a
C
setenv FOR010A fort.10a
C
/bin/rm -f core
touch      core
${BINRUN} ./kp_nc < fort.05i
C
C --- Output.
C
/bin/mv fort.10  lwdflx_${Y01}${A}.b
/bin/mv fort.10a lwdflx_${Y01}${A}.a
C
if (-e ./SAVE) then
  ln lwdflx_${Y01}${A}.a ./SAVE/lwdflx_${Y01}${A}.a
  ln lwdflx_${Y01}${A}.b ./SAVE/lwdflx_${Y01}${A}.b
endif
C
C  --- END OF JUST IN TIME LWDFLX GENERATION SCRIPT.
C
date +"END    %c"
