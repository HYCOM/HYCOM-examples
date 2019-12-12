#!/bin/csh -x
#PBS -N XXX
#PBS -j oe
#PBS -o XXX.log
#PBS -l walltime=04:00:00
#PBS -l select=1
#PBS -A NRLSS03755018
#PBS -q transfer
#PBS -W umask=027
#
set echo
set time = 1
#
# --- transfer MNA and SQA files to newton
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src
setenv P a
setenv DM ${S}/meanstd
setenv N /u/home/${user}/HYCOM-examples/${R}/expt_${X}/data
setenv Y 001
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
#
cd ${DM}
/usr/bin/rcp ${E}_archMNA.${YY}${P}.b newton:${N}/${E}_archMNA.${YY}${P}.b &
/usr/bin/rcp ${E}_archMNA.${YY}${P}.a newton:${N}/${E}_archMNA.${YY}${P}.a &
/usr/bin/rcp ${E}_archSQA.${YY}${P}.b newton:${N}/${E}_archSQA.${YY}${P}.b &
/usr/bin/rcp ${E}_archSQA.${YY}${P}.a newton:${N}/${E}_archSQA.${YY}${P}.a &
#
wait
