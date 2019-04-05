#
set echo
# DS is datasets/topo directory
# T  is topography file name
# TV is version of topography to use
#
#setenv DS ~/HYCOM-examples/GLBt0.72/datasets/topo
setenv DS /p/work1/${user}/HYCOM-examples/GLBt0.72/datasets/topo
setenv T `echo $cwd | awk -f depth.awk`
setenv TV `echo ${T} | cut -d"_" -f 3-`
cd ${DS}/partit/${TV}
#
# --- pad ibig+12,jbid+12 to a multiple of 8
#
#
setenv FOR011  fort.11
setenv FOR021  fort.21
#
foreach f ( ${T}.[0-9]??s )
  cp $f fort.21
  echo 8 1 | ~/HYCOM-tools/topo/src/partit_resize
  mv fort.11 ${f}8
  /bin/rm -f fort.21
  diff -biw $f ${f}8
  cp ${f}8 ../
end
