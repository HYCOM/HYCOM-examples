#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -l walltime=1:00:00
#PBS -l select=1
#PBS -W umask=027
#PBS -A NRLSS03755018
#PBS -q standard
####PBS -l walltime=12:00:00
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
C
C --- A is month.
C --- Y01 is year
C
setenv A " "
setenv Y01 "001"
C
C --- run in the tar directories.
C --- tarc: i.e. daily CICE files.
C
chmod 750 $S/tarc_${Y01}${A}
cd        $S/tarc_${Y01}${A}
#
/bin/rm *days* *.tar*
C
C --- tar into four files
C
/bin/rm -f               days*
ls -1 ${E}*.{nc}      >! days
C
${BINRUN} /bin/tar --format=posix --files-from=days -cvf ${E}_archc_${Y01}${A}.tar >! ${E}_archc_${Y01}${A}.tar.lis &
wait
C
${BINRUN} /app/bin/pigz -p 8 --fast ${E}_archc_${Y01}${A}.tar &
#${BINRUN} /usr/bin/gzip ${E}_archc_${Y01}${A}.tar &
wait
C
cd $S
if ($ARCHIVE == 1) then
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../POST/${E}Ac_rcp.csh >! tarc_${Y01}${A}_rcp.csh
  ${QSUBMIT} tarc_${Y01}${A}_rcp.csh
endif 
