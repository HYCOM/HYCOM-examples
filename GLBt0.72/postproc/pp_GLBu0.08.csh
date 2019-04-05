#!/bin/csh -x
#PBS -N pp_GLBu0.08
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l walltime=10:00:00
#PBS -l application=home-grown
#PBS -A ONRDC10855122 
#PBS -q standard
#
set echo
set time = 1
C
C
C - environment variables defining the region and experiment number.
C
setenv X 01.6
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

C - time
setenv Y 001
setenv P a
C
C - environment variables defining the working directories
C
setenv SM  ${S}/GLBu0.08
setenv L   ${D}/../../archive
C
if ( ! -d ${SM}   ) mkdir -p ${SM}
cd ${SM}
C
C --- GLBb0.08 to GLBu0.08
C
/bin/rm -f ${SM}/${E}_GLBb0.08_2_GLBu0.08_${Y}${P}.{csh,log}
awk -f ${L}/GLBb0.08_2_GLBu0.08.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
       ${L}/GLBb0.08_2_GLBu0.08.csh >!  ${SM}/${E}_GLBb0.08_2_GLBu0.08_${Y}${P}.csh
csh    ${SM}/${E}_GLBb0.08_2_GLBu0.08_${Y}${P}.csh >&! ${SM}/${E}_GLBb0.08_2_GLBu0.08_${Y}${P}.log
wait
echo "FINISHED Creating GLBu0.08 files"
C
C --- GLBu0.08 to netCDF
C
/bin/rm -f ${SM}/${E}_GLBu0.08_ncdf3z_${Y}${P}.{csh,log}
awk -f ${L}/GLBb0.08_2_GLBu0.08.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
       ${L}/GLBu0.08_ncdf3z_archm.csh >!  ${SM}/${E}_GLBu0.08_ncdf3z_${Y}${P}.csh
csh    ${SM}/${E}_GLBu0.08_ncdf3z_${Y}${P}.csh >&! ${SM}/${E}_GLBu0.08_ncdf3z_${Y}${P}.log
wait
echo "FINISHED Creating GLBu0.08 netCDF files"
C
C --- submit job to transfer GLBu0.08 netCDF files to newton
C
if (${ARCHIVE} == 1 ) then
/bin/rm -f ${S}/${E}_GLBu0.08_ncdf3z_${Y}${P}_rcp.{csh,log}
   awk -f ${L}/GLBb0.08_2_GLBu0.08.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
          ${L}/GLBu0.08_ncdf3z_rcp.csh >!  ${S}/${E}_GLBu0.08_ncdf3z_${Y}${P}_rcp.csh
   cd     ${S}
   ${QSUBMIT} ${E}_GLBu0.08_ncdf3z_${Y}${P}_rcp.csh
endif
echo "SUBMITTED job to transfer GLBu0.08 netCDF files to newton"
