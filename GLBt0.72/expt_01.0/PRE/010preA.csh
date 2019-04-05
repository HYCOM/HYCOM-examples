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
setenv EX /p/home/abozec/HYCOM-examples/GLBt0.72/expt_01.0
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

if (-e ./mslp && ${MAKE_FORCE} == 0) then
C
C --- mslprs forcing without wind forcing.
C --- Check to see if mslprs files exist, if not make them and wait.
C
  /bin/rm -f forcing.mslprs.a
  /bin/rm -f forcing.mslprs.b
  /bin/rm -f ./mslp/${E}m${Y01}${A}
  if (-e     ./mslp/mslprs_${Y01}${A}.a && \
      -e     ./mslp/mslprs_${Y01}${A}.b    ) then
    /bin/ln  ./mslp/mslprs_${Y01}${A}.a forcing.mslprs.a
    /bin/ln  ./mslp/mslprs_${Y01}${A}.b forcing.mslprs.b
  else
    cd ./mslp
    touch ${E}m${Y01}${A}
    /bin/rm -f ${E}m${Y01}${A}.csh ${E}m${Y01}${A}.log
    awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}M.csh > ${E}m${Y01}${A}.csh
    csh ${E}m${Y01}${A}.csh >& ${E}m${Y01}${A}.log
    cd ..
    /bin/ln  ./mslp/mslprs_${Y01}${A}.a forcing.mslprs.a
    /bin/ln  ./mslp/mslprs_${Y01}${A}.b forcing.mslprs.b
  endif
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
    awk -f $D/../${E}.awk y01=${YXX} ab=${B} $D/../PRE/${E}M.csh > ${E}m${YXX}${B}.csh
    csh ${E}m${YXX}${B}.csh >& ${E}m${YXX}${B}.log &
    cd ..
  endif
endif
C
if (${MAKE_FORCE} >= 1) then

  if (! -e ./flux) then
    echo './flux must exist if MAKE_FORCE >= 1 '
    exit
  endif
  if (${MAKE_FORCE} == 1 || ${MAKE_FORCE} == 3) then
      /bin/rm -f forcing.wndewd.a forcing.wndnwd.a
      /bin/rm -f forcing.wndewd.b forcing.wndnwd.b
      /bin/rm -f ./wvel/${E}v${Y01}${A}
      if (-e     ./wvel/wndewd_${Y01}${A}.a && \
          -e     ./wvel/wndewd_${Y01}${A}.b && \
          -e     ./wvel/wndnwd_${Y01}${A}.a && \
          -e     ./wvel/wndnwd_${Y01}${A}.b    ) then
        /bin/ln  ./wvel/wndewd_${Y01}${A}.a forcing.wndewd.a
        /bin/ln  ./wvel/wndnwd_${Y01}${A}.a forcing.wndnwd.a
        /bin/ln  ./wvel/wndewd_${Y01}${A}.b forcing.wndewd.b
        /bin/ln  ./wvel/wndnwd_${Y01}${A}.b forcing.wndnwd.b
      else
        cd ./wvel
        touch ${E}v${Y01}${A}
        /bin/rm -f ${E}v${Y01}${A}.csh ${E}v${Y01}${A}.log
        awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}V.csh > ${E}v${Y01}${A}.csh
        csh ${E}v${Y01}${A}.csh >& ${E}v${Y01}${A}.log &
        cd ..
      endif
  endif
  echo ${MAKE_FORCE}
  if (${MAKE_FORCE} >= 2 ) then
