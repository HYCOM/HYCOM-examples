#! /bin/csh -x
#
# --- check that the C comment command is available.
#
C >& /dev/null
if (! $status) then
  if (-e ${home}/HYCOM-tools/bin/C) then
    set path = ( ${path} ${home}/HYCOM-tools/bin )
  else
    echo "Please put the command HYCOM-tools/bin/C in your path"
  endif
endif
#
set echo
set time = 1
set timestamp
C
C --- Experiment GOMb0.08 - 01.0 series
C --- Create CICE forcing on 0.08 degree Gulf of Mexico region
C --- 01.1 - cfsr_gom

C --- EX is experiment directory, required because batch systems often start scripts in home
C
setenv EX /p/home/wallcraf/HYCOM-examples/GOMb0.08/cice_01.1
C
C --- Preamble, defined in EXPT.src
C
C --- OS is operating system of machine
C --- R is region name.
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- SCR is the scratch directory prefix.
C --- S is scratch directory, must not be the permanent directory.
C --- DS is the datasets directory.
C --- MAKE_FORCE is logical for creating forcing at run time.
C --- N is the name of the atmospheric forcing for PRE-processing.
C
source ${EX}/EXPT.src
C
C --- get to the scratch directory
C
mkdir -p $S
cd       $S
C
C --- For whole year runs.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- For a few hour/day run
C ---   A   is the start day and hour, of form "dDDDhHH".
C ---   B   is the end   day and hour, of form "dXXXhYY".
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- Note that these variables are set by the .awk generating script.
C
setenv A "a"
setenv B "b"
setenv Y01 "094"
setenv YXX "094"
setenv YOF `echo ${Y01} | awk '{printf("%04.0f", $1+1900)}'`
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}

C --- annual offset, if needed
C
setenv YOF ""
#setenv YOF `echo ${Y01} | awk '{printf("%04.0f", $1+1900)}'`
C
C --- local input files.
C
if (-e    ${D}/../${E}y${Y01}${A}.limits) then
  /bin/cp ${D}/../${E}y${Y01}${A}.limits limits
else
#  use "LIMITI"  when starting a run after day zero.
#  use "LIMITS9" (say) for a 9-day run
  echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} >! limits
endif
cat limits
C
C --- pget, pput "copy" files between scratch and permanent storage.
C --- Can both be cp if the permanent filesystem is mounted locally.
C
switch ($OS)
case 'AIX':
case 'unicos':
case 'HPE':      
case 'ICE':      
case 'IDP':
case 'XC30':
case 'XC40':
    if      (-e   ~${user}/bin/pget_navo) then
      setenv pget ~${user}/bin/pget_navo
      setenv pput ~${user}/bin/pput_navo
    else if (-e   ~${user}/bin/pget) then
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
C --- input files from file server.
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
   ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
if (-z regional.grid.b) then
   ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
C
C --- vapmix or spchum
C
setenv HUM vapmix
#setenv HUM spchum 
C
C --- let all file copies complete.
C
wait
C
C --- Just in time atmospheric forcing.
C
if ( ${MAKE_FORCE} >= 1 ) then
  # present run forcing
  /bin/rm -f ${E}preA${Y01}${A}.csh ${E}preA${Y01}${A}.log
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}preA.csh > ${E}preA${Y01}${A}.csh
  csh ${E}preA${Y01}${A}.csh >&  ${E}preA${Y01}${A}.log
endif
wait
/bin/ls -laFq cice
