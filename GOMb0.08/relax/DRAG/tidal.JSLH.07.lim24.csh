#
set echo
#
# --- JSL to JSLH
#
setenv RO GOMb0.08
cd ~/HYCOM-examples/${RO}/relax/DRAG
setenv IDM 263
setenv JDM 193
setenv T 07
#
/bin/rm -f depth_${T}.a
hycom_void ../../topo/depth_${RO}_${T}.a ${IDM} ${JDM} 0.0 depth_${T}.a >! depth_${T}.b
#
/bin/rm -f tidal.JSLH.${T}.lim24.a
hycom_expr JSL_lim24.a depth_${T}.a ${IDM} ${JDM} 0.0 0.0 tidal.JSLH.${T}.lim24.a | grep "min" >! tidal.JSLH.${T}.lim24.b
