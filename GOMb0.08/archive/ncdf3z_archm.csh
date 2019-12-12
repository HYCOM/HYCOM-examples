#!/bin/csh
#
set echo
C
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
C --- XT4, XT5 or XC30
  setenv SRC ~/HYCOM-tools/ALT
  setenv BINRUN "aprun -n 1"
  breaksw
endsw

# --- domain and time
setenv Y 001
setenv IDM    `grep idm ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM    `grep jdm ${D}/../blkdat.input | awk '{print $1}'`
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
#
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
    setenv CDF030  ${ATMP}/${E}_archm.${Y}_${J}_12_3z.nc
    /bin/rm $CDF030  

# -- convert to NetCDF
${BINRUN} ${SRC}/archive/src/archv2ncdf3z <<E-o-D
${S}/tarm_${YY}${P}/${E}_archm.${Y}_${J}_12.a
netCDF
 000    'iexpt ' = experiment number x10 (000=from archive file)
   0    'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
 ${IDM} 'idm   ' = longitudinal array size
 ${JDM} 'jdm   ' = latitudinal  array size
  ${K}  'kdm   ' = number of layers
  34.0  'thbase' = reference density (sigma units)
   0    'smooth' = smooth the layered fields (0=F,1=T)
   1    'iorign' = i-origin of plotted subregion
   1    'jorign' = j-origin of plotted subregion
   0    'idmp  ' = i-extent of plotted subregion (<=idm; 0 implies idm)
   0    'jdmp  ' = j-extent of plotted subregion (<=jdm; 0 implies jdm)
   1    'itype ' = interpolation type (0=sample,1=linear)
  33    'kz    ' = number of depths to sample
   0.0  'z     ' = sample depth  1
  10.0  'z     ' = sample depth  2
  20.0  'z     ' = sample depth  3
  30.0  'z     ' = sample depth  4
  50.0  'z     ' = sample depth  5
  75.0  'z     ' = sample depth  6
 100.0  'z     ' = sample depth  7
 125.0  'z     ' = sample depth  8
 150.0  'z     ' = sample depth  9
 200.0  'z     ' = sample depth 10
 250.0  'z     ' = sample depth 11
 300.0  'z     ' = sample depth 12
 400.0  'z     ' = sample depth 13
 500.0  'z     ' = sample depth 14
 600.0  'z     ' = sample depth 15
 700.0  'z     ' = sample depth 16
 800.0  'z     ' = sample depth 17
 900.0  'z     ' = sample depth 18
1000.0  'z     ' = sample depth 19
1100.0  'z     ' = sample depth 20
1200.0  'z     ' = sample depth 21
1300.0  'z     ' = sample depth 22
1400.0  'z     ' = sample depth 23
1500.0  'z     ' = sample depth 24
1750.0  'z     ' = sample depth 25
2000.0  'z     ' = sample depth 26
2500.0  'z     ' = sample depth 27
3000.0  'z     ' = sample depth 28
3500.0  'z     ' = sample depth 29
4000.0  'z     ' = sample depth 30
4500.0  'z     ' = sample depth 31
5000.0  'z     ' = sample depth 32
5500.0  'z     ' = sample depth 33
   0    'botio ' = bathymetry  I/O unit (0 no I/O)
   0    'mltio ' = mix.l.thk.  I/O unit (0 no I/O)
   1.0  'tempml' = temperature jump across mixed-layer (degC,  0 no I/O)
   0.05 'densml' =     density jump across mixed-layer (kg/m3, 0 no I/O)
   0    'infio ' = intf. depth I/O unit (0 no I/O, <0 label with layer #)
   0    'wviio ' = intf. veloc I/O unit (0 no I/O)
  30    'wvlio ' = w-velocity  I/O unit (0 no I/O)
  30    'uvlio ' = u-velocity  I/O unit (0 no I/O)
  30    'vvlio ' = v-velocity  I/O unit (0 no I/O)
   0    'splio ' = speed       I/O unit (0 no I/O)
  30    'temio ' = temperature I/O unit (0 no I/O)
  30    'salio ' = salinity    I/O unit (0 no I/O)
  30    'tthio ' = density     I/O unit (0 no I/O)
  30    'keio  ' = kinetic egy I/O unit (0 no I/O)
E-o-D
#
/bin/rm -f regional.*
