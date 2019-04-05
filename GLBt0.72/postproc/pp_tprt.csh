#!/bin/csh -x
#PBS -N pp_tspt
#PBS -j oe
#PBS -o XXX.log
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
setenv Y 001
setenv P a
#
# - environment variables defining the working directories
#
setenv SM  ${S}/sample
setenv L   ${D}/../../sample
#
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
#
####################################################################
#
# - sample transports
#
####################################################################
#
/bin/rm -f ${SM}/${E}_trans2_${Y}${P}.{csh,log}
awk -f ${L}/trans.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
     ${L}/trans2_archm.csh >!  ${SM}/${E}_trans2_${Y}${P}.csh
csh ${SM}/${E}_trans2_${Y}${P}.csh >&! ${SM}/${E}_trans2_${Y}${P}.log
wait
echo "FINISHED Creating Sample Transport"