C
C --- Check to see if wind and flux files exist, if not make them and wait.
C
     /bin/rm -f forcing.tauewd.a forcing.taunwd.a forcing.wndspd.a
     /bin/rm -f forcing.tauewd.b forcing.taunwd.b forcing.wndspd.b
     /bin/rm -f ./wind/${E}w${Y01}${A}
     if (-e     ./wind/tauewd_${Y01}${A}.a && \
         -e     ./wind/tauewd_${Y01}${A}.b && \
         -e     ./wind/taunwd_${Y01}${A}.a && \
         -e     ./wind/taunwd_${Y01}${A}.b    ) then
       /bin/ln  ./wind/tauewd_${Y01}${A}.a forcing.tauewd.a
       /bin/ln  ./wind/taunwd_${Y01}${A}.a forcing.taunwd.a
       /bin/ln  ./wind/tauewd_${Y01}${A}.b forcing.tauewd.b
       /bin/ln  ./wind/taunwd_${Y01}${A}.b forcing.taunwd.b
       if (-e     ./wind/wndspd_${Y01}${A}.a && \
           -e     ./wind/wndspd_${Y01}${A}.b    ) then
          /bin/ln  ./wind/wndspd_${Y01}${A}.a forcing.wndspd.a
          /bin/ln  ./wind/wndspd_${Y01}${A}.b forcing.wndspd.b
       endif
     else
       cd ./wind
       touch ${E}w${Y01}${A}
       /bin/rm -f ${E}w${Y01}${A}.csh ${E}w${Y01}${A}.log
       awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}W.csh > ${E}w${Y01}${A}.csh
       csh ${E}w${Y01}${A}.csh >& ${E}w${Y01}${A}.log &
       cd ..
     endif

     if (-e ./wspd/) then
       /bin/rm -f forcing.wndspd.a
       /bin/rm -f forcing.wndspd.b
       /bin/rm -f ./wspd/${E}s${Y01}${A}
        if (-e     ./wspd/wndspd_${Y01}${A}.a && \
            -e     ./wspd/wndspd_${Y01}${A}.b    ) then
          /bin/ln  ./wspd/wndspd_${Y01}${A}.a forcing.wndspd.a
          /bin/ln  ./wspd/wndspd_${Y01}${A}.b forcing.wndspd.b
        endif
     else
        cd ./wspd
        touch ${E}s${Y01}${A}
        /bin/rm -f ${E}s${Y01}${A}.csh ${E}s${Y01}${A}.log
        awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}S.csh > ${E}s${Y01}${A}.csh
        csh ${E}s${Y01}${A}.csh >& ${E}s${Y01}${A}.log &
        cd ..
     endif

  endif

  if (-e ./grad) then
    /bin/rm -f ./grad/${E}g${Y01}${A}
    if (-e     ./grad/glbrad_${Y01}${A}.a && \
        -e     ./grad/glbrad_${Y01}${A}.b    ) then
C
C     this segments glbrad already exists
C
      touch ./grad/${E}g${Y01}${A}
    else
      cd ./grad
      touch ${E}g${Y01}${A}
      /bin/rm -f ${E}g${Y01}${A}.csh ${E}g${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}G.csh > ${E}g${Y01}${A}.csh
      csh ${E}g${Y01}${A}.csh >& ${E}g${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./lrad) then
    /bin/rm -f forcing.radflx.a
    /bin/rm -f forcing.radflx.b
    /bin/rm -f forcing.shwflx.a
    /bin/rm -f forcing.shwflx.b
    /bin/rm -f ./lrad/${E}l${Y01}${A}
    if (-e     ./lrad/lwdflx_${Y01}${A}.a && \
        -e     ./lrad/lwdflx_${Y01}${A}.b    ) then
