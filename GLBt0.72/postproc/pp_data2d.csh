#!/bin/csh -x
#PBS -N pp_data2d
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l place=scatter:excl
#PBS -l walltime=4:00:00
#PBS -l application=home-grown
#PBS -A ONRDC10855122 
#PBS -q standard
#
set echo
set verbose
set time = 1
C
# --- environment variables defining the region and experiment number.
#
setenv X 01.6
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

C
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

# --- time and size of the domain
setenv Y 001
setenv IDM `grep idm ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM `grep jdm ${D}/../blkdat.input | awk '{print $1}'`
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
 setenv YY `echo ${Y}  | awk '{printf("%04d", $1+1900)}'`
else
 setenv YY `echo ${Y}  | awk '{printf("%04d", $1)}'`
endif
setenv YX `echo ${YY} | awk '{printf("%04d", $1+1)}'`
setenv P a
#
# --- environment variables defining the working directories
#
setenv M    ${S}/movie
setenv A    ${S}/archive
setenv ATMP ${S}/archive/${YY}${P}
setenv F    ${D}/../../plot/${E}/movie
setenv C    ${D}/../../archive
#
if ( ! -d ${M}   ) mkdir -p ${M}
if ( ! -d ${C}   ) mkdir -p ${C}
if ( ! -d ${A}   ) mkdir -p ${A}
if ( ! -d ${ATMP}) mkdir -p ${ATMP}
#
####################################################################
#
# - save surface fields in HYCOM .a format
#
####################################################################
#
foreach f (${S}/tarm_${Y}${P}/${E}_archm.${YY}_???_12.b)
  unsetenv J
  unsetenv YZ
#                        cut range depends on username
  setenv   J  `ls ${f} | cut -c74-76`
  setenv   YZ `ls ${f} | cut -c69-72`
#
  /bin/rm -f ${E}_data2d_${YZ}${P}.{csh,log}
  awk -f ${C}/data2d.awk y=${YZ} p=${P} ex=${EX} r=${R} e=${E} x=${X} t=${T} j=${J} \
         ${C}/data2d_archm.csh  >!  ${ATMP}/${E}_data2d_${YZ}${P}.csh
  csh ${ATMP}/${E}_data2d_${YZ}${P}.csh >&! ${ATMP}/${E}_data2d_${YZ}${P}.log
end
#
####################################################################
#
# - plot ssh and sst with ice masks for the global and antarctic domains
#   NO .b files are created for the masks.
#
####################################################################
#
#cd ${ATMP}
#/bin/rm -f regional.* src
#ln -sf ${DS}/topo/depth_${R}_${T}.a  regional.depth.a
#ln -sf ${DS}/topo/depth_${R}_${T}.b  regional.depth.b
#ln -sf ${DS}/topo/regional.grid.a    regional.grid.a
#ln -sf ${DS}/topo/regional.grid.b    regional.grid.b
#ln -sf ${DS}/topo/regional.mask.a    regional.mask.a
#ln -sf /usr/local/u/wallcraf/hycom/ALL/plot/src_2.1.00 src
##
#foreach f (${ATMP}/${E}_archm.${YY}_???_12_ice.b ${ATMP}/${E}_archm.${YX}_???_12_ice.b)
#  set NM = `basename ${f} | cut -c16-18`
#  set YZ = `basename ${f} | cut -c11-14`
#
#  setenv yy "`cut -c 20-40 ${ATMP}/${E}_archm.${YZ}_${NM}_12_ice.b`"
#  echo SSH ${yy} >! file1
#  echo SST ${yy} >! file2
#  if ( -e ${ATMP}/${E}_archm.${YZ}_${NM}_12_icm.a  ) /bin/rm ${ATMP}/${E}_archm.${YZ}_${NM}_12_icm.a
#  if ( -e ${ATMP}/${E}_archm.${YZ}_${NM}_12_sshM.a ) /bin/rm ${ATMP}/${E}_archm.${YZ}_${NM}_12_sshM.a
#  if ( -e ${ATMP}/${E}_archm.${YZ}_${NM}_12_sstM.a ) /bin/rm ${ATMP}/${E}_archm.${YZ}_${NM}_12_sstM.a
#  hycom_bandmask_inv ${ATMP}/${E}_archm.${YZ}_${NM}_12_ice.a \
#   ${IDM} ${JDM} 0.0 0.0 ${ATMP}/${E}_archm.${YZ}_${NM}_12_icm.a 
#  hycom_mask         ${ATMP}/${E}_archm.${YZ}_${NM}_12_ssh.a \
#                     ${ATMP}/${E}_archm.${YZ}_${NM}_12_icm.a \
#   ${IDM} ${JDM}         ${ATMP}/${E}_archm.${YZ}_${NM}_12_sshM.a
#  ls                 ${ATMP}/${E}_archm.${YZ}_${NM}_12_sshM.a >! file0
##
#  cat file0 ${F}/ssh-ice_cell_globe1.csh file1 ${F}/ssh-ice_cell_globe2.csh >! PLT01.csh
#  cat file0 ${F}/ssh-ice_cell_antar1.csh file1 ${F}/ssh-ice_cell_antar2.csh >! PLT02.csh
#  env NCARG_GKS_PS=${M}/${E}_ssh-ice_global_${YZ}_${NM}.ps ./src/fieldcell < PLT01.csh >! PLT01.log
#  env NCARG_GKS_PS=${M}/${E}_ssh-ice_antarc_${YZ}_${NM}.ps TRACKS=${F}/lonlat_antarctic.txt ./src/fieldcell < PLT02.csh >! PLT02.log
#
#  hycom_mask         ${ATMP}/${E}_archm.${YZ}_${NM}_12_sst.a \
#                     ${ATMP}/${E}_archm.${YZ}_${NM}_12_icm.a \
#   ${IDM} ${JDM}         ${ATMP}/${E}_archm.${YZ}_${NM}_12_sstM.a
#  ls                 ${ATMP}/${E}_archm.${YZ}_${NM}_12_sstM.a >! file0
##
#  cat file0 ${F}/sst-ice_cell_globe1.csh file2 ${F}/sst-ice_cell_globe2.csh >! PLT03.csh
#  cat file0 ${F}/sst-ice_cell_antar1.csh file2 ${F}/sst-ice_cell_antar2.csh >! PLT04.csh
#  env NCARG_GKS_PS=${M}/${E}_sst-ice_global_${YZ}_${NM}.ps ./src/fieldcell < PLT03.csh >! PLT03.log
#  env NCARG_GKS_PS=${M}/${E}_sst-ice_antarc_${YZ}_${NM}.ps TRACKS=${F}/lonlat_antarctic.txt ./src/fieldcell < PLT04.csh >! PLT04.log
#  /bin/rm PLT??.csh
#end
#/bin/rm -f file? PLT??.log
#
# -  Tar the types of files up 
#
cd ${ATMP}
foreach f (ssh sst uv1 vv1)
  ${BINRUN} /bin/tar cvf    ${A}/${E}_archm.${YY}${P}_${f}.tar ${E}_archm.*${f}.[ab]
end
foreach f (ssh sst uv1 vv1)
  ${BINRUN} /usr/bin/gzip ${A}/${E}_archm.${YY}${P}_${f}.tar
if (${ARCHIVE} == 1) then
  /usr/bin/rcp  ${A}/${E}_archm.${YY}${P}_${f}.tar.gz newton:/u/home/${user}/HYCOM-examples/${R}/expt_${X}/data/data2d &
endif
end
foreach f (ssh sst uv1 vv1)
  ${BINRUN} /bin/rm -f ${ATMP}/${E}_archm.*_???_12_${f}.[ab]
end
#
####################################################################
#
# - sample INSTANT, TAO, PIRATA PhilEx and Indian Ocean moorings
# - sample PCM-1, INSTANT, TAO, PIRATA PhilEx and Indian Ocean moorings
#
####################################################################
#
cd ${ATMP}
ln -sf ${DS}/topo/depth_${R}_${T}.a  regional.depth.a
ln -sf ${DS}/topo/depth_${R}_${T}.b  regional.depth.b
ln -sf ${DS}/topo/regional.grid.a    regional.grid.a
ln -sf ${DS}/topo/regional.grid.b    regional.grid.b
foreach f (${S}/tarm_${Y}${P}/${E}_archm.${YY}_???_12.a \
           ${S}/tarm_${Y}${P}/${E}_archm.${YX}_???_12.a)
#                      cut range depends on username
  setenv ff `echo $f | cut -c59-79`
  ${BINRUN} hycom_profile_list $f 127 $HOME/HYCOM-examples/${R}/mooring_all.txt ${ff}_NAME
end
#
foreach f (PCM-1 INSTANT PIRATA TAO INDIAN PhilEx)
  ${BINRUN} /bin/tar cvf ${A}/${E}_archm.${YY}${P}_${f}_moorings.tar ${E}*${f}*txt
if (${ARCHIVE} == 1) then
  /usr/bin/rcp ${A}/${E}_archm.${YY}${P}_${f}_moorings.tar newton:/u/home/${user}/HYCOM-examples/${R}/expt_${X}/data/profiles &
endif
  /bin/rm -f ${ATMP}/${E}*${f}*txt
end
#
####################################################################
#
# - remove archive files
#
####################################################################
#
cd ${S}
if ( -d ${ATMP} ) /bin/rm -fr ${ATMP}
wait
