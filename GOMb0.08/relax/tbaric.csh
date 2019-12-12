#! /bin/csh
#
set echo
set time = 1
C
C
C --- Generate HYCOM thkdf4_rstrt.a file with .01 everywhere except .05
C --- Script has idm and jdm values hardwired.
# --- Use regional.grid in place of depth_${R}_${T} so values gets spread over land.
C ---
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
C --- C is scratch directory,
C --- D is permanent directory,
C
source EXPT.src
C
setenv P relax/${E}
setenv S ${DS}/${P}
setenv IDM    `grep idm ${DS}/topo/regional.grid.b | awk '{print $1}'`
setenv JDM    `grep jdm ${DS}/topo/regional.grid.b | awk '{print $1}'`
C
C
mkdir -p $S
cd       $S
C
touch   iso_density fort.51 fort.51A fort.61A regional.grid.a regional.grid.b
/bin/rm iso_density fort.51 fort.51A fort.61A regional.grid.a regional.grid.b
C
C --- Input.
C

C
C --- get grid and bathymetry
C
touch fort.51 fort.51A
if (-z fort.51) then
  ${pget} ${DS}/topo/depth_${R}_${T}.b fort.51 &
#  ${pget} ${DS}/topo/regional.grid.b fort.51 &
endif
if (-z fort.51A) then
  ${pget} ${DS}/topo/depth_${R}_${T}.a fort.51A &
#  ${pget} ${DS}/topo/regional.grid.a fort.51A &
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
C --- get executable
C
touch iso_density
if (-z iso_density) then
 ${pget} ${TOOLS}/relax/src/iso_density . &
endif

wait
cp fort.51A fort.61A
chmod a+rx iso_density
C
/bin/rm -f fort.10 fort.10A fort.10M tbaric.a tbaric.b
C
setenv FOR010A fort.10A
setenv FOR051A fort.51A
setenv FOR061A fort.61A
C
cat <<'E-o-D' >! fort.99
 500	  'idm   ' = longitudinal array size
 382	  'jdm   ' = latitudinal  array size
   1	  'kdm   ' = number of layers
   1.0    'sigma ' = default thermobaric reference state (1.0,2.0,3.0)
   1	  'if    ' = first i point of sub-region (<=0 to end)
 500	  'il    ' = last  i point of sub-region
 110	  'jf    ' = first j point of sub-region
 160	  'jl    ' = last  j point of sub-region
   1.00   'sigmaA' = bottom left  thermobaric reference state
   1.00   'sigmaB' = bottom right thermobaric reference state
   2.00   'sigmaC' = top    right thermobaric reference state
   2.00   'sigmaD' = top    left  thermobaric reference state
   1      'if    ' = first i point of sub-region (<=0 to end)
 250      'il    ' = last  i point of sub-region
 305      'jf    ' = first j point of sub-region
 382      'jl    ' = last  j point of sub-region
   1.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
   1      'if    ' = first i point of sub-region (<=0 to end)
 250      'il    ' = last  i point of sub-region
 160      'jf    ' = first j point of sub-region
 305      'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 250      'if    ' = first i point of sub-region (<=0 to end)
 394      'il    ' = last  i point of sub-region
 160      'jf    ' = first j point of sub-region
 275      'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 394	  'if    ' = first i point of sub-region (<=0 to end)
 410	  'il    ' = last  i point of sub-region
 268	  'jf    ' = first j point of sub-region
 274	  'jl    ' = last  j point of sub-region
   1.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
   1	  'if    ' = first i point of sub-region (<=0 to end)
 250	  'il    ' = last  i point of sub-region
 305	  'jf    ' = first j point of sub-region
 382	  'jl    ' = last  j point of sub-region
   1.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 254	  'if    ' = first i point of sub-region (<=0 to end)
 351	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 367	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 352	  'if    ' = first i point of sub-region (<=0 to end)
 362	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 306	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 363	  'if    ' = first i point of sub-region (<=0 to end)
 363	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 305	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 364	  'if    ' = first i point of sub-region (<=0 to end)
 364	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 304	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 365	  'if    ' = first i point of sub-region (<=0 to end)
 365	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 303	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 366	  'if    ' = first i point of sub-region (<=0 to end)
 377	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 302	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 378	  'if    ' = first i point of sub-region (<=0 to end)
 380	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 299	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 381	  'if    ' = first i point of sub-region (<=0 to end)
 381	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 298	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 382	  'if    ' = first i point of sub-region (<=0 to end)
 382	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 297	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 383	  'if    ' = first i point of sub-region (<=0 to end)
 383	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 295	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 384	  'if    ' = first i point of sub-region (<=0 to end)
 386	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 294	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 387	  'if    ' = first i point of sub-region (<=0 to end)
 388	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 292	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 389	  'if    ' = first i point of sub-region (<=0 to end)
 389	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 287	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 390	  'if    ' = first i point of sub-region (<=0 to end)
 390	  'il    ' = last  i point of sub-region
 275	  'jf    ' = first j point of sub-region
 277	  'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 392      'if    ' = first i point of sub-region (<=0 to end)
 500      'il    ' = last  i point of sub-region
 160      'jf    ' = first j point of sub-region
 265      'jl    ' = last  j point of sub-region
   2.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 390      'if    ' = first i point of sub-region (<=0 to end)
 401      'il    ' = last  i point of sub-region
 230      'jf    ' = first j point of sub-region
 247      'jl    ' = last  j point of sub-region
   3.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
 402      'if    ' = first i point of sub-region (<=0 to end)
 448      'il    ' = last  i point of sub-region
 225      'jf    ' = first j point of sub-region
 251      'jl    ' = last  j point of sub-region
   3.0    'sigma ' = thermobaric reference state (1.0,2.0,3.0)
   0	  'if    ' = first i point of sub-region (<=0 to end)
'E-o-D'
C
./iso_density
C
C
C --- Output.
C
cat <<'E-o-D' >! tbaric.b
Thermobaric Reference State
i/jdm =  500 382 
Default 2.0; Antarctic and Arctic 1.0; Mediterranean 3.0
Switchover between 38S and 4.3S and at sills to GIN Sea
Smoothed 3 times
'E-o-D'
sed -e "s/target_density: layer,range = 01/tbaric: range =/" fort.10 >> tbaric.b
#
${TOOLS}/bin/hycom_mask   fort.10A fort.51A 500 382      fort.10M
${TOOLS}/bin/hycom_smooth fort.10M          500 382 3    tbaric.a
${TOOLS}/bin/hycom_zonal  tbaric.a          500 382 1 >! tbaric.zonal
#
#${pput} tbaric.b     ${D}/tbaric.b
#${pput} tbaric.a     ${D}/tbaric.a
#${pput} tbaric.zonal ${D}/tbaric.zonal
#C
#C --- Delete all scratch directory files.
#C
/bin/rm -f fort* iso_density region*
