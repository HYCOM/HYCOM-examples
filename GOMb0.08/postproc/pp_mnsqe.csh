#!/bin/csh -x
#PBS -N pp_mnsqe
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:mpiprocs=24
#PBS -l walltime=0:15:00
#PBS -l application=home-grown
#PBS -A NRLSS03755018 
#PBS -q standard
#
set echo
set time = 1
C
#
# - environment variables defining the region and experiment number.
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/hycom/${R}/expt_${X}
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
setenv SM  ${S}/meanstd/e${YZ}${P}
setenv M   ${D}/../../meanstd
#
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
#
####################################################################
#
# - compute mean and square files
#
####################################################################
#
/bin/rm -f ${SM}/${E}_mn+sqe_${Y}${P}.{csh,log}
awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
       ${M}/mn+sq_arche.csh >!  ${SM}/${E}_mn+sqe_${Y}${P}.csh
csh ${SM}/${E}_mn+sqe_${Y}${P}.csh >&! ${SM}/${E}_mn+sqe_${Y}${P}.log
wait
echo "FINISHED Creating Means and Squares"
