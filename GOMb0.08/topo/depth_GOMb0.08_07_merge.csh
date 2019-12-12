#
set echo
#
# --- merge two HYCOM bathymetries 
#
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets/topo/
setenv TOOLS ~/HYCOM-tools

cd ${DS}/
#
/bin/rm -f fort.[567]1*
setenv FOR051  fort.51 
setenv FOR051A fort.51A
setenv FOR061  fort.61 
setenv FOR061A fort.61A
setenv FOR071  fort.71 
setenv FOR071A fort.71A
ln -s depth_GOMb0.08_04.b fort.51
ln -s depth_GOMb0.08_04.a fort.51A
ln -s depth_GOMb0.08_09m11.b fort.61
ln -s depth_GOMb0.08_09m11.a fort.61A
/bin/rm -f $FOR071 $FOR071A
#
${TOOLS}/topo/src/topo_merge <<'E-o-D'
 &MERGE
  CTITLE = 'depth_GOMb0.01_04bs17m subregioned to GOMb0.08 via isuba_topog',
           '0.01 deg. resolution; boxsmoothed 9x; land from 5x;',
           'lon: -98.00 to -77.0000.  lat: 18.09165N to 31.96065N.',
           'Filled single-width inlets and 1-point seas.',
           'Re-merged with depth_GLBb0.08_09m11 near open boundaries.',
  IF     =   129,   129,  252,   241,   241,   230,   252,   241,   201,   201,
  IL     =   261,   261,  261,   251,   250,   240,   261,   251,   261,   261,
  JF     =     2,    12,    3,     3,    60,    60,   121,   121,   183,   172,
  JL     =    11,    22,   24,    24,   116,   116,   192,   192,   192,   182,
! ---      scale       - multiplier for 2nd bathymetry in box
! ---                     =-9.0; use boxscl linearly varying multiplier
! ---                     < 0.0; use 1st bathymetry, but merge land
! ---                     = 0.0; use 1st bathymetry only (default)
! ---                     = 1.0; use 2nd bathymetry only
! ---                     = 0.0-1.0; use fraction of each bathymetry
! ---                     = 2.0; use 2nd bathymetry where 1st is land
! ---                     = 3.0; use 2nd bathymetry where 1st is near land
  SCALE  =   1.0,  -9.0,   1.0,  -9.0,  1.0,  -9.0,   1.0,  -9.0,   1.0,  -9.0,
! ---      boxscl(1,:) - scale factor for (if,jf) between 0.0 and 1.0
! ---      boxscl(2,:) - scale factor for (il,jf) between 0.0 and 1.0
! ---      boxscl(3,:) - scale factor for (il,jl) between 0.0 and 1.0
! ---      boxscl(4,:) - scale factor for (if,jl) between 0.0 and 1.0
  BOXSCL =   1.0,   1.0,   1.0,   1.0,
             1.0,   1.0,   0.0,   0.0,
             1.0,   1.0,   1.0,   1.0,
             0.0,   1.0,   1.0,   0.0,
             1.0,   1.0,   1.0,   1.0,
             0.0,   1.0,   1.0,   0.0,
             1.0,   1.0,   1.0,   1.0,
             0.0,   1.0,   1.0,   0.0,
             1.0,   1.0,   1.0,   1.0,
             0.0,   0.0,   1.0,   1.0,
 &END
'E-o-D'
#
mv fort.71  depth_GOMb0.08_07.b
mv fort.71A depth_GOMb0.08_07.a
#
/bin/rm -f fort.[56]1*
