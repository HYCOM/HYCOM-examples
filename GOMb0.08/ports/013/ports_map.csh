#
set echo
#
# ---  Map Open Boundaries
#
source EXPT.src
#
sed -e "/sports/d" ../../expt_${X}/ports.input >! ../../expt_${X}/ports.input_nosp
/bin/rm -f ports.input
ln -s ../../expt_${X}/ports.input_nosp ports.input
#
setenv FOR051A fort.51A
/bin/rm -f fort.51 fort.51A
ln -s ../../topo/depth_${R}_${T}.b fort.51
ln -s ../../topo/depth_${R}_${T}.a fort.51A
#
if (! -e regional.grid.a) then
  /bin/ln -s ../../topo/regional.grid.a .
  /bin/ln -s ../../topo/regional.grid.b .
endif
#
~/HYCOM-tools/topo/src/topo_ports
#
/bin/rm -f fort.51 fort.51A
/bin/rm -f regional.grid.a regional.grid.b
