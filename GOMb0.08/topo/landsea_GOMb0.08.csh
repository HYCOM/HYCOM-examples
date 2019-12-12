#! /bin/csh
#
set echo
set time=1
#
# --- interpolate 1-min to hycom landsea mask.
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
setenv FOR061A fort.61A
#
/bin/rm -f $FOR061A
#
setenv CDF_GEBCO ~/topo_ieee/GEBCO_30sec/GEBCO_2014_1D.nc
#
${TOOLS}/topo/src/landsea_30sec <<'E-o-D'
 &TOPOG
  INTERP = -4,      ! =-N; AVERAGE OVER (2*N+1)x(2*N+1) GRID PATCH
                    ! = 0; PIECEWISE LINEAR.  = 1; CUBIC SPLINE.
  MTYPE  =  0,      ! = 0; CLOSED DOMAIN. = 1; NEAR GLOBAL. = 2; FULLY GLOBAL.
 /
'E-o-D'
#
/bin/mv fort.61A landsea_GOMb0.08.a
