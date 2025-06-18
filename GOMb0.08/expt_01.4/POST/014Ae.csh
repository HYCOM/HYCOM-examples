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
####PBS -l select=4
#
set echo
set time = 1
set timestamp
C
C --- tar archive files in a batch job
C
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.4
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C
source ${EX}/EXPT.src
C
 --- BINRUN is application to run executable (if any)
C
setenv BINRUN ""
switch ($OS)
case 'XC30':
case 'XC40':
  setenv BINRUN      "aprun -n 1"
  breaksw
endsw

C --- A is month.
C --- Y01 is year
C
setenv A " "
setenv Y01 "001"
C
C --- run in the tar directories.
C --- tare: i.e. 3 hourly ESMF coupling files.
C
chmod 750 $S/tare_${Y01}${A}
cd        $S/tare_${Y01}${A}
#
/bin/rm *days* *.tar*
C
C --- tar into four files
C
/bin/rm -f               days*
ls -1 ${E}*.{a,b,txt} >! days
head -375 days         >! days1
comm -3   days   days1 >! days1x
head -375 days1x       >! days2
comm -3   days1x days2 >! days2x
head -375 days2x       >! days3
comm -3   days2x days3 >! days4
C
${BINRUN} /bin/tar --format=posix --files-from=days1 -cvf ${E}_arche_${Y01}${A}1.tar >! ${E}_arche_${Y01}${A}1.tar.lis &
${BINRUN} /bin/tar --format=posix --files-from=days2 -cvf ${E}_arche_${Y01}${A}2.tar >! ${E}_arche_${Y01}${A}2.tar.lis &
${BINRUN} /bin/tar --format=posix --files-from=days3 -cvf ${E}_arche_${Y01}${A}3.tar >! ${E}_arche_${Y01}${A}3.tar.lis &
${BINRUN} /bin/tar --format=posix --files-from=days4 -cvf ${E}_arche_${Y01}${A}4.tar >! ${E}_arche_${Y01}${A}4.tar.lis &
wait
C
${BINRUN} /app/bin/pigz -p 8 --fast ${E}_arche_${Y01}${A}1.tar &
${BINRUN} /app/bin/pigz -p 8 --fast ${E}_arche_${Y01}${A}2.tar &
${BINRUN} /app/bin/pigz -p 8 --fast ${E}_arche_${Y01}${A}3.tar &
${BINRUN} /app/bin/pigz -p 8 --fast ${E}_arche_${Y01}${A}4.tar &
#${BINRUN} /usr/bin/gzip ${E}_arche_${Y01}${A}1.tar &
#${BINRUN} /usr/bin/gzip ${E}_arche_${Y01}${A}2.tar &
#${BINRUN} /usr/bin/gzip ${E}_arche_${Y01}${A}3.tar &
#${BINRUN} /usr/bin/gzip ${E}_arche_${Y01}${A}4.tar &
wait
C
cd $S
if ($ARCHIVE == 1) then
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../POST/${E}Ae_rcp.csh >! tare_${Y01}${A}_rcp.csh
  ${QSUBMIT} tare_${Y01}${A}_rcp.csh 
endif