C
C     this segments lwdflx already exists
C
      touch ./lrad/${E}l${Y01}${A}
    else
      cd ./lrad
      touch ${E}l${Y01}${A}
      /bin/rm -f ${E}l${Y01}${A}.csh ${E}l${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}L.csh > ${E}l${Y01}${A}.csh
      csh ${E}l${Y01}${A}.csh >& ${E}l${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./mslp) then
    /bin/rm -f forcing.mslprs.a
    /bin/rm -f forcing.mslprs.b
    /bin/rm -f ./mslp/${E}m${Y01}${A}
    if (-e     ./mslp/mslprs_${Y01}${A}.a && \
        -e     ./mslp/mslprs_${Y01}${A}.b    ) then
      /bin/ln  ./mslp/mslprs_${Y01}${A}.a forcing.mslprs.a
      /bin/ln  ./mslp/mslprs_${Y01}${A}.b forcing.mslprs.b
    else
      cd ./mslp
      touch ${E}m${Y01}${A}
      /bin/rm -f ${E}m${Y01}${A}.csh ${E}m${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}M.csh > ${E}m${Y01}${A}.csh
      csh ${E}m${Y01}${A}.csh >& ${E}m${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./ssta) then
    /bin/rm -f forcing.surtmp.a
    /bin/rm -f forcing.surtmp.b
    /bin/rm -f ./ssta/${E}p${Y01}${A}
    if (-e     ./ssta/surtmp_${Y01}${A}.a && \
        -e     ./ssta/surtmp_${Y01}${A}.b    ) then
      /bin/ln  ./ssta/surtmp_${Y01}${A}.a forcing.surtmp.a
      /bin/ln  ./ssta/surtmp_${Y01}${A}.b forcing.surtmp.b
    else
      cd ./ssta
      touch ${E}t${Y01}${A}
      /bin/rm -f ${E}t${Y01}${A}.csh ${E}t${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}T.csh > ${E}t${Y01}${A}.csh
      csh ${E}t${Y01}${A}.csh >& ${E}t${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./ssto) then
    /bin/rm -f forcing.seatmp.a
    /bin/rm -f forcing.seatmp.b
    /bin/rm -f ./ssto/${E}p${Y01}${A}
    if (-e     ./ssto/seatmp_${Y01}${A}.a && \
        -e     ./ssto/seatmp_${Y01}${A}.b    ) then
      /bin/ln  ./ssto/seatmp_${Y01}${A}.a forcing.seatmp.a
      /bin/ln  ./ssto/seatmp_${Y01}${A}.b forcing.seatmp.b
    else
      cd ./ssto
      touch ${E}o${Y01}${A}
      /bin/rm -f ${E}o${Y01}${A}.csh ${E}o${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}O.csh > ${E}o${Y01}${A}.csh
      csh ${E}o${Y01}${A}.csh >& ${E}o${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./pcip) then
    /bin/rm -f forcing.precip.a
    /bin/rm -f forcing.precip.b
    /bin/rm -f ./pcip/${E}p${Y01}${A}
    if (-e     ./pcip/precip_${Y01}${A}.a && \
        -e     ./pcip/precip_${Y01}${A}.b    ) then
      /bin/ln  ./pcip/precip_${Y01}${A}.a forcing.precip.a
      /bin/ln  ./pcip/precip_${Y01}${A}.b forcing.precip.b
    else
      cd ./pcip
      touch ${E}p${Y01}${A}
      /bin/rm -f ${E}p${Y01}${A}.csh ${E}p${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}P.csh > ${E}p${Y01}${A}.csh
      csh ${E}p${Y01}${A}.csh >& ${E}p${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./flxt) then
    /bin/rm -f forcing.radflx.a
    /bin/rm -f forcing.radflx.b
    /bin/rm -f ./flxt/${E}p${Y01}${A}
    if (-e     ./flxt/totflx_${Y01}${A}.a && \
        -e     ./flxt/totflx_${Y01}${A}.b    ) then
      /bin/ln  ./flxt/totflx_${Y01}${A}.a forcing.radflx.a
      /bin/ln  ./flxt/totflx_${Y01}${A}.b forcing.radflx.b
    else
      cd ./flxt
      touch ${E}q${Y01}${A}
      /bin/rm -f ${E}p${Y01}${A}.csh ${E}p${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}Q.csh > ${E}q${Y01}${A}.csh
      csh ${E}q${Y01}${A}.csh >& ${E}q${Y01}${A}.log &
      cd ..
    endif
  endif
  if (-e ./flux) then
    /bin/rm -f forcing.airtmp.a forcing.shwflx.a forcing.${HUM}.a
    /bin/rm -f forcing.airtmp.b forcing.shwflx.b forcing.${HUM}.b
    if (! -e ./pcip) then
      /bin/rm -f forcing.precip.a
      /bin/rm -f forcing.precip.b
      touch ./flux/precip_${Y01}${A}.a
      touch ./flux/precip_${Y01}${A}.b
    endif
    if (! -e ./flxt && ! -e ./lrad) then
      /bin/rm -f forcing.radflx.a
      /bin/rm -f forcing.radflx.b
      touch ./flux/radflx_${Y01}${A}.a
      touch ./flux/radflx_${Y01}${A}.b
    endif
    if (! -e ./lrad) then
      touch ./flux/shwflx_${Y01}${A}.a
      touch ./flux/shwflx_${Y01}${A}.b
    endif
    /bin/rm -f ./flux/${E}f${Y01}${A}
    if (-e     ./flux/airtmp_${Y01}${A}.a && \
        -e     ./flux/airtmp_${Y01}${A}.b && \
        -e     ./flux/${HUM}_${Y01}${A}.a && \
        -e     ./flux/${HUM}_${Y01}${A}.b    ) then
      /bin/ln  ./flux/airtmp_${Y01}${A}.a forcing.airtmp.a
      /bin/ln  ./flux/airtmp_${Y01}${A}.b forcing.airtmp.b
      /bin/ln  ./flux/${HUM}_${Y01}${A}.a forcing.${HUM}.a
      /bin/ln  ./flux/${HUM}_${Y01}${A}.b forcing.${HUM}.b
      if (! -e ./pcip) then
        /bin/ln ./flux/precip_${Y01}${A}.b forcing.precip.b
        /bin/ln ./flux/precip_${Y01}${A}.a forcing.precip.a
      endif
      if (! -e ./flxt && ! -e ./lrad) then
        /bin/ln ./flux/radflx_${Y01}${A}.a forcing.radflx.a
        /bin/ln ./flux/radflx_${Y01}${A}.b forcing.radflx.b
      endif
      if (! -e ./lrad) then
        /bin/ln ./flux/shwflx_${Y01}${A}.a forcing.shwflx.a
        /bin/ln ./flux/shwflx_${Y01}${A}.b forcing.shwflx.b
      endif
    else
      cd ./flux
      touch ${E}f${Y01}${A}
      /bin/rm -f ${E}f${Y01}${A}.csh ${E}f${Y01}${A}.log
      awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}F.csh > ${E}f${Y01}${A}.csh
      csh ${E}f${Y01}${A}.csh >& ${E}f${Y01}${A}.log &
      cd ..
    endif
  endif
  wait
  if (-e    ./wind/${E}w${Y01}${A}) then
    /bin/ln ./wind/tauewd_${Y01}${A}.a forcing.tauewd.a
    /bin/ln ./wind/taunwd_${Y01}${A}.a forcing.taunwd.a
    /bin/ln ./wind/tauewd_${Y01}${A}.b forcing.tauewd.b
    /bin/ln ./wind/taunwd_${Y01}${A}.b forcing.taunwd.b
    if (-e    ./wind/wndspd_${Y01}${A}.a && \
        -e    ./wind/wndspd_${Y01}${A}.b    ) then
      /bin/ln ./wind/wndspd_${Y01}${A}.a forcing.wndspd.a
      /bin/ln ./wind/wndspd_${Y01}${A}.b forcing.wndspd.b
    endif
  endif
  if (-e ./wvel) then
    if (-e ./wvel/${E}v${Y01}${A}) then
      /bin/ln  ./wvel/wndewd_${Y01}${A}.a forcing.wndewd.a
      /bin/ln  ./wvel/wndnwd_${Y01}${A}.a forcing.wndnwd.a
      /bin/ln  ./wvel/wndewd_${Y01}${A}.b forcing.wndewd.b
      /bin/ln  ./wvel/wndnwd_${Y01}${A}.b forcing.wndnwd.b
      endif
    endif
  endif
  if (-e ./wspd) then
    if (-e ./wspd/${E}s${Y01}${A}) then
      /bin/ln ./wspd/wndspd_${Y01}${A}.a forcing.wndspd.a
      /bin/ln ./wspd/wndspd_${Y01}${A}.b forcing.wndspd.b
    endif
  endif
  if (-e ./ssta) then
    if (-e ./ssta/${E}t${Y01}${A}) then
      /bin/ln ./ssta/surtmp_${Y01}${A}.a forcing.surtmp.a
      /bin/ln ./ssta/surtmp_${Y01}${A}.b forcing.surtmp.b
    endif
  endif
  if (-e ./ssto) then
    if (-e ./ssto/${E}o${Y01}${A}) then
      /bin/ln ./ssto/seatmp_${Y01}${A}.a forcing.seatmp.a
      /bin/ln ./ssto/seatmp_${Y01}${A}.b forcing.seatmp.b
    endif
  endif
  if (-e ./pcip) then
    if (-e ./pcip/${E}p${Y01}${A}) then
      /bin/ln ./pcip/precip_${Y01}${A}.a forcing.precip.a
      /bin/ln ./pcip/precip_${Y01}${A}.b forcing.precip.b
    endif
  endif
  if (-e ./lrad) then
    if (-e ./grad/${E}g${Y01}${A}) then
      /bin/ln ./grad/glbrad_${Y01}${A}.a forcing.shwflx.a
      /bin/ln ./grad/glbrad_${Y01}${A}.b forcing.shwflx.b
    endif
    if (-e ./lrad/${E}l${Y01}${A}) then
      /bin/ln ./lrad/lwdflx_${Y01}${A}.a forcing.radflx.a
      /bin/ln ./lrad/lwdflx_${Y01}${A}.b forcing.radflx.b
    endif
  endif
  if (-e ./flxt) then
    if (-e ./flxt/${E}q${Y01}${A}) then
      /bin/ln ./flxt/totflx_${Y01}${A}.a forcing.radflx.a
      /bin/ln ./flxt/totflx_${Y01}${A}.b forcing.radflx.b
    endif
  endif
  if (-e ./flux) then
    if (-e    ./flux/${E}f${Y01}${A}) then
      /bin/ln ./flux/airtmp_${Y01}${A}.a forcing.airtmp.a
      /bin/ln ./flux/airtmp_${Y01}${A}.b forcing.airtmp.b
      /bin/ln ./flux/${HUM}_${Y01}${A}.a forcing.${HUM}.a
      /bin/ln ./flux/${HUM}_${Y01}${A}.b forcing.${HUM}.b
      if (! -e ./pcip) then
        /bin/ln ./flux/precip_${Y01}${A}.b forcing.precip.b
        /bin/ln ./flux/precip_${Y01}${A}.a forcing.precip.a
      endif
      if (! -e ./flxt && ! -e ./lrad) then
        /bin/ln ./flux/radflx_${Y01}${A}.a forcing.radflx.a
        /bin/ln ./flux/radflx_${Y01}${A}.b forcing.radflx.b
      endif
      if (! -e ./lrad) then
        /bin/ln ./flux/shwflx_${Y01}${A}.a forcing.shwflx.a
        /bin/ln ./flux/shwflx_${Y01}${A}.b forcing.shwflx.b
      endif
    endif
  endif

