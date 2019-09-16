#!/bin/csh

#@$-lt 0:04:00
#@$-lT 0:04:00
#@$-lm 4mw
#@$-lM 4mw
#@$-s  /bin/csh
#@$
#
set echo
set time = 1
C
C --- Script to interpolate in time NetCDF CORE2 NYF forcing created
C --- by the core_??????.csh script if NOT using the on-the-fly option 
C --- (i.e. for MAKE_FORCE =0, see expt_XX.X/EXPT.src  )
C --- Edit this script for yrflag = 2 or yrflag = 4 and time increment FINC
C
C

C --- set copy command
if (-e ~${user}/bin/pget) then
C --- remote copy
  setenv pget ~${user}/bin/pget
  setenv pput ~${user}/bin/pput
else
C --- local copy
  setenv pget cp
  setenv pput cp
endif

C --- SP is scratch prefix
C --- DSR is non-specific to config dataset directory
C --- DS  is specific to config dataset directory
C --- P is force output     directory,
C --- S is force scratch  directory,
C --- L is domain interpolated CORE2 file  directory
C
setenv SP  /p/work1/${user}
setenv DSR ${SP}/HYCOM-examples/datasets
setenv DS  ${SP}/HYCOM-examples/GLBt0.72/datasets
setenv L   ${DS}/force/CORE2_NYF
#setenv S   ${DS}/force/CORE2_NYF_6hr_yrflag4
setenv S   ${DS}/force/CORE2_NYF_6hr

C
mkdir -p $S
cd       $S

C
C --- time limits.
C --- use "LIMITI" when starting a run after day zero.
C
# yrflag == 4
#setenv TS 731 
#setenv TM 1096
# yrflag == 2
setenv TS 1096
setenv TM 1461
C
echo "TS =" $TS "TM =" $TM

C --- variables to do 
C
set var = ( airtmp lwdflx glbrad precip spchum wndewd wndnwd)

foreach n ( 1  2 3 4 5 6 7 )

C
C --- grid to interpolate to
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  cp ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  cp ${DS}/topo/regional.grid.a regional.grid.a &
endif

C
C --- Input.
C
touch  fort.20 fort.20a
if (-z fort.20a) then
  ${pget} ${L}/${var[${n}]}.a fort.20a &
endif
if (-z fort.20) then
  ${pget} ${L}/${var[${n}]}.b fort.20  &
endif
setenv FOR020A fort.20a


C
C --- executable
C
/bin/cp ~/HYCOM-tools/force/src/time_interp . &
wait
chmod ug+rx time_interp
ls -laFq

C
C --- NAMELIST input
C
cat <<E-o-D  >! fort.05i
 &AFTIME
  FINC   = 0.25,  ! Time increment between output days    (Days)
  FSTART = ${TS}, ! TIME OF HEAT FLUX START               (Days)
  WSTART = ${TS}, ! TIME OF WIND  START                   (Days)
  TMAX   = ${TM}, ! TIME OF END   OF CURRENT INTEGRATION  (Days)
  TSTART = ${TS}, ! TIME OF START OF CURRENT INTEGRATION  (Days)
 /
 &AFFLAG
  INTERP =   1,  !1:linear; 3:cubic-spline (HERMITE);
  ILIMIT =   1,  !0:no ; 1:yes (ONLY ACTIVE FOR HERMITE INTERPOLATION)
  ICOMBI =   0,  !0:no ; 1:yes (ADD TO HIGH FREQUENCY FLUX FIELDS)
 /
E-o-D

C
C --- run the flux interpolation.
C
touch fort.10 fort.10a
/bin/rm -f fort.10 fort.10a
C
setenv FOR010A fort.10a

C --- execution of the program
echo $PWD
/bin/rm -f core
touch core
./time_interp < fort.05i

C
C --- Output.
C
/bin/mv fort.10  ${var[${n}]}.b
/bin/mv fort.10a ${var[${n}]}.a
rm -rf fort.* core time_interp regional.grid*
end
