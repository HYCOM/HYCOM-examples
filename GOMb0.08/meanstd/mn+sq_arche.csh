#! /bin/csh -x
#
set echo
set time = 1
# --- form the mean and mean-square of a sequence of archive files
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- K is number of layers (or 1 for a surface mean).
# --- Y is year
# --- P is month
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src
#
setenv M  ${D}/../../meanstd
setenv N  ${D}/../

# ---  machine related source directory
setenv SRCBIN ~/HYCOM-tools/bin
setenv SRC ~/HYCOM-tools/
setenv BINRUN ""

switch ($OS)
case 'Linux':
case 'XT40':
case 'XT30':
  setenv SRCBIN ~/HYCOM-tools/ALT/bin
  setenv SRC ~/HYCOM-tools/MPI
  setenv BINRUN "aprun -n 1" 
  breaksw
case 'HPE':
  setenv SRCBIN ~/HYCOM-tools/bin
  setenv SRC ~/HYCOM-tools/MPI
  setenv BINRUN "mpiexec_mpt -np 1"
  breaksw
endsw

# --- time
setenv Y 003
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
setenv ARCHFQ `grep meanfq ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
setenv P a
setenv STMP    ${S}/meanstd/e${YY}${P}
setenv SM      ${S}/meanstd/

#
cd ${STMP}
limit
if ( ! -e hycom_mnsq ) /bin/cp ${SRC}/meanstd/src/hycom_mnsq ${STMP}
#
touch   regional.depth.a regional.depth.b
if (-z regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/cp ${DS}/topo/depth_${R}_${T}.a regional.depth.a
endif
if (-z regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/cp ${DS}/topo/depth_${R}_${T}.b regional.depth.b
endif
#
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/cp ${DS}/topo/regional.grid.a regional.grid.a
endif
if (-z regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/cp ${DS}/topo/regional.grid.b regional.grid.b
endif
#
# --- individual model years, 1-day 3-d archives.
#
#
foreach mon ( ${P} )
  echo "year - month " ${Y} ${mon}
#
# determine start and end days
#
  setenv DF `echo LIMITS | awk -f ${N}/${E}.awk y01=${Y} ab=${mon} | awk '{print $1}'`
  setenv DL `echo LIMITS | awk -f ${N}/${E}.awk y01=${Y} ab=${mon} | awk '{print $2}'`
#
  echo $YRFLAG $ARCHFQ $DF $DL | ${SRCBIN}/hycom_archv_dates | tail -n +3 >! ${E}_mean.tmp
  foreach d ( `cat ${E}_mean.tmp` )
#   touch   ../../tare_${Y}${P}/${E}_arche.${d}.a
    if (! -e  ../../tare_${Y}${P}/${E}_arche.${d}.a) then
      echo "../../tare_${Y}${P}/${E}_arche.${d}.a does not exist - exiting script"
      exit
    else
      ln -sf ../../tare_${Y}${P}/${E}_arche.${d}.a arche.${d}.a
    endif
#   touch   ../../tare_${Y}${P}/${E}_arche.${d}.b
    if (! -e  ../../tare_${Y}${P}/${E}_arche.${d}.b) then
      echo "../../tare_${Y}${P}/${E}_arche.${d}.b does not exist - exiting script"
      exit
    else
      ln -sf ../../tare_${Y}${P}/${E}_arche.${d}.b arche.${d}.b
    endif
  end
  wait
#
# --- mean.
#
  setenv NA `cat ${E}_mean.tmp | wc -l`
  echo "  21	'nn    ' = number of fields involved"               >! ${E}_mean.IN
  echo "  0	'meansq' = form meansq, rather than mean (0=F,1=T)" >> ${E}_mean.IN
  echo "  $NA	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
  cat ${E}_mean.tmp | awk '{printf("arche.%s.a\n",$1)}' >> ${E}_mean.IN
  echo "  0  	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
  echo   "${E}_archMNE.${YY}${mon}" >> ${E}_mean.IN
  touch   ${E}_archMNE.${YY}${mon}.a ${E}_archMNE.${YY}${mon}.b
  /bin/rm ${E}_archMNE.${YY}${mon}.a ${E}_archMNE.${YY}${mon}.b
  cat ${E}_mean.IN
  date

  ${BINRUN} ${SRC}/meanstd/src/hesmf_mean < ${E}_mean.IN

  if ( -e "${E}_archMNE.${YY}${mon}.b" ) then
    /bin/mv ${E}_archMNE.${YY}${mon}.[ab] ${SM}
  else
    echo "ERROR : Unable to create ${E}_archMNE.${YY}${mon}.a"
  endif
  date
#
# --- mnsq.
#
  sed -e "s/0	'meansq'/1	'meansq'/g" -e "s/archMN/archSQ/g" ${E}_mean.IN >! ${E}_mnsq.IN
  touch   ${E}_archSQE.${YY}${mon}.a ${E}_archSQE.${YY}${mon}.b
  /bin/rm ${E}_archSQE.${YY}${mon}.a ${E}_archSQE.${YY}${mon}.b
  cat ${E}_mnsq.IN
  date

  ${BINRUN} ${SRC}/meanstd/src/hesmf_mean < ${E}_mnsq.IN

  date
  if ( -e "${E}_archSQE.${YY}${mon}.b" ) then
    /bin/mv ${E}_archSQE.${YY}${mon}.[ab] ${SM}
  else
    echo "ERROR : Unable to create ${E}_archSQE.${YY}${mon}.a"
  endif
#
# --- submit transfer job to copy files to newton
#
  cd ${SM}
  if (${ARCHIVE} == 1) then
    awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
     ${M}/mn+sq_rcp_E.csh >! mn+sq_rcp_E_${Y}${P}.csh
     ${QSUBMIT} mn+sq_rcp_E_${Y}${P}.csh
   endif 
end
#
# --- Remove temporary files
#
cd ${SM}
if ( -d ${STMP} ) /bin/rm -fr          ${STMP}
#
# --- submit the job to combine the means and squares
#
if (${P} == l) then
 awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
 ${M}/mrgmn+sq_2_ann_arche.csh >! ${E}_mrgmn+sq_2_ann_arche.csh
 ${QSUBMIT} ${E}_mrgmn+sq_2_ann_arche.csh
endif
