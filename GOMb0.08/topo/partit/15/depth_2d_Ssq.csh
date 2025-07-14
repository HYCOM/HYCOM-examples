#
set echo
#
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

mkdir -p ${DS}/partit/${TV}
cd ${DS}/partit/${TV}
#
# --- generate 2-d equal area processor partitions
# --- shift tiles if it reduces the tile count.
# --- nearly-square tiles
#
/bin/rm -f regional.grid.a regional.grid.b
ln -s $DS/regional.grid.a .
ln -s $DS/regional.grid.b .
#
setenv FOR051  $DS/${T}.b
setenv FOR051A $DS/${T}.a
#
setenv NX `head -n 1 regional.grid.b | sed -e "s/^  *//g" -e "s/ .*//g"`
setenv NY `head -n 2 regional.grid.b | tail -n 1 | sed -e "s/^  *//g" -e "s/ .*//g"`
echo $NX $NY
#
#  next two lines set the range of tilings considered
#  note that tiles over land are discarded,
#   so the number of cores is less than m x n.
#
@ i = 4
while (${i} <= 14 )
  setenv n `echo $i | awk '{printf("%02d",$1)}'`
  @ i = ${i} + 1
  mkdir -p S${n}
#
#  Look for nearly square tiles,
#  scale by idm/jdm (NX/NY)
  setenv NI `expr $n \* $NY`
  setenv M  `expr $NI / $NX`
  echo "M =", $M
  @ k = -1
  while (${k} <= 3 )
    setenv m `expr $M + $k | awk '{printf("%02d",$1)}'`
    echo "m =", $m
    @ k = ${k} + 1
    echo "-$n -$m 9.1" | ~/HYCOM-tools/topo/src/partit
    setenv nm `head -2 fort.21 | tail -1 | awk '{printf("%3.3d\n",$1)}'`
    mv fort.21 S${n}/patch.input_${nm}
  end
end
