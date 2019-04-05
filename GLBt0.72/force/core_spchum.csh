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
C --- Script to horizontally interpolate NetCDF CORE2 NYF spec. humidity forcing to
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
setenv CDF071 $L/q_10.15JUNE2009.nc
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
  CNAME  = 'spchum',
  CVNAME = 'Q_10_MOD',
 &END
 &AFTIME
  PARMIN =     0.0,  !downward flux is always non-negative
  PARMAX = 9999.0,   !disable maximum
  PAROFF =    0.0,   !none
  FSTART = 1096.125,   !Jan 01, climo
  WSTART = 1096.125,   !Jan 01, climo
  TSTART =    0.125,   !Jan 01, climo
  TMAX   =  364.875,   !Dec 31, climo
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
/bin/mv fort.10  ./spchum.b
/bin/mv fort.10A ./spchum.a
C
#${pput} spchum.b ${D}/spchum.b
#${pput} spchum.a ${D}/spchum.a
C
C --- Delete all files.
C
/bin/rm -f regional.* ./kp_core
