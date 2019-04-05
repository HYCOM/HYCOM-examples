#! /bin/csh -x
#
set echo
set time = 1
C
#
# --- calculate region-wide statistics from HYCOM archm files
# --- invoke this via ../postproc/pp_statm.csh
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- Y is year
# --- P is month
#
setenv X 01.6
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

# --- domain and time
setenv Y 003
setenv IDM    `grep idm ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM    `grep jdm ${D}/../blkdat.input | awk '{print $1}'`
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
setenv ARCHFQ `grep meanfq ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%04d", $1+1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%04d", $1)}'`
endif
setenv P a

# --- input and output directory
setenv SM ${S}/tarm_${Y}${P}
setenv DM ${S}/OUTPUT_${Y}${P}

setenv M  ${D}/../../archive
setenv N  ${D}/..

# --- machine related source directory 
setenv SRC  ~/HYCOM-tools/archive/src
setenv SRCBIN ~/HYCOM-tools/bin
setenv BINRUN ""
switch ($OS)
case 'XC30':
case 'XC40':
C --- XT4, XT5 or XC30
  setenv SRCBIN ~/HYCOM-tools/ALT/bin
  breaksw
endsw

#
mkdir -p ${SM}
switch ($OS)
case 'XC30':
case 'XC40':
C --- XT4, XT5 or XC30
lfs setstripe -d ${SM}
lfs setstripe    ${SM} -s 1048576 -i -1 -c 8
  breaksw
endsw
cd ${SM}
#
limit
if ( ! -e stats_archv ) /bin/cp ${SRC}/stats_archv ${SM}
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
  setenv YMD `echo ${DF} 3     | ${SRCBIN}/hycom_wind_ymdh   | sed -e "s/_//g" | cut -c 1-8`
#
  echo $YRFLAG $ARCHFQ $DF $DL | ${SRCBIN}/hycom_archm_dates | tail -n +3 >! ${E}_mean.tmp
  foreach ydh ( `cat ${E}_mean.tmp` )
    date
    /bin/rm -f ${E}_archm.${ydh}.stat
${BINRUN} ${SRC}/stats_archv <<E-o-D
${E}_archm.${ydh}.a
${E}      'iexpt ' = experiment number
${YRFLAG} 'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
 ${IDM}   'idm   ' = longitudinal array size
 ${JDM}   'jdm   ' = latitudinal  array size
 ${K}     'kdm   ' = number of layers
  2       'thflag' = reference pressure flag (0=Sigma-0, 2=Sigma-2)
 34.0     'thbase' = reference density (sigma units)
E-o-D
  end
end
date
