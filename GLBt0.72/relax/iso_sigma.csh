#! /bin/csh
set echo
set time = 1
C
C
C --- Generate HYCOM spatially varying isopycnal target densities.
C --- Mediterranean Sea 2 boxes,
C
C
C --- set copy command
if (-e ~${user}/bin/pget) then
C --- remote copy
  setenv pget ~${user}/bin/pget
  setenv pput ~${user}/bin/pput
else
C --- local copy
  setenv pget cp
  setenv pput cp
endif

C
C --- E is experiment number, from EXPT.src
C --- R is region identifier, from EXPT.src
C --- T is topog. identifier, from EXPT.src
C
C --- P is primary path,
C --- S is scratch directory,
C
source EXPT.src
C
setenv P relax/${E}
setenv S ${DS}/${P} 
C
mkdir -p $S
cd       $S
C
touch   iso_density fort.61 fort.61A regional.grid.a regional.grid.b
/bin/rm iso_density fort.61 fort.61A regional.grid.a regional.grid.b
C
C --- Input.
C

C
C --- get grid and bathymetry
C
touch fort.61 fort.61A
if (-z fort.61) then
  ${pget} ${DS}/topo/depth_${R}_${T}.b fort.61 &
endif
if (-z fort.61A) then
  ${pget} ${DS}/topo/depth_${R}_${T}.a fort.61A &
endif
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
C
C --- get executable
C
touch iso_density
if (-z iso_density) then
 ${pget} ${TOOLS}/relax/src/iso_density . &
endif
wait
chmod a+rx iso_density
C
/bin/rm -f core
touch core

