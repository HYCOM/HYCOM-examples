#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -l walltime=12:00:00
#PBS -l select=1
#PBS -A NRLSS03755018
#PBS -q transfer
#
set echo
set time = 1
set timestamp
C
C --- tar archive files in a batch job
C
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.0
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
setenv DN /u/home/${user}/${P}/
C
C --- run in the tar directories.
C --- tarc: i.e. daily CICE files.
C
cd $S/tarc_${Y01}${A}
C
${BINRUN} /usr/bin/rcp ${E}_archc_${Y01}${A}.tar.gz newton:${DN} &
wait
