#!/bin/csh
#
set echo
#
# --- extract montg and ssh for relax_montg.a
#
setenv DS /p/work1/${user}/HYCOM-examples/GLBt0.72/datasets
setenv TOOLS ~/HYCOM-tools

touch regional.depth.a regional.depth.b
if (-z regional.depth.a) then
  /bin/rm regional.depth.a
  /bin/ln -s ${DS}/topo/depth_GLBt0.72_15.a regional.depth.a
endif
if (-z regional.depth.b) then
  /bin/rm regional.depth.b
  /bin/ln -s ${DS}/topo/depth_GLBt0.72_15.b regional.depth.b
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
# --- D,y select the mean archive files.
#
setenv E 019
setenv X `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'`
setenv D ${DS}/../expt_${X}/data/meanstd
#
foreach y ( 1911-1915 )
    setenv FOR021A ${D}/relax_montg_${E}.a
    setenv FOR021  ${D}/relax_montg_${E}.b
    /bin/rm $FOR021
    /bin/rm $FOR021A
    ${TOOLS}/archive/src/archv2data2d <<E-o-D
${D}/${E}_archm.${y}.a
HYCOM
000	'iexpt ' = experiment number x10 (000=from archive file)
  0	'yrflag' = days in year flag (0=360J16,1=366J16,2=366J01,3-actual)
500     'idm   ' = longitudinal array size
382     'jdm   ' = latitudinal  array size
  1	'kdm   ' = number of layers
 34.0	'thbase' = reference density (sigma units)
  0	'smooth' = smooth fields before plotting (0=F,1=T)
  0	'mthin ' = mask thin layers from plots   (0=F,1=T)
  0	'baclin' = extract baroclinic velocity (0=total,1=baroclinic)
  1	'iorign' = i-origin of plotted subregion
  1	'jorign' = j-origin of plotted subregion
  0	'idmp  ' = i-extent of plotted subregion (<=idm; 0 implies idm)
  0	'jdmp  ' = j-extent of plotted subregion (<=jdm; 0 implies jdm)
  0	'botio ' = bathymetry       I/O unit (0 no I/O)
  0	'flxio ' = surf. heat flux  I/O unit (0 no I/O)
  0	'empio ' = surf. evap-pcip  I/O unit (0 no I/O)
  0	'tbfio ' = temp. bou. flux  I/O unit (0 no I/O)
  0	'sbfio ' = saln. bou. flux  I/O unit (0 no I/O)
  0	'abfio ' = total bou. flux  I/O unit (0 no I/O)
  0	'icvio ' = ice coverage     I/O unit (0 no I/O)
  0	'ithio ' = ice thickness    I/O unit (0 no I/O)
  0	'ictio ' = ice temperature  I/O unit (0 no I/O)
 21     'montio' = ave. HYCOM th3d  I/O unit (0 no I/O)
 21	'sshio ' = sea surf. height I/O unit (0 no I/O)
  0     'bkeio ' = baro. k.e.       I/O unit (0 no I/O)
  0	'bsfio ' = baro.   strmfn.  I/O unit (0 no I/O)
  0	'uvmio ' = mix. lay. u-vel. I/O unit (0 no I/O)
  0	'vvmio ' = mix. lay. v-vel. I/O unit (0 no I/O)
  0	'spmio ' = mix. lay. speed  I/O unit (0 no I/O)
  0	'bltio ' = bnd. lay. thick. I/O unit (0 no I/O)
  0	'mltio ' = mix. lay. thick. I/O unit (0 no I/O)
  0	'sstio ' = mix. lay. temp.  I/O unit (0 no I/O)
  0	'sssio ' = mix. lay. saln.  I/O unit (0 no I/O)
  0	'ssdio ' = mix. lay. dens.  I/O unit (0 no I/O)
  0     'mkeio ' = mix. lay. k.e.   I/O unit (0 no I/O)
  0	'kf    ' = first output layer (=0 end output; <0 label with layer #)
E-o-D
end

\rm regional*
