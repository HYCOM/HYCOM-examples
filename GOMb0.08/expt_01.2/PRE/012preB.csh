#!/bin/csh
#PBS -N 373f
#PBS -j oe
#PBS -o 373f.log
#PBS -W umask=027
#PBS -l application=hycom
#PBS -l mppwidth=8
#PBS -l mppnppn=8
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122
#PBS -q standard
#
set echo
set time = 1
set timestamp
date +"START  %c"
C
C --- EX is experiment directory
C
setenv EX ~/HYCOM-examples/GOMb0.08/expt_01.2
C
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- S is scratch   directory, must not be the permanent directory.
C --- N is data-set name, e.g. ec10m-reanal
C
source ${EX}/EXPT.src
C
C --- For whole year runs.
C ---   ymx number of years per model run.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 initial model year of this run.
C ---   YXX year at end of this part year run.
C ---   ymx is 1.
C --- Note that these variables and the .awk generating script must
C ---  be consistant to get a good run script.
C
C --- For winds, only Y01 and A are used.
C
C --- One year spin-up run.
C
C
@ ymx =  1
setenv A "a"
setenv B "b"
setenv Y01 "011"
switch ("${B}")
case "${A}":
    setenv YXX `echo $Y01 $ymx | awk '{printf("%03d", $1+$2)}'`
    breaksw
case "a":
    setenv YXX `echo $Y01 | awk '{printf("%03d", $1+1)}'`
    breaksw
default:
    setenv YXX $Y01
endsw
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}

cd ${S}/

if (-e ./mslp && ! ${MAKE_FORCE} == 0) then
C
C --- If the mslprs for the next segment does not exist,
C --- interpolate them to model grid while current segment is running.
C
  if (-e ./mslp/mslprs_${YXX}${B}.a && \
      -e ./mslp/mslprs_${YXX}${B}.b    ) then
C
C --- next segments mslprs already exists.
C
  else
    cd ./mslp
    /bin/rm -f ${E}m${YXX}${B}.csh ${E}m${YXX}${B}.log
    awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../${E}M.csh > ${E}m${YXX}${B}.csh
    csh ${E}m${YXX}${B}.csh >& ${E}m${YXX}${B}.log &
    cd ..
  endif
endif
C
if (${MAKE_FORCE} >= 1) then

C
C --- If the winds or fluxes for the next segment dont exist,
C --- interpolate them to model grid while current segment is running.
C
  if (${MAKE_FORCE} == 1 || ${MAKE_FORCE} == 3) then
    if (-e ./wvel) then
        if (-e ./wvel/wndewd_${YXX}${B}.a && \
            -e ./wvel/wndewd_${YXX}${B}.b && \
            -e ./wvel/wndnwd_${YXX}${B}.a && \
            -e ./wvel/wndnwd_${YXX}${B}.b    ) then
C
C ---     next segments wind velocities already exist.
C
        else
          cd ./wvel
          /bin/rm -f ${E}v${YXX}${B}.csh ${E}v${YXX}${B}.log
          awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}V.csh > ${E}v${YXX}${B}.csh
          csh ${E}v${YXX}${B}.csh >& ${E}v${YXX}${B}.log &
          cd ..
        endif
    endif
  endif # MAKE_FORCE == 1 or 3
  if (${MAKE_FORCE} == 2 || ${MAKE_FORCE} == 3) then
    if (-e ./wind/tauewd_${YXX}${B}.a && \
        -e ./wind/tauewd_${YXX}${B}.b && \
        -e ./wind/taunwd_${YXX}${B}.a && \
        -e ./wind/taunwd_${YXX}${B}.b    ) then
C
C --- next segments winds already exist.
C
    else
      cd ./wind
      /bin/rm -f ${E}w${YXX}${B}.csh ${E}w${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}W.csh > ${E}w${YXX}${B}.csh
      csh ${E}w${YXX}${B}.csh >& ${E}w${YXX}${B}.log &
      cd ..
    endif
    if (-e ./wspd) then
      if (-e ./wspd/wndspd_${YXX}${B}.a && \
          -e ./wspd/wndspd_${YXX}${B}.b    ) then
C
C ---   next segments wndspd already exists.
C
      else
        cd ./wspd
        /bin/rm -f ${E}s${YXX}${B}.csh ${E}s${YXX}${B}.log
        awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}S.csh > ${E}s${YXX}${B}.csh
        csh ${E}s${YXX}${B}.csh >& ${E}s${YXX}${B}.log &
        cd ..
      endif
    endif
  endif # MAKE_FORCE == 2 or 3 
  if (-e ./grad) then
    if (-e ./grad/glbrad_${YXX}${B}.a && \
        -e ./grad/glbrad_${YXX}${B}.b    ) then
