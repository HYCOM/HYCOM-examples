#! /bin/csh
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
C --- Script to horizontally interpolate NetCDF CORE2 NYF precip forcing to
C --- HYCOM grid configuration
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
C --- L is CORE2 raw file  directory
C
setenv SP  /p/work1/${user}
setenv DSR ${SP}/HYCOM-examples/datasets
setenv DS  ${SP}/HYCOM-examples/GLBt0.72/datasets
setenv S   ${DS}/force/CORE2_NYF

setenv L   ${DSR}/CORE2_NYF
C
mkdir -p $S
cd       $S

C
C --- Input.
C
touch      fort.70
/bin/rm -f fort.70
#${pget} /home/hermes/metzger/fnmoc/nogaps_mask_360x181.D fort.70 &
#ln -s /home/hermes/metzger/fnmoc/nogaps_mask_360x181.D fort.70 &
C
setenv CDF071 $L/ncar_precip.15JUNE2009.nc
C
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
C --- get executable
C
cp ~/HYCOM-tools/force/src/kp_core . &

C
wait
chmod a+rx kp_core
C

/bin/rm -f fort.1[01234]*
C
setenv FOR010A fort.10A
C
/bin/rm -f fort.10
./kp_core <<'E-o-D'
 &AFTITL
  CTITLE = '1234567890123456789012345678901234567890',
  CTITLE = 'CORE CNYFv2, std',
  CNAME  = 'precip',
  CVNAME = 'PRC_MOD',
 &END
 &AFTIME
  PARMIN = -9999.0,  !disable minimum
  PARMAX =  9999.0,  !disable maximum
  PAROFF =    0.0,   !none
  PARSCL = 1.0E-3,   !kg/s/m^2 to m/s
  FSTART = 1111.5,   !Jan 15, climo
  WSTART = 1111.5,   !Jan 15, climo
  TSTART =   15.5,   !Jan 15, climo
  TMAX   =  349.5,   !Dec 16, climo
 &END
 &AFFLAG
  IFFILE =   5,  !3:monthly; 5:actual
  INTERP =   0,  !0:piecewise-linear; 1:cubic-spline;
  INTMSK =   0,  !0:no mask; 1:land/sea=0/1; 2:land/sea=1/0;
 &END
'E-o-D'
C
C --- 6-hrly Output
C
/bin/mv fort.10  ./precip.b
/bin/mv fort.10A ./precip.a
C
#${pput} lwdflx.b ${D}/lwdflx.b
#${pput} lwdflx.a ${D}/lwdflx.a
C
C --- Delete all files.
C
/bin/rm -f regional.* ./kp_core
