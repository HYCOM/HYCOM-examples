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
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.4
source ${EX}/EXPT.src

setenv N ${S}/nest
setenv DSN ${DS}/subregion
setenv TOOLS ~/HYCOM-tools/bin
#
cd   ${N}

#
setenv Y $1
setenv P $2

setenv NF `echo "LIMITS" | awk -f ${EX}/${E}.awk y01=${Y} ab=${P} | awk '{print $1-1}'`
setenv NL `echo "LIMITS" | awk -f ${EX}/${E}.awk y01=${Y} ab=${P} | awk '{print $2+3}'`
echo ${NF} ${NL}
#
echo 3 1.0 $NF $NL | hycom_archm_dates | grep "_12" >! nest_${Y}${P}.tmp
foreach ydh ( `paste -d" " -s nest_${Y}${P}.tmp` )
  if (-e  ${DSN}/archm.${ydh}.a ) then
    ln -s ${DSN}/archm.${ydh}.a archm.${ydh}.a
    ln -s ${DSN}/archm.${ydh}.b archm.${ydh}.b
  endif
end


