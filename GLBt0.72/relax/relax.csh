#!/bin/csh
#@$-lt 0:04:00
#@$-lT 0:04:00
#@$-lm 4mw
#@$-lM 4mw
#@$-s  /bin/csh
#@$
#
set echo
set time = 1
C
C --- Convert z-level climatology to HYCOM layers.
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
C --- TOOLS is path to tools directory
C --- SP    is scratch prefix
C --- R     is region identifier
C --- DSR   is path to non specific domain datasets
C --- DS    is path to specific domain datasets
C --- E is experiment number
C --- T is topography number
C
source EXPT.src

C
C --- X is experiment number, decimal i.e., E=010,X=01.0
C --- P is primary path
C --- S is scratch directory
C --- D is permanent directory
C
setenv X `echo ${E} | awk '{printf("%04.1f", $1*0.1)}'` 
setenv D ${DS}/relax/WOA13
setenv P ${DS}/relax/${E}
setenv S ${P}/SCRATCH
setenv B ${PWD} 
C
C
mkdir -p $S
cd       $S
C
touch   relaxi blkdat.input fort.51 fort.51A fort.52 fort.52A
/bin/rm relaxi blkdat.input fort.51 fort.51A fort.52 fort.52A
C
C --- 12 months
C
foreach MM ( 01 02 03 04 05 06 07 08 09 10 11 12 )
C
C --- Input.
C
touch      fort.72 fort.72A fort.73 fort.73A
/bin/rm -f fort.72 fort.72A fort.73 fort.73A
${pget} ${D}/saln_sig2-17t_m${MM}.b fort.73  &
${pget} ${D}/saln_sig2-17t_m${MM}.a fort.73A &
${pget} ${D}/temp_sig2-17t_m${MM}.b fort.72  &
${pget} ${D}/temp_sig2-17t_m${MM}.a fort.72A &

C
C --- get grid and bathymetry
C
touch fort.51 fort.51A
if (-z fort.51) then
  ${pget} ${DS}/topo/depth_${R}_${T}.b fort.51  &
endif
if (-z fort.51A) then
  ${pget} ${DS}/topo/depth_${R}_${T}.a fort.51A &
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
C --- get iso_sigma
C
touch fort.52 fort.52A
if (-z fort.52) then
  ${pget} ${P}/iso_sigma.b fort.52 &
endif
if (-z fort.52A) then
  ${pget} ${P}/iso_sigma.a fort.52A &
endif

C
C --- get blkdat.input
C
touch blkdat.input
if (-z blkdat.input) then
  ${pget} ${B}/blkdat.input blkdat.input &
endif
C
C --- get executable
C
touch relaxi
if (-z relaxi) then
  ${pget} ${TOOLS}/relax/src/relaxi . &
endif
wait
chmod a+rx relaxi
C
sed -e "s/^[ 	0-9]*'month ' =/  ${MM}	  'month ' =/" blkdat.input >! fort.99
C
/bin/rm -f core
     touch core

C
C --- set up input/output
C
setenv FOR010A fort.10A
setenv FOR011A fort.11A
setenv FOR012A fort.12A
setenv FOR021A fort.21A
setenv FOR051A fort.51A
setenv FOR052A fort.52A
setenv FOR072A fort.72A
setenv FOR073A fort.73A
/bin/rm -f fort.10  fort.11  fort.12  fort.21
/bin/rm -f fort.10A fort.11A fort.12A fort.21A
C
./relaxi
C
C --- Output.
C
mv fort.10  relax_tem_m${MM}.b
mv fort.10A relax_tem_m${MM}.a
mv fort.11  relax_sal_m${MM}.b
mv fort.11A relax_sal_m${MM}.a
mv fort.12  relax_int_m${MM}.b
mv fort.12A relax_int_m${MM}.a
C
#setenv DAYM `echo ${MM} | awk '{printf("0000_%3.3d_00\n",30*($1-1)+16)}'`
setenv DAYM `echo ${MM} | awk '{printf("0000_%3.3d_00\n",30.5*($1-1)+16)}'`
#setenv DAYM `echo ${MM} | awk '{printf("0000_%3.3d_00\n",30.5*($1-1)+1)}'`
mv fort.21  relax.${DAYM}.b
mv fort.21A relax.${DAYM}.a
C
C --- end of month foreach loop
C
/bin/rm fort.7[12]
end
#
# --- Merge monthly climatologies into one file.
#
cp relax_int_m01.b relax_int.b
cp relax_sal_m01.b relax_sal.b
cp relax_tem_m01.b relax_tem.b
#
foreach MM ( 02 03 04 05 06 07 08 09 10 11 12 )
  tail -n +6 relax_int_m${MM}.b >> relax_int.b
  tail -n +6 relax_sal_m${MM}.b >> relax_sal.b
  tail -n +6 relax_tem_m${MM}.b >> relax_tem.b
end
#
cp relax_int_m01.a relax_int.a
cp relax_sal_m01.a relax_sal.a
cp relax_tem_m01.a relax_tem.a
#
foreach MM ( 02 03 04 05 06 07 08 09 10 11 12 )
  cat relax_int_m${MM}.a >> relax_int.a
  cat relax_sal_m${MM}.a >> relax_sal.a
  cat relax_tem_m${MM}.a >> relax_tem.a
end
${pput} relax_int.b ${S}/../relax_int.b
${pput} relax_int.a ${S}/../relax_int.a
${pput} relax_sal.b ${S}/../relax_sal.b
${pput} relax_sal.a ${S}/../relax_sal.a
${pput} relax_tem.b ${S}/../relax_tem.b
${pput} relax_tem.a ${S}/../relax_tem.a
C
C --- delete the monthly files
C
/bin/rm relax_int_m??.[ab]
/bin/rm relax_sal_m??.[ab]
/bin/rm relax_tem_m??.[ab]
C
C --- Delete all scratch directory files.
C
/bin/rm -f *
