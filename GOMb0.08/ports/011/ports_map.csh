#
set echo
#
# ---  Map Open Boundaries
#
setenv E `echo $cwd | awk '{print substr($0,length($0)-2,length($0))}'`
setenv X `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'`
source ../../expt_${X}/EXPT.src
#
#Cray: ~/HYCOM-tools/bin is for CNL (ftn)
#setenv BINRUN "aprun -n 1"
setenv BINRUN ""
#
/bin/rm -f ports.input
ln -s ../../expt_${X}/ports.input .
#
setenv FOR051A fort.51A
/bin/rm -f fort.51 fort.51A
ln -s ${DS}/topo/depth_${R}_${T}.b fort.51
ln -s ${DS}/topo/depth_${R}_${T}.a fort.51A
#
if (! -e regional.grid.a) then
  /bin/ln -s ${DS}/topo/regional.grid.a .
  /bin/ln -s ${DS}/topo/regional.grid.b .
endif
#
${BINRUN} ~/HYCOM-tools/topo/src/topo_ports
#
/bin/rm -f fort.51 fort.51A
/bin/rm -f regional.grid.a regional.grid.b
