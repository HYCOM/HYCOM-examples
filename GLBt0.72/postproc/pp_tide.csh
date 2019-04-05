#!/bin/csh -x
#PBS -N postproc_tide
#PBS -j oe
#PBS -o postproc_tide.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l walltime=4:00:00
#PBS -l application=home-grown
#PBS -A ONRDC10855122 
#PBS -q standard
#
set echo
set time = 1
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
setenv SM ${S}/NCDF/${YZ}${P}
setenv L  ${D}/../../moorings
#
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
#
####################################################################
#
# - sample tidegauges
#
####################################################################
#
/bin/rm -f ${SM}/${E}_tidegauge_${Y}${P}.{csh,log}
awk -f ${L}/tg.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
       ${L}/tg_XXXyYYYY.csh >! ${SM}/${E}_tidegauge_${Y}${P}.csh
csh ${SM}/${E}_tidegauge_${Y}${P}.csh >&! ${SM}/${E}_tidegauge_${Y}${P}.log &
wait
echo "FINISHED Creating tide gauge"
