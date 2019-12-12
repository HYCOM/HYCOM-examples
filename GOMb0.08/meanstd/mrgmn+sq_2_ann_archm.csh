#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:ncpus=48
#PBS -l mppmem=64gb
#PBS -l walltime=0:30:00
#PBS -A NRLSS03755018
#PBS -q debug 
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
  setenv BINRUN      "time aprun -B"
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
if ( ! -e hycom_mnsq ) /bin/cp ${SRC}/meanstd/src/hycom_mnsq .
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
touch   ${E}_mean.IN
/bin/rm ${E}_mean.IN
touch   ${E}_mean.IN
echo " ${K}	'kk    ' = number of layers involved (usually 1)"   >> ${E}_mean.IN
echo "  0	'meansq' = form meansq, rather than mean (0=F,1=T)" >> ${E}_mean.IN
#
foreach y ( ${YY} )
  setenv YF $y

  foreach P (a b c d e f g h i j k l)
    if (! -e ${SM}/${E}_archMNA.${y}${P}.b) then
      pget   ${D}/${E}_archMNA.${y}${P}.b ${SM} &
      pget   ${D}/${E}_archMNA.${y}${P}.a ${SM} &
    endif
  end
  wait

  foreach P (a b c d e f g h i j k l)
    echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
    echo                                  "${SM}/${E}_archMNA.${y}${P}.b" >> ${E}_mean.IN
  end
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
echo                                           "${SM}/${E}_archMNA.${YF}" >> ${E}_mean.IN
#
touch   ${SM}/${E}_archMNA.${YF}.a ${SM}/${E}_archMNA.${YF}.b
/bin/rm -f ${SM}/${E}_archMNA.${YF}.a ${SM}/${E}_archMNA.${YF}.b
/bin/cp ${E}_mean.IN blkdat.input
/bin/cat blkdat.input

${BINRUN} ./hycom_mnsq

if ( -e "${E}_archMNA.${YY}.b" ) then
  /bin/mv ${E}_archMNA.${YY}.[ab] ${SM}
else
  echo "ERROR : Unable to create ${E}_archMNA.${YY}.a"
endif
#
/bin/rm blkdat.input ${E}_mean.IN
#
# --- squares
#
touch   ${E}_mnsq.IN
/bin/rm ${E}_mnsq.IN
touch   ${E}_mnsq.IN
echo " ${K}	'kk    ' = number of layers involved (usually 1)"   >> ${E}_mnsq.IN
echo "  1	'meansq' = form meansq, rather than mean (0=F,1=T)" >> ${E}_mnsq.IN
#
foreach y ( ${YY} )
  setenv YF $y

  foreach P (a b c d e f g h i j k l)
    if (! -e ${SM}/${E}_archSQA.${y}${P}.b) then
      pget    ${D}/${E}_archSQA.${y}${P}.b ${SM} &
      pget    ${D}/${E}_archSQA.${y}${P}.a ${SM} &
    endif
  end
  wait

  foreach P (a b c d e f g h i j k l)
    echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
    echo                                  "${SM}/${E}_archSQA.${y}${P}.b" >> ${E}_mnsq.IN
  end
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
echo                                           "${SM}/${E}_archSQA.${YF}" >> ${E}_mnsq.IN
#
touch   ${SM}/${E}_archSQA.${YF}.a ${SM}/${E}_archSQA.${YF}.b
/bin/rm -f ${SM}/${E}_archSQA.${YF}.a ${SM}/${E}_archSQA.${YF}.b
/bin/cp ${E}_mnsq.IN blkdat.input
/bin/cat blkdat.input

${BINRUN} ./hycom_mnsq

if ( -e "${E}_archSQA.${YY}.b" ) then
  /bin/mv ${E}_archSQA.${YY}.[ab] ${SM}
else
  echo "ERROR : Unable to create ${E}_archSQA.${YY}.a"
endif
#
/bin/rm blkdat.input ${E}_mnsq.IN ./hycom_mnsq
#
# --- submit transfer job to copy files to newton
#
if (${ARCHIVE} == 1)
  awk -f ${D}/../../meanstd/mn+sq.awk y=${Y} p='' ex=${EX} r=${R} e=${E} x=${X} \
         ${D}/../../meanstd/mn+sq_rcp_A.csh >! mn+sq_rcp_A_${Y}.csh
   ${QSUBMIT}  mn+sq_rcp_A_${Y}.csh
endif
#
# submit std job
#
#cd ~/HYCOM-examples/${R}/meanstd
#${QSUBMIT} ${E}_std.csh
#
wait
