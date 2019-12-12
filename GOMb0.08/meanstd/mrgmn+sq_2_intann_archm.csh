#!/bin/csh -x
#PBS -N mean
#PBS -j oe
#PBS -o mean_inter.log
#PBS -W umask=027
#PBS -l select=1:ncpus=48
##PBS -l mppmem=64gb
#PBS -l walltime=0:30:00
#PBS -A NRLSS03755018
#PBS -q debug
#
set echo
setenv pget ~wallcraf/bin/pget
setenv pput ~wallcraf/bin/pput
#
# --- combine multiple annual mean files
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- K is number of layers (or 1 for a surface mean).
# --- YF is first year
# --- YL is last  year
#
setenv X 06.2
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src
setenv YF 1994
setenv YL 1998 
setenv SM  ${S}/meanstd
#
cd ${SM}

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
#  setenv BINRUN      "mpiexec_mpt -np 1"
  breaksw
endsw

#
limit
#
if ( ! -e hycom_mnsq ) /bin/cp ~/HYCOM-tools/meanstd/src/hycom_mnsq .
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
@ n = ${YF}
while ($n <= ${YL} )
  setenv YY `echo $n | awk '{printf("%04d",$1)}'`
  if (! -e ${SM}/${E}_archMNA.${YY}.b) then
    pget    ${D}/${E}_archMNA.${YY}.b ${SM} &
    pget    ${D}/${E}_archMNA.${YY}.a ${SM} &
  endif
  wait

  echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
  echo                                       "${SM}/${E}_archMNA.${YY}.b" >> ${E}_mean.IN
#
  @ n = $n + 1
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
echo                                     "${SM}/${E}_archMNA.${YF}_${YL}" >> ${E}_mean.IN
#
touch      ${SM}/${E}_archMNA.${YF}_${YL}.a ${SM}/${E}_archMNA.${YF}_${YL}.b
/bin/rm -f ${SM}/${E}_archMNA.${YF}_${YL}.a ${SM}/${E}_archMNA.${YF}_${YL}.b
/bin/cp ${E}_mean.IN blkdat.input
/bin/cat blkdat.input
${BINRUN} ./hycom_mnsq < ${E}_mean.IN

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
@ n = ${YF}
while ($n <= ${YL} )
  setenv YY `echo $n | awk '{printf("%04d",$1)}'`
  if (! -e ${SM}/${E}_archSQA.${YY}.b) then
    pget    ${D}/${E}_archSQA.${YY}.b ${SM} &
    pget    ${D}/${E}_archSQA.${YY}.a ${SM} &
  endif
  wait
  echo "  1	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
  echo                                       "${SM}/${E}_archSQA.${YY}.b" >> ${E}_mnsq.IN
#
  @ n = $n + 1
end
#
echo "  0	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
echo                                     "${SM}/${E}_archSQA.${YF}_${YL}" >> ${E}_mnsq.IN
#
touch      ${SM}/${E}_archSQA.${YF}_${YL}.a ${SM}/${E}_archSQA.${YF}_${YL}.b
/bin/rm -f ${SM}/${E}_archSQA.${YF}_${YL}.a ${SM}/${E}_archSQA.${YF}_${YL}.b
/bin/cp ${E}_mnsq.IN blkdat.input
/bin/cat blkdat.input
${BINRUN} ./hycom_mnsq < ${E}_mnsq.IN
#
/bin/rm blkdat.input ${E}_mnsq.IN ./hycom_mnsq
#
# std
#
#cd ~/HYCOM-examples/${R}/meanstd
/bin/cp ~/HYCOM-tools/meanstd/src/hycom_std .
#
setenv Y ${YF}_${YL}
#
touch ${SM}/${E}_archMNA.${Y}.a ${SM}/${E}_archMNA.${Y}.b 
touch ${SM}/${E}_archSQA.${Y}.a ${SM}/${E}_archSQA.${Y}.b 
#
touch   blkdat.input
/bin/rm blkdat.input
touch   blkdat.input
echo " ${K}    'kk    ' = number of layers involved (usually 1)"  >> blkdat.input
echo "${SM}/${E}_archMNA.${Y}.b"                                  >> blkdat.input
echo "${SM}/${E}_archSQA.${Y}.b"                                  >> blkdat.input
echo "${SM}/${E}_archSDA.${Y}"                                    >> blkdat.input
#
touch   ${SM}/${E}_archSDA.${Y}.a ${SM}/${E}_archSDA.${Y}.b
/bin/rm ${SM}/${E}_archSDA.${Y}.a ${SM}/${E}_archSDA.${Y}.b
/bin/cat blkdat.input
/bin/cp blkdat.input ${E}_input.IN
${BINRUN} ./hycom_std < ${E}_input.IN

if ( -e "${SM}/${E}_archSDA.${Y}.b" ) then
  echo "Successfully created ${E}_archSDA.${Y}.a"
else
  echo "ERROR : Unable to create ${E}_archSDA.${Y}.a"
endif
#
/bin/rm -f blkdat.input ./hycom_std
#
#rcp ${SM}/${E}_archMNA.${Y}.a newton:HYCOM-examples/${R}/expt_${X}/data/${E}_archMNA.${Y}.a
#rcp ${SM}/${E}_archMNA.${Y}.b newton:HYCOM-examples/${R}/expt_${X}/data/${E}_archMNA.${Y}.b
#rcp ${SM}/${E}_archSDA.${Y}.a newton:HYCOM-examples/${R}/expt_${X}/data/${E}_archSDA.${Y}.a
#rcp ${SM}/${E}_archSDA.${Y}.b newton:HYCOM-examples/${R}/expt_${X}/data/${E}_archSDA.${Y}.b
date