/bin/rm -f fort.10 fort.10A
C
setenv FOR010A fort.10A
setenv FOR061A fort.61A
C
cat <<'E-o-D' >! fort.99
 500	  'idm   ' = longitudinal array size
 382	  'jdm   ' = latitudinal  array size
  41	  'kdm   ' = number of layers
  17.00   'sigma ' = layer  1 isopycnal target density (sigma units)
  18.00   'sigma ' = layer  2 isopycnal target density (sigma units)
  19.00   'sigma ' = layer  3 isopycnal target density (sigma units)
  20.00   'sigma ' = layer  4 isopycnal target density (sigma units)
  21.00   'sigma ' = layer  5 isopycnal target density (sigma units)
  22.00   'sigma ' = layer  6 isopycnal target density (sigma units)
  23.00   'sigma ' = layer  7 isopycnal target density (sigma units)
  24.00   'sigma ' = layer  8 isopycnal target density (sigma units)
  25.00   'sigma ' = layer  9 isopycnal target density (sigma units)
  26.00   'sigma ' = layer 10 isopycnal target density (sigma units)
  27.00   'sigma ' = layer 11 isopycnal target density (sigma units)
  28.00   'sigma ' = layer 12 isopycnal target density (sigma units)
  29.00   'sigma ' = layer 13 isopycnal target density (sigma units)
  29.90   'sigma ' = layer 14 isopycnal target density (sigma units)
  30.65   'sigma ' = layer  A isopycnal target density (sigma units)
  31.35   'sigma ' = layer  B isopycnal target density (sigma units)
  31.95   'sigma ' = layer  C isopycnal target density (sigma units)
  32.55   'sigma ' = layer  D isopycnal target density (sigma units)
  33.15   'sigma ' = layer  E isopycnal target density (sigma units)
  33.75   'sigma ' = layer  F isopycnal target density (sigma units)
  34.30   'sigma ' = layer  G isopycnal target density (sigma units)
  34.80   'sigma ' = layer  H isopycnal target density (sigma units)
  35.20   'sigma ' = layer  I isopycnal target density (sigma units)
  35.50   'sigma ' = layer 15 isopycnal target density (sigma units)
  35.80   'sigma ' = layer 16 isopycnal target density (sigma units)
  36.04   'sigma ' = layer 17 isopycnal target density (sigma units)
  36.20   'sigma ' = layer 18 isopycnal target density (sigma units)
  36.38   'sigma ' = layer 19 isopycnal target density (sigma units)
  36.52   'sigma ' = layer 20 isopycnal target density (sigma units)
  36.62   'sigma ' = layer 21 isopycnal target density (sigma units)
  36.70   'sigma ' = layer 22 isopycnal target density (sigma units)
  36.77   'sigma ' = layer 23 isopycnal target density (sigma units)
  36.83   'sigma ' = layer 24 isopycnal target density (sigma units)
  36.89   'sigma ' = layer 25 isopycnal target density (sigma units)
  36.97   'sigma ' = layer 26 isopycnal target density (sigma units)
  37.02   'sigma ' = layer 27 isopycnal target density (sigma units)
  37.06   'sigma ' = layer 28 isopycnal target density (sigma units)
  37.10   'sigma ' = layer 29 isopycnal target density (sigma units)
  37.17   'sigma ' = layer 30 isopycnal target density (sigma units)
  37.30   'sigma ' = layer 31 isopycnal target density (sigma units)
  37.42   'sigma ' = layer 32 isopycnal target density (sigma units)
  390      'if    ' = first i point of sub-region (<=0 to end)
  400      'il    ' = last  i point of sub-region
  230      'jf    ' = first j point of sub-region
  247      'jl    ' = last  j point of sub-region
  17.00   'sigma ' = layer  1 isopycnal target density (sigma units)
  18.00   'sigma ' = layer  2 isopycnal target density (sigma units)
  19.00   'sigma ' = layer  3 isopycnal target density (sigma units)
  20.00   'sigma ' = layer  4 isopycnal target density (sigma units)
  21.00   'sigma ' = layer  5 isopycnal target density (sigma units)
  22.00   'sigma ' = layer  6 isopycnal target density (sigma units)
  23.00   'sigma ' = layer  7 isopycnal target density (sigma units)
  24.00   'sigma ' = layer  8 isopycnal target density (sigma units)
  25.00   'sigma ' = layer  9 isopycnal target density (sigma units)
  26.00   'sigma ' = layer 10 isopycnal target density (sigma units)
  27.00   'sigma ' = layer 11 isopycnal target density (sigma units)
  28.00   'sigma ' = layer 12 isopycnal target density (sigma units)
  29.00   'sigma ' = layer 13 isopycnal target density (sigma units)
  29.90   'sigma ' = layer 14 isopycnal target density (sigma units)
  30.65   'sigma ' = layer  A isopycnal target density (sigma units)
  31.35   'sigma ' = layer  B isopycnal target density (sigma units)
  31.95   'sigma ' = layer  C isopycnal target density (sigma units)
  32.55   'sigma ' = layer  D isopycnal target density (sigma units)
  33.15   'sigma ' = layer  E isopycnal target density (sigma units)
  33.75   'sigma ' = layer  F isopycnal target density (sigma units)
  34.30   'sigma ' = layer  G isopycnal target density (sigma units)
  34.80   'sigma ' = layer  H isopycnal target density (sigma units)
  35.20   'sigma ' = layer  I isopycnal target density (sigma units)
  35.50   'sigma ' = layer  I isopycnal target density (sigma units)
  35.85   'sigma ' = layer 15 isopycnal target density (sigma units)
  36.20   'sigma ' = layer 16 isopycnal target density (sigma units)
  36.55   'sigma ' = layer 17 isopycnal target density (sigma units)
  36.90   'sigma ' = layer 18 isopycnal target density (sigma units)
  37.25   'sigma ' = layer 19 isopycnal target density (sigma units)
  37.50   'sigma ' = layer 20 isopycnal target density (sigma units)
  37.63   'sigma ' = layer 21 isopycnal target density (sigma units)
  37.69   'sigma ' = layer 22 isopycnal target density (sigma units)
  37.73   'sigma ' = layer 23 isopycnal target density (sigma units)
  37.76   'sigma ' = layer 24 isopycnal target density (sigma units)
  37.79   'sigma ' = layer 25 isopycnal target density (sigma units)
  37.82   'sigma ' = layer 26 isopycnal target density (sigma units)
  37.85   'sigma ' = layer 27 isopycnal target density (sigma units)
  37.88   'sigma ' = layer 28 isopycnal target density (sigma units)
  37.91   'sigma ' = layer 29 isopycnal target density (sigma units)
  37.94   'sigma ' = layer 30 isopycnal target density (sigma units)
  37.97   'sigma ' = layer 31 isopycnal target density (sigma units)
  401      'if    ' = first i point of sub-region (<=0 to end)
  451      'il    ' = last  i point of sub-region
  223      'jf    ' = first j point of sub-region
  254      'jl    ' = last  j point of sub-region
  17.00   'sigma ' = layer  1 isopycnal target density (sigma units)
  18.00   'sigma ' = layer  2 isopycnal target density (sigma units)
  19.00   'sigma ' = layer  3 isopycnal target density (sigma units)
  20.00   'sigma ' = layer  4 isopycnal target density (sigma units)
  21.00   'sigma ' = layer  5 isopycnal target density (sigma units)
  22.00   'sigma ' = layer  6 isopycnal target density (sigma units)
  23.00   'sigma ' = layer  7 isopycnal target density (sigma units)
  24.00   'sigma ' = layer  8 isopycnal target density (sigma units)
  25.00   'sigma ' = layer  9 isopycnal target density (sigma units)
  26.00   'sigma ' = layer 10 isopycnal target density (sigma units)
  27.00   'sigma ' = layer 11 isopycnal target density (sigma units)
  28.00   'sigma ' = layer 12 isopycnal target density (sigma units)
  29.00   'sigma ' = layer 13 isopycnal target density (sigma units)
  29.90   'sigma ' = layer 14 isopycnal target density (sigma units)
  30.65   'sigma ' = layer  A isopycnal target density (sigma units)
  31.35   'sigma ' = layer  B isopycnal target density (sigma units)
  31.95   'sigma ' = layer  C isopycnal target density (sigma units)
  32.55   'sigma ' = layer  D isopycnal target density (sigma units)
  33.15   'sigma ' = layer  E isopycnal target density (sigma units)
  33.75   'sigma ' = layer  F isopycnal target density (sigma units)
  34.30   'sigma ' = layer  G isopycnal target density (sigma units)
  34.80   'sigma ' = layer  H isopycnal target density (sigma units)
  35.20   'sigma ' = layer  I isopycnal target density (sigma units)
  35.50   'sigma ' = layer  I isopycnal target density (sigma units)
  35.85   'sigma ' = layer 15 isopycnal target density (sigma units)
  36.20   'sigma ' = layer 16 isopycnal target density (sigma units)
  36.55   'sigma ' = layer 17 isopycnal target density (sigma units)
  36.90   'sigma ' = layer 18 isopycnal target density (sigma units)
  37.25   'sigma ' = layer 19 isopycnal target density (sigma units)
  37.50   'sigma ' = layer 20 isopycnal target density (sigma units)
  37.63   'sigma ' = layer 21 isopycnal target density (sigma units)
  37.69   'sigma ' = layer 22 isopycnal target density (sigma units)
  37.73   'sigma ' = layer 23 isopycnal target density (sigma units)
  37.76   'sigma ' = layer 24 isopycnal target density (sigma units)
  37.79   'sigma ' = layer 25 isopycnal target density (sigma units)
  37.82   'sigma ' = layer 26 isopycnal target density (sigma units)
  37.85   'sigma ' = layer 27 isopycnal target density (sigma units)
  37.88   'sigma ' = layer 28 isopycnal target density (sigma units)
  37.91   'sigma ' = layer 29 isopycnal target density (sigma units)
  37.94   'sigma ' = layer 30 isopycnal target density (sigma units)
  37.97   'sigma ' = layer 31 isopycnal target density (sigma units)
   0	  'if    ' = first i point of sub-region (<=0 to end)
'E-o-D'
C
./iso_density
C
C
C --- Output.
C
/bin/mv fort.10  iso_sigma.b
/bin/mv fort.10A iso_sigma.a
C
C --- Delete all scratch directory files.
C
/bin/rm -f  regional* core fort.* iso_density
