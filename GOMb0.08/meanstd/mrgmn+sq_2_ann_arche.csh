#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l place=scatter:excl
#PBS -l mppmem=64gb
#PBS -l walltime=4:00:00
#PBS -A NRLSS03755018
#PBS -q standard
#
set echo
#
# --- form the annual mean of a sequence of monthly mean files
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- K is number of layers (or 1 for a surface mean).
# --- Y is year
# --- P is month
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

setenv SRC      ~/HYCOM-tools
setenv BINRUN    ""
#
switch ($OS)
case 'XC30':
case 'XC40':
# --- XT4, XT5 or XC30
  setenv SRC        ~/HYCOM-tools/MPI
  setenv BINRUN      "aprun -n 1 -m 31g"
  breaksw
case 'HPE':
  setenv SRC        ~/HYCOM-tools/MPI
  setenv BINRUN      "mpiexec_mpt -np 1"
  breaksw
endsw


# --- pget, pput "copy" files between scratch and permanent storage.
# --- Can both be cp if the permanent filesystem is mounted locally.
#
switch ($OS)
case 'SunOS':
case 'Linux':
case 'XT4':
case 'OSF1':
case 'AIX':
case 'unicos':
case 'unicosmk':
    if (-e ~wallcraf/bin/pget) then
      setenv pget ~wallcraf/bin/pget
      setenv pput ~wallcraf/bin/pput
    else
      setenv pget cp
      setenv pput cp
    endif
    breaksw
default:
      setenv pget cp
      setenv pput cp
endsw

#
# - time
#
setenv Y 003
setenv P a
setenv SM ${S}/meanstd
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
setenv ARCHFQ `grep meanfq ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
#
cd ${SM}
#
limit
#
touch   regional.depth.a regional.depth.b
if (-z regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/cp ${DS}/topo/depth_${R}_${T}.a regional.depth.a
endif
if (-z regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/cp ${DS}/topo/depth_${R}_${T}.b regional.depth.b
endif
#
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/cp ${DS}/topo/regional.grid.a regional.grid.a
endif
if (-z regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/cp ${DS}/topo/regional.grid.b regional.grid.b
endif
#
# --- means
#
touch   ${E}_meane.IN
/bin/rm ${E}_meane.IN
touch   ${E}_meane.IN
echo " 21	'nn    ' = number of fields involved"               >> ${E}_meane.IN
echo "  0	'meansq' = form meansq, rather than mean (0=F,1=T)" >> ${E}_meane.IN
#
foreach y ( $YY )
  setenv YF $y

  foreach P (a b c d e f g h i j k l)
    if (! -e     ${E}_archMNE.${y}${P}.b) then
      pget ${SM}/${E}_archMNE.${y}${P}.b . &
      pget ${SM}/${E}_archMNE.${y}${P}.a . &
    endif
  end
  wait

  foreach P (a b c d e f g h i j k l)
    echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_meane.IN
    echo                                  "${SM}/${E}_archMNE.${y}${P}.b" >> ${E}_meane.IN
  end
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_meane.IN
echo                                           "${SM}/${E}_archMNE.${YF}" >> ${E}_meane.IN
#
cat ${E}_meane.IN
#
touch   ${SM}/${E}_archMNE.${YF}.a ${SM}/${E}_archMNE.${YF}.b
/bin/rm ${SM}/${E}_archMNE.${YF}.a ${SM}/${E}_archMNE.${YF}.b
date

  ${BINRUN} ${SRC}/meanstd/src/hesmf_mean < ${E}_meane.IN

date
/bin/rm ${E}_meane.IN
#
# --- mean squares
#
touch   ${E}_mnsqe.IN
/bin/rm ${E}_mnsqe.IN
touch   ${E}_mnsqe.IN
echo " 21	'nn    ' = number of fields involved"               >> ${E}_mnsqe.IN
echo "  1	'meansq' = form meansq, rather than mean (0=F,1=T)" >> ${E}_mnsqe.IN
#
foreach y ( $YY )
  setenv YF $y

  foreach P (a b c d e f g h i j k l)
    if (! -e     ${E}_archSQE.${y}${P}.b) then
      pget ${SM}/${E}_archSQE.${y}${P}.b . &
      pget ${SM}/${E}_archSQE.${y}${P}.a . &
    endif
  end
  wait

  foreach P (a b c d e f g h i j k l)
    echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsqe.IN
    echo                                  "${SM}/${E}_archSQE.${y}${P}.b" >> ${E}_mnsqe.IN
  end
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsqe.IN
echo                                           "${SM}/${E}_archSQE.${YF}" >> ${E}_mnsqe.IN
#
cat ${E}_mnsqe.IN
#
touch   ${SM}/${E}_archSQE.${YF}.a ${SM}/${E}_archSQE.${YF}.b
/bin/rm ${SM}/${E}_archSQE.${YF}.a ${SM}/${E}_archSQE.${YF}.b
date

  ${BINRUN} ${SRC}/meanstd/src/hesmf_mean < ${E}_mnsqe.IN

date
/bin/rm ${E}_mnsqe.IN
#
# --- submit transfer job to copy files to newton
#
if (${ARCHIVE} == 1) then
  awk -f ${D}/../../meanstd/mn+sq.awk y=${Y} p='' ex=${EX} r=${R} e=${E} x=${X} \
         ${D}/../../meanstd/mn+sq_rcp_E.csh >! mn+sq_rcp_E_${Y}.csh
        ${QSUBMIT} mn+sq_rcp_E_${Y}.csh
endif
#
# submit std job
#
#cd ~/HYCOM-examples/${R}/meanstd
#${QSUBMIT} ${E}_stde.csh
#
wait
