#!/bin/csh
#
set echo
C
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
setenv R GLBt0.72
setenv EX ~/HYCOM-examples/${R}/expt_${X}
source ${EX}/EXPT.src

# --- config domain
setenv IDM    `grep idm ${D}/../blkdat.input | awk '{print $1}'`
setenv JDM    `grep jdm ${D}/../blkdat.input | awk '{print $1}'`

setenv SRC      ~/HYCOM-tools
setenv BINRUN    ""
C
switch ($OS)
case 'XC30':
case 'XC40':
C --- XT4, XT5 or XC30
  setenv SRC        ~/HYCOM-tools/ALT
  setenv BINRUN      "aprun -n 1"
  breaksw
endsw
#
setenv Y 001
setenv YRFLAG `grep yrflag ${D}/../blkdat.input | awk '{print $1}'`
if (${YRFLAG} == 3) then
  setenv YY `echo ${Y} | awk '{printf("%03d", $1+1900)}'`
else
  setenv YY `echo ${Y} | awk '{printf("%03d", $1)}'`
endif
setenv P a
setenv J 001
#
if (${YRFLAG} == 3) then
  if (${J} == 001) setenv YY `echo ${Y} | awk '{printf("%03d", $1-1901)}'`
else
  if (${J} == 001) setenv YY `echo ${Y} | awk '{printf("%03d", $1)}'`
endif
#
setenv A    ${S}/archive
setenv ATMP ${S}/archive/${Y}${P}
#
if ( ! -d ${ATMP} ) /bin/mkdir -p ${ATMP}
cd ${ATMP}
#
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
#
setenv FOR032A ${ATMP}/${E}_archm.${Y}_${J}_12_ssh.a
setenv FOR032  ${ATMP}/${E}_archm.${Y}_${J}_12_ssh.b
setenv FOR033A ${ATMP}/${E}_archm.${Y}_${J}_12_sst.a
setenv FOR033  ${ATMP}/${E}_archm.${Y}_${J}_12_sst.b
setenv FOR035A ${ATMP}/${E}_archm.${Y}_${J}_12_uv1.a
setenv FOR035  ${ATMP}/${E}_archm.${Y}_${J}_12_uv1.b
setenv FOR036A ${ATMP}/${E}_archm.${Y}_${J}_12_vv1.a
setenv FOR036  ${ATMP}/${E}_archm.${Y}_${J}_12_vv1.b
/bin/rm -f $FOR032A $FOR033A $FOR035A $FOR036A
/bin/rm -f $FOR032  $FOR033  $FOR035  $FOR036
${BINRUN} ${SRC}/archive/src/archv2data2d <<E-o-D
${S}/tarm_${YY}${P}/${E}_archm.${Y}_${J}_12.a
HYCOM
000	'iexpt ' = experiment number x10 (000=from archive file)
  3	'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
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
  0	'flxio ' = surf. heat flux  I/O unit (0 no I/O)
  0	'empio ' = surf. evap-pcip  I/O unit (0 no I/O)
  0	'ttrio ' = surf. temp trend I/O unit (0 no I/O)
  0	'strio ' = surf. saln trend I/O unit (0 no I/O)
  0	'icvio ' = ice coverage     I/O unit (0 no I/O)
  0	'ithio ' = ice thickness    I/O unit (0 no I/O)
  0	'ictio ' = ice temperature  I/O unit (0 no I/O)
 32	'sshio ' = sea surf. height I/O unit (0 no I/O)
  0     'bkeio ' = baro. k.e.       I/O unit (0 no I/O)
  0	'bsfio ' = baro. strmfn.    I/O unit (0 no I/O)
  0	'uvmio ' = mix. lay. u-vel. I/O unit (0 no I/O)
  0	'vvmio ' = mix. lay. v-vel. I/O unit (0 no I/O)
  0	'spmio ' = mix. lay. speed  I/O unit (0 no I/O)
  0	'bltio ' = bnd. lay. thick. I/O unit (0 no I/O)
  0	'mltio ' = mix. lay. thick. I/O unit (0 no I/O)
  0	'sstio ' = mix. lay. temp.  I/O unit (0 no I/O)
  0	'sssio ' = mix. lay. saln.  I/O unit (0 no I/O)
  0	'ssdio ' = mix. lay. dens.  I/O unit (0 no I/O)
  0     'mkeio ' = mix. lay. k.e.   I/O unit (0 no I/O)
 -1	'kf    ' = first output layer (=0 end output; <0 label with layer #)
  1	'kl    ' = last  output layer
 35	'uvlio ' = layer k   u-vel. I/O unit (0 no I/O)
 36	'vvlio ' = layer k   v-vel. I/O unit (0 no I/O)
  0	'splio ' = layer k   speed. I/O unit (0 no I/O)
  0	'infio ' = layer k   i.dep. I/O unit (0 no I/O)
  0	'thkio ' = layer k   thick. I/O unit (0 no I/O)
 33	'temio ' = layer k   temp   I/O unit (0 no I/O)
  0	'salio ' = layer k   saln.  I/O unit (0 no I/O)
  0	'tthio ' = layer k   dens,  I/O unit (0 no I/O)
  0     'keio  ' = kinetic energy   I/O unit (0 no I/O)
  0	'sfnio ' = layer k  strmfn. I/O unit (0 no I/O)
  0	'kf    ' = first output layer (=0 end output; <0 label with layer #)
E-o-D
#
/bin/rm -f regional.*
