#! /bin/csh -x
#PBS -N Rnest_GOMb0.08
#PBS -j oe
#PBS -o Rnest_GOMb0.08.log
#PBS -W umask=027 
#PBS -l select=1:ncpus=48
#PBS -l place=scatter:excl
#PBS -l walltime=1:30:00
#PBS -A ONRDC10855122
#PBS -q standard
#
module list
set echo
set time = 1
hostname
date
#
# --- form interpolated subregion daily mean archive files, GLBb0.08 to GOMb0.08.
#
# --- R  is the original region
# --- U  is the target   region
# --- E  is the experiment number
# --- Y  is year
# --- P  is month
# --- S  is the location to run from
# --- D  is the location of the original   archive files
# --- N  is the location of the subregion  archive files
# --- TR is the location of the original  topo    files
# --- TU is the location of the subregion topo    files
# --- VR is the original  depth version (${TR}/depth_${R}_${VR}.[ab])
# --- VU is the subregion depth version (${TU}/depth_${U}_${VU}.[ab])
#
setenv R GLBy0.08 
setenv U GOMb0.08
setenv E 530 
setenv Y 124 
setenv P i

#
setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
setenv X  `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'`
setenv EE ~/HYCOM-examples/${U}/expt_${X}/
#
setenv S  /p/work1/${user}/HYCOM-examples/${U}/datasets/subregion/
setenv TR /p/work1/${user}/HYCOM-examples/${R}/datasets/topo
setenv TU /p/work1/${user}/HYCOM-examples/${U}/datasets/topo
setenv VR 27
setenv VU 27s 
setenv D  /p/work1/${user}/HYCOM-examples/datasets/nest/GLBy0.08/
setenv N  /p/work1/${user}/HYCOM-examples/${U}/datasets/subregion/
#
setenv TOOLS  ~/HYCOM-tools
#setenv BINRUN ""
#Cray XC40
#setenv BINRUN "aprun -n 1"
setenv BINRUN ""
#
mkdir -p $N
#
mkdir -p $S
cd       $S
#
/bin/rm   regional.depth.a regional.depth.b
touch     regional.depth.a regional.depth.b
if (-z    regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/ln -s ${TR}/depth_${R}_${VR}.a regional.depth.a
endif
if (-z    regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/ln -s ${TR}/depth_${R}_${VR}.b regional.depth.b
endif
#
touch     regional.grid.a regional.grid.b
if (-z    regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/ln -s ${TR}/regional.grid.a .
endif
if (-z    regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/ln -s ${TR}/regional.grid.b .
endif
#
# determine start and end days, one day overlap for mean files
#
if (-e ${EE}/${E}y${Y}${P}.limits) then
  setenv NF `sed -e "s/-/ /g" ${EE}/${E}y${Y}${P}.limits | awk '{print $1-1}'`
  setenv NL `cat              ${EE}/${E}y${Y}${P}.limits | awk '{print $2+1}'`
else
  setenv NF `echo "LIMITS" | awk -f ${EE}/${E}.awk y01=${Y} ab=${P} | awk '{print $1-1}'`
  setenv NL `echo "LIMITS" | awk -f ${EE}/${E}.awk y01=${Y} ab=${P} | awk '{print $2+1}'`
endif
echo ${NF} ${NL}
##
echo 3 1.0 $NF $NL | hycom_archm_dates | grep "_12" >! nest_${Y}${P}.tmp
#
foreach ydh ( `paste -d" " -s nest_${Y}${P}.tmp` )
  set julh_date = `echo ${ydh} | hycom_date_wind`
  set y_m_d_h = `echo ${julh_date} | hycom_wind_ymdh`
  set ymdh = `echo $y_m_d_h | tr -d '_'`

  if (-e ${D}/US058GCOM-OPSnce.espc-d-031-hycom_fcst_glby008_${ymdh}_M0000_archm.a && ! -e ${N}/archm.${ydh}.b) then
    
#   no leading expt number for nesting files
    touch   ${N}/archm.${ydh}.b
    /bin/rm ${N}/archm.${ydh}.[ab]
    /usr/bin/time ${BINRUN} ${TOOLS}/subregion/src/isubaregion <<E-o-D
${TU}/regional.grid.a
${TU}/regional.gmapi_${R}.a
${TU}/depth_${U}_${VU}.a
regional.depth.a
${D}/US058GCOM-OPSnce.espc-d-031-hycom_fcst_glby008_${ymdh}_M0000_archm.a
${N}/archm.${ydh}.a
${R} interpolated to ${U}
 263	  'idm   ' = target longitudinal array size
 193	  'jdm   ' = target latitudinal  array size
   0	  'iceflg' = ice in output archive flag (0=none,1=energy loan model)
   0	  'smooth' = smooth interface depths    (0=F,1=T)
E-o-D

    touch  ${N}/archm.${ydh}.b
    if (-z ${N}/archm.${ydh}.b) then
      echo "missing archive file: " ${N}/archm.${ydh}.b
      exit (2)
    endif

    cd ${S}
  date
end

\rm region*
