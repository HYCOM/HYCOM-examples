#!/bin/csh -x
#PBS -N pp_netcdf
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

# --- machine related source directory
setenv SRC  ~/HYCOM-tools
setenv BINRUN ""
switch ($OS)
case 'SunOS':
case 'XC30':
case 'XC40':
C --- XT4, XT5 or XC30
  setenv SRC ~/HYCOM-tools/ALT
  setenv BINRUN "aprun -n 1"
  breaksw
endsw

#
# - time
#
setenv YFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
setenv Y 001
if (${YFLAG} == 3) then
  setenv YZ `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YZ `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
setenv P a
#
# - environment variables defining the working directories
#
#
setenv A    ${S}/archive
setenv ATMP ${S}/archive/ncdf_${YZ}${P}
setenv C    ${D}/../../archive
#
if ( ! -d ${A}   ) mkdir -p ${A}
if ( ! -d ${ATMP}) mkdir -p ${ATMP}
#
####################################################################
#
# - save surface fields in HYCOM .a format
#
####################################################################
#
foreach f (${S}/tarm_${Y}${P}/${E}_archm.${YZ}_???_12.b)
  unsetenv J
  unsetenv YZ
#                        cut range depends on username
#  setenv   J  `ls ${f} | cut -c74-76`
#  setenv   YZ `ls ${f} | cut -c69-72`
   setenv J  `ls ${f} | rev | cut -c6-8 | rev`
   setenv YZ `ls ${f} | rev | cut -c10-13 | rev`
#
  /bin/rm -f ${E}_ncdf2d_${YZ}${P}.{csh,log}
  awk -f ${C}/ncdf.awk y=${YZ} p=${P} ex=${EX} r=${R} x=${X}  j=${J} \
         ${C}/ncdf2d_archm.csh  >!  ${ATMP}/${E}_ncdf2d_${YZ}${P}.csh
  csh ${ATMP}/${E}_ncdf2d_${YZ}${P}.csh >&! ${ATMP}/${E}_ncdf2d_${YZ}${P}.log

  /bin/rm -f ${E}_ncdf3z_${YZ}${P}.{csh,log}
  awk -f ${C}/ncdf.awk y=${YZ} p=${P} ex=${EX} r=${R} x=${X}  j=${J} \
         ${C}/ncdf3z_archm.csh  >!  ${ATMP}/${E}_ncdf3z_${YZ}${P}.csh
  csh ${ATMP}/${E}_ncdf3z_${YZ}${P}.csh >&! ${ATMP}/${E}_ncdf3z_${YZ}${P}.log


end
wait

# - tar files
cd ${ATMP}/
${BINRUN} /bin/tar cvf ${E}_archm.${YZ}${P}_layer2d.tar ${E}_archm.${YZ}*_12_2d*.nc
${BINRUN} /usr/bin/gzip ${E}_archm.${YZ}${P}_layer2d.tar
${BINRUN} /bin/tar cvf ${E}_archm.${YZ}${P}_layer3d.tar ${E}_archm.${YZ}*_12_3d*.nc 
${BINRUN} /usr/bin/gzip ${E}_archm.${YZ}${P}_layer3d.tar
${BINRUN} /bin/tar cvf ${E}_archm.${YZ}${P}_level.tar ${E}_archm.${YZ}*_12_3z*.nc
${BINRUN} /usr/bin/gzip ${E}_archm.${YZ}${P}_level.tar


echo "FINISHED Creating Means and Squares"
date
