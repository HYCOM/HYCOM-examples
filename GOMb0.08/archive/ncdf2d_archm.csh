#!/bin/csh
#
set echo
#
# --- extract 2-d fields from a single HYCOM archive file.
# --- output is HYCOM .a files
#
# --- R is region name.
# --- E is expt number.
# --- X is decimal expt number.
# --- T is topography number.
# --- Y is year
# --- P is month
# --- J is julian day
#
setenv X 01.6
setenv R GOMb0.08
setenv EX ~/HYCOM-examples/${R}/expt_${X}
#setenv EX ~/hycom/${R}/expt_${X}
source ${EX}/EXPT.src

#
# --- machine related source directory
setenv SRC  ~/HYCOM-tools
setenv BINRUN ""
switch ($OS)
case 'XC30':
case 'XC40':
# --- XT4, XT5 or XC30
  setenv SRC ~/HYCOM-tools
  setenv BINRUN "aprun -n 1"
  breaksw
endsw

# --- domain and time
setenv Y 001
setenv IDM    `grep idm    ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM    `grep jdm    ${D}/../blkdat.input | awk '{print $1}'`
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%03d", $1-1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%03d", $1)}'`
endif
setenv P a
setenv J 001
#
if (${YRFLAG} == 3) then
##Alex  if (${J} == 001) setenv YY `echo ${Y} | awk '{printf("%03d", $1-1901)}'`
  if (${J} == 001) setenv YY `echo ${Y} | awk '{printf("%03d", $1-1900)}'`
else
  if (${J} == 001) setenv YY `echo ${Y} | awk '{printf("%03d", $1)}'`
endif

# --- output directory
setenv A    ${S}/archive
setenv ATMP ${S}/archive/ncdf_${Y}${P}

if ( ! -d ${ATMP} ) /bin/mkdir -p ${ATMP}
cd ${ATMP}

# --- get grid and depth
touch   regional.depth.a regional.depth.b
/bin/rm regional.depth.a regional.depth.b
ln -sf ${DS}/topo/depth_${R}_${T}.a regional.depth.a
ln -sf ${DS}/topo/depth_${R}_${T}.b regional.depth.b
#
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
  /bin/rm regional.grid.a
  /bin/ln -s ${DS}/topo/regional.grid.a regional.grid.a
endif
if (-z regional.grid.b) then
  /bin/rm regional.grid.b
  /bin/ln -s ${DS}/topo/regional.grid.b regional.grid.b
endif


# --- output files
setenv CDF020  ${ATMP}/${E}_archm.${Y}_${J}_12_2d.nc
setenv CDF021  ${ATMP}/${E}_archm.${Y}_${J}_12_3d.nc
/bin/rm -f $CDF020  $CDF021

# --- sea ice present?
setenv ICEFLG `grep iceflg ${D}/../blkdat.input | awk '{print $1}'`
if ($ICEFLG == 0 ) then
  setenv IQQ 0
else
  setenv IQQ 20
endif

# --- surface fields

# -- convert to NetCDF
${BINRUN} ${SRC}/archive/src/archv2ncdf2d <<E-o-D
${S}/tarm_${YY}${P}/${E}_archm.${Y}_${J}_12.a
NetCDF
000	'iexpt ' = experiment number x10 (000=from archive file)
  2	'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
${IDM}	'idm   ' = longitudinal array size
${JDM}	'jdm   ' = latitudinal  array size
  ${K}	'kdm   ' = number of layers
 34.0	'thbase' = reference density (sigma units)
  0	'smooth' = smooth fields before plotting (0=F,1=T)
  0	'mthin ' = mask thin layers from plots   (0=F,1=T)
  1	'iorign' = i-origin of plotted subregion
  1	'jorign' = j-origin of plotted subregion
  0	'idmp  ' = i-extent of plotted subregion (<=idm; 0 implies idm)
  0	'jdmp  ' = j-extent of plotted subregion (<=jdm; 0 implies jdm)
  0	'botio ' = bathymetry       I/O unit (0 no I/O)
 20	'flxio ' = surf. heat flux  I/O unit (0 no I/O)
 20	'empio ' = surf. evap-pcip  I/O unit (0 no I/O)
  0	'ttrio ' = surf. temp trend I/O unit (0 no I/O)
  0	'strio ' = surf. saln trend I/O unit (0 no I/O)
${IQQ}	'icvio ' = ice coverage     I/O unit (0 no I/O)
${IQQ}	'ithio ' = ice thickness    I/O unit (0 no I/O)
${IQQ}	'ictio ' = ice temperature  I/O unit (0 no I/O)
 20     'oetaio' = one+eta          I/O unit (0 no I/O)
 20	'montio' = Montgomery Pot.  I/O unit (0 no I/O)
 20	'sshio ' = sea surf. height I/O unit (0 no I/O)
  0     'bkeio ' = baro. k.e.       I/O unit (0 no I/O)
 20	'buvio ' = baro. u-velocity I/O unit (0 no I/O)
 20	'bvvio ' = baro. v-velocity I/O unit (0 no I/O)
  0	'bspio ' = baro. speed      I/O unit (0 no I/O)
  0	'bsfio ' = baro. strmfn.    I/O unit (0 no I/O)
  0	'uvmio ' = mix. lay. u-vel. I/O unit (0 no I/O)
  0	'vvmio ' = mix. lay. v-vel. I/O unit (0 no I/O)
  0	'spmio ' = mix. lay. speed  I/O unit (0 no I/O)
 20	'bltio ' = bnd. lay. thick. I/O unit (0 no I/O)
 20	'mltio ' = mix. lay. thick. I/O unit (0 no I/O)
  0	'sstio ' = mix. lay. temp.  I/O unit (0 no I/O)
  0	'sssio ' = mix. lay. saln.  I/O unit (0 no I/O)
  0	'ssdio ' = mix. lay. dens.  I/O unit (0 no I/O)
  0     'mkeio ' = mix. lay. k.e.   I/O unit (0 no I/O)
 -1	'kf    ' = first output layer (=0 end output; <0 label with layer #)
  ${K}	'kl    ' = last  output layer
 21	'uvlio ' = layer k   u-vel. I/O unit (0 no I/O)
 21	'vvlio ' = layer k   v-vel. I/O unit (0 no I/O)
  0	'splio ' = layer k   speed. I/O unit (0 no I/O)
  0	'infio ' = layer k   i.dep. I/O unit (0 no I/O)
 21	'thkio ' = layer k   thick. I/O unit (0 no I/O)
 21	'temio ' = layer k   temp   I/O unit (0 no I/O)
 21	'salio ' = layer k   saln.  I/O unit (0 no I/O)
  0	'tthio ' = layer k   dens,  I/O unit (0 no I/O)
  0     'keio  ' = kinetic energy   I/O unit (0 no I/O)
  0	'sfnio ' = layer k  strmfn. I/O unit (0 no I/O)
  0	'kf    ' = first output layer (=0 end output; <0 label with layer #)
E-o-D
#
/bin/rm -f regional.*
