#
set echo
# DS is datasets/topo directory
# D  is current directory
# T  is topography file name
# TV is version of topography to use
#
#setenv DS ~/HYCOM-examples/GOMb0.08/datasets/topo
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo
setenv D ${cwd}
setenv T `echo $cwd | awk -f depth.awk`
setenv TV `echo ${T} | cut -d"_" -f 3-`
cd ${DS}/partit/${TV}
#
# --- generate selected full size PPM image file.
#
/bin/rm -f regional.grid.a regional.grid.b
ln -s $DS/regional.grid.a .
ln -s $DS/regional.grid.b .
ln -s ${D}/xbathy.pal .
#
#
setenv FOR021  fort.21
setenv FOR051  $DS/${T}.b
setenv FOR051A $DS/${T}.a
#
ln -s S04/patch.input_016 ${T}.016s
ln -s S06/patch.input_024 ${T}.024s
ln -s S06/patch.input_030 ${T}.030s
ln -s S08/patch.input_047 ${T}.047s
ln -s S09/patch.input_062 ${T}.062s
ln -s S13/patch.input_096 ${T}.096s
ln -s S12/patch.input_122 ${T}.122s
#
foreach f ( ${T}.[0-9]??s )
  cp $f fort.21
  echo 1 | ~/HYCOM-tools/topo/src/topo_ppmX
  mv fort.31 ${f}.ppm
  /bin/rm -f fort.21
end
#
#/bin/rm -f regional.grid.a regional.grid.b xbathy.pal
