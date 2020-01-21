#!/bin/csh
#@$-lt 0:04:00
#@$-lT 0:04:00
#@$-lm 4mw
#@$-lM 4mw
#@$-s  /bin/csh
#@$
C
set echo
set time = 1 
C
C --- Script to horizontally interpolate NetCDF World Ocean Atlas 13 fields 
C --- onto HYCOM grid. For vertical interpolation, see relax.csh
C --- See z_woa13.f in HYCOM-tools/relax/src for interp. options.
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

C --- TOOLS is path to tools directory
C --- SP    is scratch prefix
C --- R     is region identifier
C --- DSR   is path to non specific domain datasets
C --- DS    is path to specific domain datasets
C
source EXPT.src

C --- P is relax output     directory,
C --- S is relax scratch  directory,
C --- L is WOA13 raw file  directory
C
setenv P   ${DS}/relax/WOA13
setenv S   ${P}/SCRATCH
setenv L   ${DSR}/WOA13_HYCOM
C
mkdir -p $S
cd       $S
C
C
C --- 12 months
C
foreach MM ( 01 02 03 04 05 06 07 08 09 10 11 12 )
C
C --- Input.
C
setenv CDF_TEMP tm${MM}.nc
setenv CDF_SALN sm${MM}.nc
C
ln -s  $L/WOA13_PTEMP_m${MM}.nc tm${MM}.nc  &
ln -s  $L/WOA13_SALT_m${MM}.nc sm${MM}.nc  &
C
C --- grid to interpolate to
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
C --- get executable
cp ${TOOLS}/relax/src/z_woa13 . &

wait
chmod a+rx z_woa13
C
/bin/rm -f core
touch core
setenv FOR010A fort.10A
setenv FOR011A fort.11A
setenv FOR012A fort.12A
/bin/rm -f fort.10 fort.10A fort.11 fort.11A fort.12 fort.12A
./z_woa13 <<E-o-D
 &AFTITL
  CTITLE = '1234567890123456789012345678901234567890',
  CTITLE = 'WOA13 monthly',
 /
 &AFFLAG
  ICTYPE =   3,
  SIGVER =   6,
  INTERP =   1,
  ITEST  = 232,
  JTEST  = 206,
  MONTH  = $MM,
 /
E-o-D
C
C --- Required Output, potential density and temperature.
C
mv fort.10  ${P}/temp_sig2-17t_m${MM}.b
mv fort.10A ${P}/temp_sig2-17t_m${MM}.a
mv fort.11  ${P}/saln_sig2-17t_m${MM}.b
mv fort.11A ${P}/saln_sig2-17t_m${MM}.a
mv fort.12  ${P}/dens_sig2-17t_m${MM}.b
mv fort.12A ${P}/dens_sig2-17t_m${MM}.a
C
C --- end of month foreach loop
C
/bin/rm $CDF_TEMP $CDF_SALN core region* z_woa*
end
C
C --- Delete all files.
C
#/bin/rm -f *
