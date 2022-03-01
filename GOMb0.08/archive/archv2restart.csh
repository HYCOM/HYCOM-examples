#!/bin/csh
#
set echo
C
# --- Form a HYCOM restart file from a HYCOM archive file.
# --- output is HYCOM restart files
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- Y is year
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

#
# --- machine related source directory
setenv SRC  ~/HYCOM-tools
setenv BINRUN ""
switch ($OS)
case 'XC30':
case 'XC40':
C --- XT4, XT5 or XC30
  setenv SRC ~/HYCOM-tools/ALT
  setenv BINRUN "aprun -n 1"
  breaksw
endsw

# --- domain and parameters
setenv Y 001
setenv IDM    `grep idm ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM    `grep jdm ${D}/../blkdat.input | awk '{print $1}'`
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
setenv THBASE `grep thbase ${D}/../blkdat.input | awk '{print $1}'`
setenv BACLIN `grep baclin ${D}/../blkdat.input | awk '{print $1}'`
setenv SSHFLG `grep 'diagnostic SSH' ${D}/../blkdat.input | awk '{print $1}'`

# --- add correction to pbavg to make it consistent with psikk and thkk
if (${SSHFLG} == 2) then
  setenv RMONTG 1
else
  setenv RMONTG 0
endif

#
# --- get depth and grid
#
touch regional.depth.a regional.depth.b
if (-z regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/ln -s ${DS}/topo/depth_${R}_${T}.a regional.depth.a
endif
if (-z regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/ln -s ${DS}/topo/depth_${R}_${T}.b regional.depth.b
endif
#
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/ln -s ${DS}/topo/regional.grid.a .
endif
if (-z regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/ln -s ${DS}/topo/regional.grid.b .
endif

#
# ---  input archive file
# ---  input restart template file
# --- output restart file
#
${BINRUN} ${SRC}/archive/src/archv2restart <<E-o-D
${S}/archv.0021_016_00.a
${S}/restart_021.a
${S}/restart_021_016.a
000        'iexpt ' = experiment number x10 (000=from archive file)
${YRFLAG}  'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
${IDM}     'idm   ' = longitudinal array size
${JDM}     'jdm   ' = latitudinal  array size
${K}       'kdm   ' = number of layers
${THBASE}  'thbase' = reference density (sigma units)
${BACLIN}  'baclin' = baroclinic time step (seconds), int. divisor of 86400
${RMONTG}  'rmontg' = pbavg correction from relax.montg file  (0=F,1=T)
${S}/relax.montg.a
E-o-D
