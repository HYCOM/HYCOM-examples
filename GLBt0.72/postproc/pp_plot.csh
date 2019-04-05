#!/bin/csh -x
#PBS -N pp_plot
#PBS -j oe
#PBS -o XXX.log
#PBS -W umask=027
#PBS -l select=1:ncpus=24
#PBS -l walltime=5:00:00
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

# - machine related source directory
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
# - environment variables defining the working directories
#
setenv M   ${S}/movie
setenv TMP ${S}/plot/${YY}${P}
setenv F   ${D}/../../plot/${E}/movie
#
if ( ! -d ${S}   ) mkdir -p ${S}
if ( ! -d ${M}   ) mkdir -p ${M}
if ( ! -d ${TMP} ) mkdir -p ${TMP}
#
###########################################################
#
# - create animation files
#
###########################################################
#
cd ${TMP}
/bin/rm -f regional.* src
ln -sf ${DS}/topo/depth_${R}_${T}.a  regional.depth.a
ln -sf ${DS}/topo/depth_${R}_${T}.b  regional.depth.b
ln -sf ${DS}/topo/regional.grid.a    regional.grid.a
ln -sf ${DS}/topo/regional.grid.b    regional.grid.b
ln -sf ${DS}/topo/regional.mask.a    regional.mask.a
ln -sf ${SRC}/plot/src src
ln -sf ${F}/lonlat_arctic.txt .
ln -sf ${F}/lonlat_antarc.txt .
#
/bin/rm -f LIST FILE
/bin/touch LIST
#
foreach f (${S}/tarm_${Y}${P}/${E}_archm.${YY}_???_12.b ${S}/tarm_${Y}${P}/${E}_archm.${YX}_???_12.b)
  ls ${f} >> LIST
end
set TOTAL = `wc -l LIST | awk '{printf("%d", $1)}'`
@ NUM = 1
#
while (${NUM} <= ${TOTAL})
  head -${NUM} LIST | tail -1 >! FILE
#                      cut range depends on username
  set NM = `cat FILE | cut -c74-76`
  set YZ = `cat FILE | cut -c69-72`
#
  cat FILE ${F}/plot_ssh_indian.IN >! PLT01.IN
  cat FILE ${F}/plot_ssh_medsea.IN >! PLT02.IN
  cat FILE ${F}/plot_ssh_glfmex.IN >! PLT03.IN
  cat FILE ${F}/plot_ssh_kurosh.IN >! PLT04.IN
  cat FILE ${F}/plot_ssh_agulha.IN >! PLT05.IN
  cat FILE ${F}/plot_ssh_arabia.IN >! PLT06.IN
  cat FILE ${F}/plot_ssh_taiwan.IN >! PLT07.IN
  cat FILE ${F}/plot_ssh_glfstr.IN >! PLT08.IN
  cat FILE ${F}/plot_ssh_nbrazl.IN >! PLT09.IN
  cat FILE ${F}/plot_ssh_intram.IN >! PLT10.IN
  cat FILE ${F}/plot_ssh_malvin.IN >! PLT11.IN
  cat FILE ${F}/plot_ssh_echina.IN >! PLT12.IN
  cat FILE ${F}/plot_ssh_persia.IN >! PLT13.IN
  cat FILE ${F}/plot_ssh_indons.IN >! PLT14.IN
  cat FILE ${F}/plot_ssh_natspg.IN >! PLT15.IN
# cat FILE ${F}/plot_sec_makasr.IN >! PLT16.IN
# cat FILE ${F}/plot_sec_lombok.IN >! PLT17.IN
# cat FILE ${F}/plot_sec_ombais.IN >! PLT18.IN
# cat FILE ${F}/plot_sec_timors.IN >! PLT19.IN
# cat FILE ${F}/plot_sec_lifama.IN >! PLT20.IN
  cat FILE ${F}/plot_ssh_weqpac.IN >! PLT21.IN
# cat FILE ${F}/plot_ssh_makass.IN >! PLT22.IN
# cat FILE ${F}/plot_ssh_karima.IN >! PLT23.IN
# cat FILE ${F}/plot_sec_framst.IN >! PLT24.IN
#
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_indian_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT01.IN >! ${TMP}/PLT01.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_medsea_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT02.IN >! ${TMP}/PLT02.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_glfmex_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT03.IN >! ${TMP}/PLT03.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_kurosh_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT04.IN >! ${TMP}/PLT04.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_agulha_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT05.IN >! ${TMP}/PLT05.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_arabia_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT06.IN >! ${TMP}/PLT06.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_taiwan_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT07.IN >! ${TMP}/PLT07.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_glfstr_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT08.IN >! ${TMP}/PLT08.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_nbrazl_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT09.IN >! ${TMP}/PLT09.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_intram_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT10.IN >! ${TMP}/PLT10.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_malvin_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT11.IN >! ${TMP}/PLT11.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_echina_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT12.IN >! ${TMP}/PLT12.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_persia_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT13.IN >! ${TMP}/PLT13.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_indons_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT14.IN >! ${TMP}/PLT14.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_natspg_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT15.IN >! ${TMP}/PLT15.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_makasr_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT16.IN >! ${TMP}/PLT16.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_lombok_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT17.IN >! ${TMP}/PLT17.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_ombais_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT18.IN >! ${TMP}/PLT18.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_timors_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT19.IN >! ${TMP}/PLT19.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_lifama_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT20.IN >! ${TMP}/PLT20.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_weqpac_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT21.IN >! ${TMP}/PLT21.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_makass_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT22.IN >! ${TMP}/PLT22.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ssh_karima_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT23.IN >! ${TMP}/PLT23.log &
# ${BINRUN} env NCARG_GKS_PS=${M}/${E}_sec_framst_${YZ}_${NM}.ps ${SRC}/plot/src/hycomproc < PLT24.IN >! ${TMP}/PLT24.log &
#
  wait
  /bin/rm PLT??.IN
  @ NUM ++