C
  if ( -e ./cice ) then
    if (-e ./cice/lwdflx_${Y01}${A}.r) then
C
C --- this segments lwdflx already exists.
C
    else
      setenv IDM `head -n 1 regional.grid.b             | sed -e "s/^  *//g" -e "s/ .*//g"`
      setenv JDM `head -n 2 regional.grid.b | tail -n 1 | sed -e "s/^  *//g" -e "s/ .*//g"`
#     JDA is CICE dimension, JDM-1 for tripole grids
      setenv JDA `expr $JDM - 1`
      cd ./cice
      switch ($OS)
      case 'XC30':
      case 'XC40':
# ---     ~/HYCOM-tools/bin is for CNL (ftn)
          setenv BINRUN "aprun -n 1"
          breaksw
      default:
          setenv BINRUN ""
      endsw
      if (-e ../lrad) then
        /bin/rm -f lwdflx_${Y01}${A}.?
        /bin/ln ../lrad/lwdflx_${Y01}${A}.a lwdflx_${Y01}${A}.A
        /bin/cp ../lrad/lwdflx_${Y01}${A}.b lwdflx_${Y01}${A}.B
      else
        /bin/rm -f lwdflx_${Y01}${A}.?
# ---   CICE: emissivity=0.95, StefanBoltzman=567.e-10, 0.95*567.e-10=538.65e-10
        ${BINRUN} ~/HYCOM-tools/bin/hycom_expr netQlw_${Y01}${A}.a surtmp4_${Y01}${A}.a ${IDM} ${JDM} 1.0 538.65e-10 lwdflx_${Y01}${A}.A >! lwdflx_${Y01}${A}.B
