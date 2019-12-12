#!/bin/csh -f
#
set echo
#
# --- hardlink nested archives to montly mean archives (yrflag=3).
# --- mean archives already in the nest directory
# --- set nestfq and/or bnstfq to -30.5
#
# --- R is region
# --- E is expt number (NNN)
# --- X is expt number (NN.N)
# --- N is target nesting directory
# --- DSN is local input nesting directory
#
#
# --- EX is experiment directory
#
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.1
source ${EX}/EXPT.src

setenv N ${S}/nest
setenv DSN ${DS}/subregion
setenv TOOLS ~/HYCOM-tools/bin
#
cd   ${N}


## current year
setenv Y01 $1 
@ Y00= ${Y01} - 1
@ Y02= ${Y01} + 1

# December of previous year
setenv ydh `"" | awk -f ${D}/../nest_mon.awk y01=${Y00} ab=l | ${TOOLS}/hycom_wind_date`

   ln -s   ${DSN}/archm.1994_12_2015_12.a archm.${ydh}.a
   ln -s   ${DSN}/archm.1994_12_2015_12.b archm.${ydh}.b

# Current year
set A=(a b c d e f g h i j k l)
foreach m (01 02 03 04 05 06 07 08 09 10 11 12 )
  setenv ydh `"" | awk -f ${D}/../nest_mon.awk y01=${Y01} ab=${A[${m}]} | ${TOOLS}/hycom_wind_date`
  ln -s ${DSN}/archm.1994_${m}_2015_${m}.a archm.${ydh}.a
  ln -s ${DSN}/archm.1994_${m}_2015_${m}.b archm.${ydh}.b
end

# January of next year
setenv ydh `"" | awk -f ${D}/../nest_mon.awk y01=${Y02} ab=a | ${TOOLS}/hycom_wind_date`
   ln -s   ${DSN}/archm.1994_01_2015_01.a archm.${ydh}.a
   ln -s   ${DSN}/archm.1994_01_2015_01.b archm.${ydh}.b



