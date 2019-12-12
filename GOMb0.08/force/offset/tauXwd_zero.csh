#! /bin/csh
#
set echo
set time = 1
C
C --- Script to create HYCOM zero wind stress files.
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
C --- DS  is specific to region dataset directory
C --- S is force scratch  directory,
C
setenv SP  /p/work1/${user}
setenv DS  ${SP}/HYCOM-examples/GOMb0.08/datasets
setenv S   ${DS}/force/offset
C
mkdir -p $S
cd       $S
C
C --- Input.
C
touch  regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  cp ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  cp ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
C --- get executable
C
cp ~/HYCOM-tools/force/src/off_zero . &
C
wait
chmod a+rx off_zero
C
touch      fort.10
/bin/rm -f fort.1[01234]*
C
setenv FOR010  fort.10
setenv FOR011  fort.11
setenv FOR010A fort.10A
setenv FOR011A fort.11A
C
./off_zero
C
/bin/mv fort.10  tauewd_zero.b
/bin/mv fort.10A tauewd_zero.a
/bin/mv fort.11  taunwd_zero.b
/bin/mv fort.11A taunwd_zero.a
C
C
C --- Delete all files.
C
/bin/rm -f regional* ./off_zero