end
/bin/rm -f LIST FILE ${TMP}/PLT??.log
wait
#
/bin/touch LIST++ LIST-- FILE++ FILE--
#
foreach f (${S}/tare_${Y}${P}/${E}_arche.????_???_00.a)
#
# extract and bandmask ice concentration and thickness
#
  /bin/rm -f ${f:gr}.a+ ${f:gr}.a++ ${f:gr}.a- ${f:gr}.a--
  ${BINRUN} ${SRC}/bin/hycom_extract  ${f:gr}.a   ${IDM} ${JDM} 1  8 1 1 ${f:gr}.a+
  ${BINRUN} ${SRC}/bin/hycom_extract  ${f:gr}.a   ${IDM} ${JDM} 1 16 1 1 ${f:gr}.a++
  ${BINRUN} ${SRC}/bin/hycom_bandmask ${f:gr}.a+  ${IDM} ${JDM} 0.0 1.e-15 ${f:gr}.a- 
  ${BINRUN} ${SRC}/bin/hycom_bandmask ${f:gr}.a++ ${IDM} ${JDM} 0.0 1.e-15 ${f:gr}.a--
  ls ${f}++ >> LIST++
  ls ${f}-- >> LIST--
end
set TOTAL = `wc -l LIST++ | awk '{printf("%d", $1)}'`
@ NUM = 1
#
while (${NUM} <= ${TOTAL})
  head -${NUM} LIST++ | tail -1 >! FILE++
  head -${NUM} LIST-- | tail -1 >! FILE--
#                        cut range depends on username
  set NM = `cat FILE++ | cut -c74-76`
  set YZ = `cat FILE++ | cut -c69-72`
  echo ${R}-${X} Ice Concentration: ${YZ} ${NM} >! file1
  echo ${R}-${X} Ice Thickness: ${YZ} ${NM}     >! file2
#
  cat FILE++ ${F}/ice_cell_arctic1.csh file1 ${F}/ice_cell_arctic2.csh >! PLT01.IN
  cat FILE-- ${F}/ict_cell_arctic1.csh file2 ${F}/ict_cell_arctic2.csh >! PLT02.IN
  cat FILE++ ${F}/ice_cell_antarc1.csh file1 ${F}/ice_cell_antarc2.csh >! PLT03.IN
  cat FILE-- ${F}/ict_cell_antarc1.csh file2 ${F}/ict_cell_antarc2.csh >! PLT04.IN
#
  if (-e ~/NIC/data/arctic/${YZ}/ascii_${YZ}${NM}.txt) then
    cat ./lonlat_arctic.txt ~/NIC/data/arctic/${YZ}/ascii_${YZ}${NM}.txt >! ./lonlat_arctic.txt+
  else
    /bin/cp ./lonlat_arctic.txt ./lonlat_arctic.txt+
  endif
#
  if (-e ~/NIC/data/antarc/${YZ}/ascii_${YZ}${NM}.txt) then
    cat ./lonlat_antarc.txt ~/NIC/data/antarc/${YZ}/ascii_${YZ}${NM}.txt >! ./lonlat_antarc.txt+
  else
    /bin/cp ./lonlat_antarc.txt ./lonlat_antarc.txt+
  endif
#
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ice_arctic_${YZ}_${NM}.ps TRACKS=./lonlat_arctic.txt+ ${SRC}/plot/src/fieldcell < PLT01.IN >! ${TMP}/PLT01.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ict_arctic_${YZ}_${NM}.ps TRACKS=./lonlat_arctic.txt+ ${SRC}/plot/src/fieldcell < PLT02.IN >! ${TMP}/PLT02.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ice_antarc_${YZ}_${NM}.ps TRACKS=./lonlat_antarc.txt+ ${SRC}/plot/src/fieldcell < PLT03.IN >! ${TMP}/PLT03.log &
  ${BINRUN} env NCARG_GKS_PS=${M}/${E}_ict_antarc_${YZ}_${NM}.ps TRACKS=./lonlat_antarc.txt+ ${SRC}/plot/src/fieldcell < PLT04.IN >! ${TMP}/PLT04.log &
#
  wait
  /bin/rm PLT??.IN
  @ NUM ++
end
/bin/rm -f LIST* FILE* ${TMP}/PLT??.log
/bin/rm ${S}/tare_${Y}${P}/${E}_arche.????_???_00.{a-,a--,a+,a++}
wait
cd ${S}
if ( -d ${TMP} ) /bin/rm -fr ${TMP}
