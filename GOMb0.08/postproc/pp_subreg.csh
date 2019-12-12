#!/bin/csh -x
#PBS -N postproc_subreg
#PBS -j oe
#PBS -o postproc_subreg.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l place=scatter:excl
#PBS -l walltime=12:00:00
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
setenv Y 103
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YZ `expr ${Y} + 1900`
else
  setenv YZ `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
setenv P a
#
# - environment variables defining the working directories
#
setenv S ${S}/u25/${YZ}${P}
setenv L ${D}/../../subregion
#
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
#
####################################################################
#
# - subsample GLBb0.08 to GLBu0.24
#
####################################################################
#
/bin/rm -f ${SM}/${E}_u25_${Y}${P}.{csh,log}
awk -f ${L}/u25.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
       ${L}/u25_XXXyYYYY.csh >! ${SM}/${E}_u25_${Y}${P}.csh
csh ${SM}/${E}_u25_${Y}${P}.csh >&! ${SM}/${E}_u25_${Y}${P}.log &
wait
echo "FINISHED Creating subregion"
