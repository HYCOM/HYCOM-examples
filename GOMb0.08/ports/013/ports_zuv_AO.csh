#
set echo
set time=1
#
# --- Generate Real and Imag parts for Tidal response at open boundary points
# --- Lat Lon values in file  ports_latlon.input
# --- tide order must be m2,s2,k1,o1,n2,p1,k2,q1 (same as HYCOM body tides)
# --- choose either 0 or 1 for "correct for minor constituents"
#
# --- version for ATLANTIC OCEAN at 1/12 degree and OTPS 2020
# --- https://www.tpxo.net/regional
#
setenv TIDE_SRC  ~wallcraf/pkgs/OTPS
setenv TIDE_DATA ~wallcraf/pkgs/OTPS/DATA

#
date
cat ports_latlon.txt
#
date
/bin/rm -f ports_z.tmp
${TIDE_SRC}/extract_HC <<E-o-D
${TIDE_DATA}/Model_AO        ! 1. tidal model control file
ports_latlon.input           ! 2. latitude/longitude/<time> file
z                            ! 3. z/U/V/u/v
m2,s2,k1,o1,n2,p1,k2,q1      ! 4. tidal constituents to include
RI                           ! 5. AP/RI
oce                          ! 6. oce/geo
0                            ! 7. 1/0 correct for minor constituents
ports_z.tmp                  ! 8. output file (ASCII)
E-o-D
#replace OTPS 2020 header and data with original OTPSnc for HYCOM
head -n 2 ports_z.tmp >! ports_z.input
cat <<'E-o-D' >> ports_z.input
    Lat     Lon  |   m2_Re   m2_Im   s2_Re   s2_Im   k1_Re   k1_Im   o1_Re   o1_Im   n2_Re   n2_Im   p1_Re   p1_Im   k2_Re   k2_Im   q1_Re   q1_Im
'E-o-D'
tail -n +4 ports_z.tmp | cut -c 1-9,11-19,21-28,30-37,39-46,48-55,57-64,66-73,75-82,84-91,93-100,102-109,111-118,120-127,129-136,138-145,147-154,156-163 >> ports_z.input
#/bin/rm -f ports_z.tmp
date
#
/bin/rm -f ports_u.tmp  
${TIDE_SRC}/extract_HC <<E-o-D
${TIDE_DATA}/Model_AO        ! 1. tidal model control file
ports_latlon.input           ! 2. latitude/longitude/<time> file
u                            ! 3. z/U/V/u/v
m2,s2,k1,o1,n2,p1,k2,q1      ! 4. tidal constituents to include
RI                           ! 5. AP/RI
oce                          ! 6. oce/geo
0                            ! 7. 1/0 correct for minor constituents
ports_u.tmp                  ! 8. output file (ASCII)
E-o-D
#replace OTPS 2020 header and data with original OTPSnc for HYCOM
head -n 2 ports_u.tmp >! ports_u.input
cat <<'E-o-D' >> ports_u.input
    Lat     Lon  |   m2_Re   m2_Im   s2_Re   s2_Im   k1_Re   k1_Im   o1_Re   o1_Im   n2_Re   n2_Im   p1_Re   p1_Im   k2_Re   k2_Im   q1_Re   q1_Im
'E-o-D'
tail -n +4 ports_u.tmp | cut -c 1-9,11-19,21-28,30-37,39-46,48-55,57-64,66-73,75-82,84-91,93-100,102-109,111-118,120-127,129-136,138-145,147-154,156-163 >> ports_u.input
#/bin/rm -f ports_u.tmp
date
/bin/rm -f ports_v.tmp  
${TIDE_SRC}/extract_HC <<E-o-D
${TIDE_DATA}/Model_AO        ! 1. tidal model control file
ports_latlon.input           ! 2. latitude/longitude/<time> file
v                            ! 3. z/U/V/u/v
m2,s2,k1,o1,n2,p1,k2,q1      ! 4. tidal constituents to include
RI                           ! 5. AP/RI
oce                          ! 6. oce/geo
0                            ! 7. 1/0 correct for minor constituents
ports_v.tmp                  ! 8. output file (ASCII)
E-o-D
#replace OTPS 2020 header and data with original OTPSnc for HYCOM
head -n 2 ports_v.tmp >! ports_v.input
cat <<'E-o-D' >> ports_v.input
    Lat     Lon  |   m2_Re   m2_Im   s2_Re   s2_Im   k1_Re   k1_Im   o1_Re   o1_Im   n2_Re   n2_Im   p1_Re   p1_Im   k2_Re   k2_Im   q1_Re   q1_Im
'E-o-D'
tail -n +4 ports_v.tmp | cut -c 1-9,11-19,21-28,30-37,39-46,48-55,57-64,66-73,75-82,84-91,93-100,102-109,111-118,120-127,129-136,138-145,147-154,156-163 >> ports_v.input
#/bin/rm -f ports_v.tmp
date
#
# --- check for bad locations
# --- cut does not impact Site on error lines
#
grep "Site" ports_[uvz].input
