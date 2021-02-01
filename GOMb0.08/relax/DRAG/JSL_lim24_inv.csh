#
set echo
#
# --- convert JSL_lim24 to e-folding time in hours
#
setenv RO GOMb0.08
setenv T  07
/bin/rm -f JSL_lim24.mask.a JSL_lim24_inv_hrs.a
setenv IDM 263
setenv JDM 193

#
hycom_bandmask JSL_lim24.a      ${IDM} ${JDM} -1.0 0.0     JSL_lim24.mask.a >! JSL_lim24.mask.b
cat JSL_lim24.mask.b
#
hycom_expr JSL_lim24.mask.a INV ${IDM} ${JDM} 3600.0 1.0   JSL_lim24_inv_hrs.a >! JSL_lim24_inv_hrs.b
cat JSL_lim24_inv_hrs.b
#
hycom_histogram JSL_lim24_inv_hrs.a 1 0.0 720.0 1.0 ../../topo/regional.grid.a ../../topo/depth_${RO}_${T}.a >! JSL_lim24_inv_hrs.hist
