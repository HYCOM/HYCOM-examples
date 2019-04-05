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
C --- Script to horizontally interpolate NetCDF CORE2 NYF u10,v10 forcing to
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
setenv CDF071 $L/uv_10.15JUNE2009.nc
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
cp ~/HYCOM-tools/force/src/wi_core . &

C
wait
chmod a+rx wi_core
C

/bin/rm -f fort.1[01234]*
C
setenv FOR010  fort.10
setenv FOR011  fort.11
setenv FOR012  fort.12
setenv FOR010A fort.10A
setenv FOR011A fort.11A
setenv FOR012A fort.12A
C
./wi_core <<'E-o-D'
 &WWTITL
  CTITLE = '123456789012345678901234567890123456789012345678901234567890',
  CTITLE = 'CORE CIAFv2, std, m/s',
  CNAME  = 'wndewd',   'wndnwd',   !actually wndxwd and wndywd
  CVNAME = 'U_10_MOD', 'V_10_MOD',
 /
 &WWTIME
  SPDMIN =    0.0,     !minimum allowed wind speed
  WSCALE =    1.0,     !scale factor to mks
  WSTART = 1096.125,   !Jan 01, climo
  TSTART =    0.125,   !Jan 01, climo
  TMAX   =  364.875,   !Dec 31, climo
 /
 &WWFLAG
  IGRID  =   2,  !0=p; 1=u&v; 2=p
  ISPEED =  -2,  !0:none; 1:const; 2:kara; 3:coare; -1,-2:input wind velocity
  INTERP =   3,  !0:bilinear; 1:cubic spline; 2:piecewise bessel; 3:piecewise bi-cubic;
  INTMSK =   0,  !0:no mask; 1:land/sea=0/1; 2:l/s=1/0;
  IFILL  =   3,  !0,1:tx&ty; 2,3:magnitude; 1,3:smooth; (intmsk>0 only)
  IOFILE =   0,  !0:single offset; 1:multiple offsets; 2:multi-off no .b check
  IWFILE =   4,  !1:ann/mon; 2:multi-file; 4:actual wind day
 /
'E-o-D'
C
C --- 6-hrly Output
C
/bin/mv fort.10  wndewd.b
/bin/mv fort.10A wndewd.a
/bin/mv fort.11  wndnwd.b
/bin/mv fort.11A wndnwd.a
/bin/rm fort.12
/bin/rm fort.12A

C
#${pput} wndewd.b ${D}/wndewd.b
#${pput} wndewd.a ${D}/wndewd.a
#${pput} wndnwd.b ${D}/wndnwd.b
#${pput} wndnwd.a ${D}/wndnwd.a

C
C --- Delete all files.
C
/bin/rm -f regional* ./wi_core
