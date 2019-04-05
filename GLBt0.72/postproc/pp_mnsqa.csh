#!/bin/csh -x
#PBS -N pp_mnsqa
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l application=home-grown
#PBS -l select=1:mpiprocs=24
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122 
#PBS -q debug
####PBS -q standard
#
set echo
set time = 1
date
C
#
# - environment variables defining the region and experiment number.
#
setenv X 01.6
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

#
# - time 
#
setenv Y 001
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YZ `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YZ `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
setenv P a
#
# - environment variables defining the working directories
#
setenv SM  ${S}/meanstd/a${YZ}${P}
setenv M   ${D}/../../meanstd
#
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
#
####################################################################
#
# - compute mean and square files
# - HYCOM archm files from a hycom run
#
####################################################################
#
/bin/rm -f                              ${SM}/${E}_mn+sq_${Y}${P}.{csh,log}
awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
       ${M}/mn+sq_archm.csh  >!  ${SM}/${E}_mn+sq_${Y}${P}.csh
csh   ${SM}/${E}_mn+sq_${Y}${P}.csh >&! ${SM}/${E}_mn+sq_${Y}${P}.log
wait
echo "FINISHED Creating Means and Squares"
date
