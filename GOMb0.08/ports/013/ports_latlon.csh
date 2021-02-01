#
set echo
#
# ---  Generate lat lon values at Open Boundary Points
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
/bin/rm -f ports_latlon.input ports_latlon_ij.input ports_a.input ports_nsew.input
~/HYCOM-tools/topo/src/topo_ports_latlon
#
/bin/rm -f fort.51 fort.51A
/bin/rm -f regional.grid.a regional.grid.b
#
# --- check for dumplicted points
#
setenv FATAL `uniq -d ports_latlon.input | wc -l`
if ($FATAL > 0) then
  echo 'error - duplicate lines in ports_latlon.input'
  uniq -d ports_latlon.input
  echo 'reorder the ports in ports.input'
endif