# ---   NWP: emissivity=1.00, StefanBoltzman=567.e-10
########${BINRUN} ~/HYCOM-tools/bin/hycom_expr netQlw_${Y01}${A}.a surtmp4_${Y01}${A}.a ${IDM} ${JDM} 1.0 567.00e-10 lwdflx_${Y01}${A}.A >! lwdflx_${Y01}${A}.B
      endif
      touch  ../forcing.offlux.a
      if (-z ../forcing.offlux.a) then
        /bin/mv -f lwdflx_${Y01}${A}.A lwdflx_${Y01}${A}.a
        /bin/mv -f lwdflx_${Y01}${A}.B lwdflx_${Y01}${A}.b
      else
# ---   add offlux to lwdflx.
        ${BINRUN} ~/HYCOM-tools/bin/hycom_expr lwdflx_${Y01}${A}.A ../forcing.offlux.a ${IDM} ${JDM} 1.0 1.0 lwdflx_${Y01}${A}.a repeat >! lwdflx_${Y01}${A}.b
      endif
      ${BINRUN} ~/HYCOM-tools/bin/hycom2raw8 lwdflx_${Y01}${A}.a ${IDM} ${JDM} 1 1 ${IDM} ${JDA} lwdflx_${Y01}${A}.r >! lwdflx_${Y01}${A}.B
      if (-e ./SAVE) then
        foreach f ( lwdflx_${Y01}${A}.[rB] )
          ln ${f} ./SAVE/${f}
        end
      endif
      cd ..
    endif
    /bin/rm -f cice/*${Y01}${A}.[Aab]
    if (-e ./grad) then
      /bin/rm -f                         cice.glbrad.r
      /bin/ln ./cice/glbrad_${Y01}${A}.r cice.glbrad.r
    else
      /bin/rm -f                         cice.netrad.r
      /bin/ln ./cice/netrad_${Y01}${A}.r cice.netrad.r
    endif
    foreach t ( airtmp lwdflx vapmix wndewd wndnwd )
      /bin/rm -f                       cice.${t}.r
      /bin/ln ./cice/${t}_${Y01}${A}.r cice.${t}.r
    end
  endif

endif
