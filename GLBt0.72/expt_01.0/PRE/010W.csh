#!/bin/csh -x
#PBS -N 373w
#PBS -j oe
#PBS -o 373w.log
#PBS -W umask=027 
#PBS -l application=hycom
#PBS -l mppwidth=8
#PBS -l mppnppn=8
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122 
#PBS -q standard
#
set echo
set time = 1
set timestamp
date +"START  %c"
C
C --- Create 3hrly interannual forcing from 3hrly climo forcing.
C ---
C --- prebuild this script similar to a model script
# --- awk -f 284.awk y01=098 ab=a 284W.csh > 284w098a.csh
C
C --- EX is experiment directory
C
setenv EX /p/home/abozec/HYCOM-examples/GLBt0.72/expt_01.0
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C --- N is data-set name, e.g. ec10m-reanal
C
source ${EX}/EXPT.src
C
setenv BINRUN ""
C
C --- Operative System
C
switch ($OS)
case 'SunOS':
C   assumes /usr/5bin is before /bin and /usr/bin in PATH.
    breaksw
case 'Linux':
case 'OSF1':
    breaksw
case 'IRIX64':
    breaksw
case 'AIX':
    breaksw
case 'XC30':
case 'XC40':
# --- ~/HYCOM-tools/bin is for CNL (ftn)
      setenv BINRUN   "aprun -n 1"
case 'HPE':
case 'unicosmk':
    setenv ACCT `groups | awk '{print $1}'`
    breaksw
case 'unicos':
    setenv ACCT `newacct -l | awk '{print $4}'`
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
    lfs setstripe -d $S
    lfs setstripe    $S -s 1048576 -i -1 -c 8
    breaksw
endsw
C
C --- create directory if not there
mkdir -p $S/wind
cd       $S/wind
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
C --- For winds, only Y01 and A are used.
C
C --- One year spin-up run.
C
@ ymx =  1
C
setenv A "a"
setenv B "b"
setenv Y01 "011"
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
C --- use "LIMITI" when starting a run after day zero.
C
setenv TS `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $1}'`
setenv TM `echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} | awk '{print $2}'`
C
echo "TS =" $TS "TM =" $TM
C
C --- input files from file server.
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
foreach f ( tauewd taunwd wndspd )
  touch ${f}.a
  if (-z ${f}.a) then
    ${pget} ${DS}/force/${N}/${f}.a ${f}.a &
  endif
  touch ${f}.b
  if (-z ${f}.b) then
    ${pget} ${DS}/force/${N}/${f}.b ${f}.b &
  endif
end
C
C --- executable
C
/bin/cp ~/HYCOM-tools/force/src/time_interp . &
wait
chmod ug+rx time_interp
ls -laFq
C
C --- NAMELIST input.
C
touch   fort.05i
/bin/rm fort.05i
cat <<E-o-D  > fort.05i
 &AFTIME
  FINC   = 0.125
  FSTART = ${TS},  !TIME OF HEAT FLUX START              (DAYS)
  WSTART = ${TS},  !TIME OF WIND START                   (DAYS)
  TSTART = ${TS},  !TIME OF START OF CURRENT INTEGRATION (DAYS)
  TMAX   = ${TM},  !TIME OF END   OF CURRENT INTEGRATION (DAYS)
 /
 &AFFLAG
  INTERP =   1,  !linear
 /
E-o-D
C
C --- run the wind extraction
C
touch      fort.10 fort.10a
/bin/rm -f fort.10 fort.10a
C
foreach f ( tauewd taunwd wndspd )
  date +"$f %c"
  setenv FOR010A fort.10a
C
C --- Input.
C
  setenv FOR020  ${f}.b
  setenv FOR020A ${f}.a
C
switch ($OS)
case 'SunOS':
case 'Linux':
case 'OSF1':
case 'AIX':
case 'HPE':
case 'XT4':
case 'XC30':
case 'XC40':
    /bin/rm -f core
    touch core
    ${BINRUN} ./time_interp < fort.05i
    breaksw
case 'IRIX64':
    /bin/rm -f core
    touch core
    assign -V
    ./time_interp < fort.05i
    assign -V
    assign -R
    breaksw
case 'unicosmk':
    /bin/rm -f core
    touch core
    assign -V
    ./time_interp < fort.05i
    if (! -z core)  debugview time_interp core
    assign -V
    assign -R
    breaksw
case 'unicos':
    /bin/rm -f core
    touch core
    assign -V
    ./time_interp < fort.05i
    if (! -z core)  debug -s time_interp core
    assign -V
    assign -R
    breaksw
endsw
C
C --- Output.
C
  /bin/mv fort.10  ${f}_${Y01}${A}.b
  /bin/mv fort.10a ${f}_${Y01}${A}.a
C
  if (-e ./SAVE) then
    ln ${f}_${Y01}${A}.a ./SAVE/${f}_${Y01}${A}.a
    ln ${f}_${Y01}${A}.b ./SAVE/${f}_${Y01}${A}.b
  endif
end
C
C  --- END OF JUST IN TIME WIND EXTRACTION SCRIPT.
C
date +"END    %c"
#
#/usr/lpp/LoadL/full/bin/llq -w $LOADL_STEP_ID
