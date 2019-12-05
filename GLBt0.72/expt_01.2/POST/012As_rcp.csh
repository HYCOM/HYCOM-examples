#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -l walltime=12:00:00
#PBS -l select=1
#PBS -A ONRDC10855122
#PBS -q transfer
#
set echo
set time = 1
set timestamp
C
C --- tar archive files in a batch job
C
setenv EX /p/home/abozec/HYCOM-examples/GLBt0.72/expt_01.2
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C
source ${EX}/EXPT.src
C
C --- BINRUN is application to run executable (if any)
C
setenv BINRUN ""
switch ($OS)
case 'XC30':
case 'XC40':
  setenv BINRUN      "aprun -n 1"
  breaksw
endsw
C
C --- A is month.
C --- Y01 is year
C
setenv A " "
setenv Y01 "001"
C
C --- run in the tar directories.
C --- tars: i.e. surface HYCOM files.
C
cd $S/tars_${Y01}${A}
C
${BINRUN} /usr/bin/rcp ${E}_archs_${Y01}${A}1.tar.gz newton:${D} &
${BINRUN} /usr/bin/rcp ${E}_archs_${Y01}${A}2.tar.gz newton:${D} &
${BINRUN} /usr/bin/rcp ${E}_archs_${Y01}${A}3.tar.gz newton:${D} &
${BINRUN} /usr/bin/rcp ${E}_archs_${Y01}${A}4.tar.gz newton:${D} &
wait
