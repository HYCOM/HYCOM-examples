#!/bin/csh

#
set echo
set time = 1
C
C --- Create HYCOM CHL files.
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

C
C --- DSR   is path to non specific domain datasets
C --- DS    is path to specific domain datasets
C --- S     is scratch directory
C
setenv DSR /p/work1/${user}/HYCOM-examples/datasets
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets
setenv S ${DS}/force/seawifs
C
mkdir -p $S
cd       $S
C
C --- Input Chlorophyll file
C
touch      fort.71
/bin/rm -f fort.71
ln -s  ${DS}/../../datasets/seawifs/chlor_a_9km.D fort.71 &
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
#${pget} ~/hycom/ALL/force/src/kp . &
cp ~/HYCOM-tools/force/src/kp . &
wait
chmod a+rx kp
C
/bin/rm -f fort.1[01234]*
C
setenv FOR010A fort.10A
C
C
./kp <<'E-o-D'
 &AFTITL
  CTITLE = '1234567890123456789012345678901234567890',
  CTITLE = 'SeaWifs monthly clim, mg/m^3',
  CNAME  = '   chl',
 /
 &AFTIME
  PARMIN =    0.01, !minimum chl
  PARMAX =  100.00, !maximum chl
 /
 &AFFLAG
  INTERP =    0,  !0:piecewise-linear; 1:cubic-spline;
  INTMSK =    0,  !0:no mask; 1:land/sea=0/1; 2:land/sea=1/0;
 /
'E-o-D'
C
C
C --- Output.
C
mv fort.10  chl.b
mv fort.10A chl.a
#${pput} chl.b ${D}/chl.b
#${pput} chl.a ${D}/chl.a
C
C --- Delete all files.
C
/bin/rm -f fort.71 kp region*
