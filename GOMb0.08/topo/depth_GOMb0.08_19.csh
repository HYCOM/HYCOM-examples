#!/bin/csh -x
#PBS -N depth_GOMb0.08_19
#PBS -j oe
#PBS -o depth_GOMb0.08_19.log
#PBS -W umask=027
#PBS -l application=home-grown
#PBS -l select=1:ncpus=128:mpiprocs=16
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122 
#PBS -q debug
#
set echo
set time=1
#
# --- interpolate 15-sec GEBCO to hycom bathymetry.
# --- may need manual editing to produce a "good" model bathmetry
#
setenv DG /p/work1/${user}/topo_ieee/GEBCO_2019
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools
#
cd $DS
#
setenv FOR061  fort.61
setenv FOR061A fort.61A
#
/bin/rm -f $FOR061 $FOR061A
#
# --- https://www.gebco.net/data_and_products/historical_data_sets/#gebco_2019
# --- 15-second is 240*0.08 = 19.2 per grid point, so use INTERP=-9.
#
setenv CDF_GEBCO ${DG}/GEBCO_2019.nc
#
${TOOLS}/topo/src/bathy_15sec <<'E-o-D'
 &TOPOG
  CTITLE = 'bathymetery from 15-second GEBCO_2019 global dataset',
  COAST  =     0.10,! DEPTH OF MODEL COASTLINE (-ve keeps orography)
  FLAND  =     0.0, ! FAVOR LAND VALUES
  INTERP = -9,      ! =-N; AVERAGE OVER (2*N+1)x(2*N+1) GRID PATCH
                    ! = 0; PIECEWISE LINEAR.  = 1; CUBIC SPLINE.
  MTYPE  =  0,      ! = 0; CLOSED DOMAIN. = 1; NEAR GLOBAL. = 2; FULLY GLOBAL.
 /
'E-o-D'
#
/bin/mv fort.61  depth_GOMb0.08_19.b
/bin/mv fort.61A depth_GOMb0.08_19.a
