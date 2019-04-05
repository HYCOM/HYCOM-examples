#! /bin/csh -x
#
set echo
set time = 1
C
#
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
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src
#
setenv M  ${D}/../../meanstd
setenv N  ${D}/../

#
# ---  machine related source directory
setenv SRCBIN ~/HYCOM-tools/bin
setenv SRC ~/HYCOM-tools/MPI
setenv BINRUN ""

switch ($OS)
case 'XT40':
case 'XT30':
  setenv SRCBIN ~/HYCOM-tools/ALT/bin
  setenv SRC ~/HYCOM-tools/MPI
  setenv BINRUN "time aprun -B"
  breaksw
case 'HPE':
  setenv SRCBIN ~/HYCOM-tools/bin
  setenv SRC ~/HYCOM-tools/MPI
  setenv BINRUN "mpiexec_mpt -np 1 "
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
setenv STMP    ${S}/meanstd/a${YY}${P}
setenv SM      ${S}/meanstd/

#
mkdir -p ${STMP}
switch ($OS)
case 'XT40':
case 'XT30':
  lfs setstripe -d ${STMP}
  lfs setstripe    ${STMP} -s 1048576 -i -1 -c 8
  breaksw
endsw
  
cd ${STMP}
#
limit
if ( ! -e hycom_mean ) /bin/cp ${SRC}/meanstd/src/hycom_mean ${STMP}
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
  echo $YRFLAG $ARCHFQ $DF $DL | ${SRCBIN}/hycom_archm_dates | tail -n +3 >! ${E}_mean.tmp
  foreach d ( `cat ${E}_mean.tmp` )
#   touch   ../../tarm_${Y}${P}/${E}_archm.${d}.a
    if (! -e  ../../tarm_${Y}${P}/${E}_archm.${d}.a) then
      echo "../../tarm_${Y}${P}/${E}_archm.${d}.a does not exist - exiting script"
      exit
    else
      ln -sf ../../tarm_${Y}${P}/${E}_archm.${d}.a archm.${d}.a
    endif
#   touch   ../../tarm_${Y}${P}/${E}_archm.${d}.b
    if (! -e  ../../tarm_${Y}${P}/${E}_archm.${d}.b) then
      echo "../../tarm_${Y}${P}/${E}_archm.${d}.b does not exist - exiting script"
      exit
    else
      ln -sf ../../tarm_${Y}${P}/${E}_archm.${d}.b archm.${d}.b
    endif
  end
  wait
#
# --- mean.
#
  setenv NA `cat ${E}_mean.tmp | wc -l`
  echo "  $K	'kk    ' = number of layers involved"                     >! ${E}_mean.IN
  echo "  1	'single' = treat input mean as a single sample (0=F,1=T)" >> ${E}_mean.IN
  echo "  0	'meansq' = form meansq, rather than mean (0=F,1=T)"       >> ${E}_mean.IN
  echo "  $NA	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
  cat ${E}_mean.tmp | awk '{printf("archm.%s.a\n",$1)}'                   >> ${E}_mean.IN
  echo "  0  	'narchs' = number of archives to read (==0 to end input)" >> ${E}_mean.IN
  echo   "${E}_archMNA.${YY}${mon}"                                       >> ${E}_mean.IN
  touch   ${E}_archMNA.${YY}${mon}.a ${E}_archMNA.${YY}${mon}.b
  /bin/rm ${E}_archMNA.${YY}${mon}.a ${E}_archMNA.${YY}${mon}.b
  /bin/cp ${E}_mean.IN blkdat.input
  /bin/cat blkdat.input

  ${BINRUN} ./hycom_mean

  if ( -e "${E}_archMNA.${YY}${mon}.b" ) then
    /bin/mv ${E}_archMNA.${YY}${mon}.[ab] ${SM}
  else
    echo "ERROR : Unable to create ${E}_archMNA.${YY}${mon}.a"
  endif
#
  /bin/rm blkdat.input ${E}_mean.IN
#
# --- mnsq.
#
  setenv NA `cat ${E}_mean.tmp | wc -l`
  echo "  $K    'kk    ' = number of layers involved"                     >! ${E}_mnsq.IN
  echo "  1     'meansq' = form meansq, rather than mean (0=F,1=T)"       >> ${E}_mnsq.IN
  echo "  $NA   'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
  cat ${E}_mean.tmp | awk '{printf("archm.%s.a\n",$1)}'                   >> ${E}_mnsq.IN
  echo "  0     'narchs' = number of archives to read (==0 to end input)" >> ${E}_mnsq.IN
  echo   "${E}_archSQA.${YY}${mon}"                                       >> ${E}_mnsq.IN
  touch   ${E}_archSQA.${YY}${mon}.a ${E}_archSQA.${YY}${mon}.b
  /bin/rm ${E}_archSQA.${YY}${mon}.a ${E}_archSQA.${YY}${mon}.b
  /bin/cp ${E}_mnsq.IN blkdat.input
  /bin/cat blkdat.input

  ${BINRUN} ./hycom_mean

#
  if ( -e "${E}_archSQA.${YY}${mon}.b" ) then
    /bin/mv ${E}_archSQA.${YY}${mon}.[ab] ${SM}
  else
    echo "ERROR : Unable to create ${E}_archSQA.${YY}${mon}.a"
  endif
#
  /bin/rm blkdat.input ${E}_mnsq.IN ${E}_mean.tmp archm.????_???_12.[ab]
#
# --- submit transfer job to copy files to newton
#
  cd ${SM}
  if (${ARCHIVE} == 1) then
     awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X} \
      ${M}/mn+sq_rcp_A.csh >! mn+sq_rcp_A_${Y}${P}.csh
      ${QSUBMIT} mn+sq_rcp_A_${Y}${P}.csh
  endif
end
#
# --- Remove temporary files
#
cd ${SM}
#if ( -d ${STMP} ) /bin/rm -fr          ${STMP}
#
# --- submit the job to combine the means and squares
#
if (${P} == l) then
 awk -f ${M}/mn+sq.awk y=${Y} p=${P} ex=${EX} r=${R} x=${X}  \
 ${M}/mrgmn+sq_2_ann_archm.csh >! ${E}_mrgmn+sq_2_ann_archm.csh
 ${QSUBMIT} ${E}_mrgmn+sq_2_ann_archm.csh
endif
