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
#  ${pget} ${DS}/topo/depth_${R}_${T}.b fort.61 &
  ${pget} ${DS}/topo/regional.grid.b fort.51 &
endif
if (-z fort.51A) then
#  ${pget} ${DS}/topo/depth_${R}_${T}.a fort.61A &
  ${pget} ${DS}/topo/regional.grid.a fort.51A &
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
/bin/rm -f fort.10 fort.10A fort.10M thkdf4.a thkdf4.b
C
setenv FOR010A fort.10A
setenv FOR051A fort.51A
setenv FOR061A fort.61A
C
cat <<'E-o-D' >! fort.99
500	  'idm   ' = longitudinal array size
382	  'jdm   ' = latitudinal  array size
   1	  'kdm   ' = number of layers
   0.02   'sigma ' = default viscosity
   1	  'if    ' = first i point of sub-region (<=0 to end)
 500	  'il    ' = last  i point of sub-region
  1	  'jf    ' = first j point of sub-region
  65	  'jl    ' = last  j point of sub-region
   0.05   'sigma ' = viscosity
   0	  'if    ' = first i point of sub-region (<=0 to end)
'E-o-D'
C
./iso_density
C
C
C --- Output.
C
sed -e "s/target_density: layer,range = 01/thkdf4: range =/" fort.10 >! thkdf4.b
#
${TOOLS}/bin/hycom_mask   fort.10A fort.51A ${IDM} ${JDM}      fort.10M
${TOOLS}/bin/hycom_smooth fort.10M          ${IDM} ${JDM} 10   thkdf4.a
${TOOLS}/bin/hycom_zonal  thkdf4.a          ${IDM} ${JDM} 1 >! thkdf4.zonal
C
/bin/rm core ./iso_density fort.* regional.grid.?
#
#rcp thkdf4.b     newton:${D}/thkdf4.b
#rcp thkdf4.a     newton:${D}/thkdf4.a
#rcp thkdf4.zonal newton:${D}/thkdf4.zonal