C
C ---   next segments glbrad already exists.
C
    else
      cd ./grad
      /bin/rm -f ${E}g${YXX}${B}.csh ${E}g${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}G.csh > ${E}g${YXX}${B}.csh
      csh ${E}g${YXX}${B}.csh >& ${E}g${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./lrad) then
    if (-e ./lrad/lwdflx_${YXX}${B}.a && \
        -e ./lrad/lwdflx_${YXX}${B}.b    ) then
C
C ---   next segments lwdflx already exists.
C
    else
      cd ./lrad
      /bin/rm -f ${E}l${YXX}${B}.csh ${E}l${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}L.csh > ${E}l${YXX}${B}.csh
      csh ${E}l${YXX}${B}.csh >& ${E}l${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./mslp) then
    if (-e ./mslp/mslprs_${YXX}${B}.a && \
        -e ./mslp/mslprs_${YXX}${B}.b    ) then
C
C ---   next segments mslprs already exists.
C
    else
      cd ./mslp
      /bin/rm -f ${E}m${YXX}${B}.csh ${E}m${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}M.csh > ${E}m${YXX}${B}.csh
      csh ${E}m${YXX}${B}.csh >& ${E}m${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./ssta) then
    if (-e ./ssta/surtmp_${YXX}${B}.a && \
        -e ./ssta/surtmp_${YXX}${B}.b    ) then
C
C ---   next segments surtmp already exists.
C
    else
      cd ./ssta
      /bin/rm -f ${E}t${YXX}${B}.csh ${E}t${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}T.csh > ${E}t${YXX}${B}.csh
      csh ${E}t${YXX}${B}.csh >& ${E}t${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./ssto) then
    if (-e ./ssto/seatmp_${YXX}${B}.a && \
        -e ./ssto/seatmp_${YXX}${B}.b    ) then
C
C ---   next segments seatmp already exists.
C
    else
      cd ./ssto
      /bin/rm -f ${E}o${YXX}${B}.csh ${E}o${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}O.csh > ${E}o${YXX}${B}.csh
      csh ${E}o${YXX}${B}.csh >& ${E}o${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./pcip) then
    if (-e ./pcip/precip_${YXX}${B}.a && \
        -e ./pcip/precip_${YXX}${B}.b    ) then
C
C ---   next segments pcip already exists.
C
    else
      cd ./pcip
      /bin/rm -f ${E}p${YXX}${B}.csh ${E}p${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}P.csh > ${E}p${YXX}${B}.csh
      csh ${E}p${YXX}${B}.csh >& ${E}p${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./flxt) then
    if (-e ./flxt/totflx_${YXX}${B}.a && \
        -e ./flxt/totflx_${YXX}${B}.b    ) then
C
C ---   next segments flxt already exist.
C
    else
      cd ./flxt
      /bin/rm -f ${E}q${YXX}${B}.csh ${E}q${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}Q.csh > ${E}q${YXX}${B}.csh
      csh ${E}q${YXX}${B}.csh >& ${E}q${YXX}${B}.log &
      cd ..
    endif
  endif
  if (-e ./flux) then
    if (-e ./pcip) then
      touch ./flux/precip_${YXX}${B}.a
      touch ./flux/precip_${YXX}${B}.b
    endif
    if (-e ./flxt) then
      touch ./flux/radflx_${YXX}${B}.a
      touch ./flux/radflx_${YXX}${B}.b
    endif
    if (-e ./lrad) then
      touch ./flux/radflx_${YXX}${B}.a
      touch ./flux/radflx_${YXX}${B}.b
      touch ./flux/shwflx_${YXX}${B}.a
      touch ./flux/shwflx_${YXX}${B}.b
    endif
    if (-e ./flux/airtmp_${YXX}${B}.a && \
        -e ./flux/airtmp_${YXX}${B}.b && \
        -e ./flux/precip_${YXX}${B}.a && \
        -e ./flux/precip_${YXX}${B}.b && \
        -e ./flux/radflx_${YXX}${B}.a && \
        -e ./flux/radflx_${YXX}${B}.b && \
        -e ./flux/shwflx_${YXX}${B}.a && \
        -e ./flux/shwflx_${YXX}${B}.b && \
        -e ./flux/${HUM}_${YXX}${B}.a && \
        -e ./flux/${HUM}_${YXX}${B}.b    ) then
C
C ---   next segments fluxes already exist.
C
    else
      cd ./flux
      /bin/rm -f ${E}f${YXX}${B}.csh ${E}f${YXX}${B}.log
      awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}F.csh > ${E}f${YXX}${B}.csh
      csh ${E}f${YXX}${B}.csh >& ${E}f${YXX}${B}.log &
      cd ..
    endif
  endif
endif

