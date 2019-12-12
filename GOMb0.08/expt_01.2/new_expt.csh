#!/bin/csh
set echo
#
# --- build new expt files from old.
# --- some files will need additional manual editing.
#
#  O = old experiment number
#  N = new experiment number
setenv  O 011 
setenv  N 012 

#  RO = old region name.
#  RN = region name.
setenv  RO GOMb0.08
setenv  RN ${RO}

#  EO = old experiment directory
#  EN = new experiment directory 
#  DO = path to old directory 
#  DN = path to new directory
#  PO = permanent old path directory 
#  PN = permanent new path directory
setenv EO `echo ${O} | awk '{printf("expt_%04.1f", $1*0.1)}'`
setenv EN `echo ${N} | awk '{printf("expt_%04.1f", $1*0.1)}'`
setenv DO HYCOM-examples/${RO}/${EO}
setenv DN HYCOM-examples/${RN}/${EN}
#  build in ~/hycom
#setenv DO hycom/${RO}/${EO}
#setenv DN hycom/${RN}/${EN}
setenv PO ~/${DO}
setenv PN ~/${DN}
# --- create subdirectory
cd    $PN
mkdir -p PRE POST data

# --- set up scratch directory prefix
#  OS   = OS name (to determine the scratch dir prefix)
#  SCRN = new scratch directory prefix, must be separate from permanent path
setenv OS   HPE
## --- single disk case
#setenv SCRN ${PN}/../../scratch
#setenv SCRN ~/scratch
# --- separate scratch disk
#setenv SCRN /work/${user}
#setenv SCRN /scr/${user}
#setenv SCRN /gpfs/work/${user}
setenv SCRN /p/work1/${user}

#  DS = datasets directory, can be on scratch (typically $RN or $RN/datasets)
#setenv DS       ~/${DN}/..
#setenv DS       ~/${DN}/../datasets
setenv DS ${SCRN}/${DN}/../datasets

# --- forcing 
# MAKE_FORCE = create forcing at run time (0-no, 1-u10/v10, 2-stress, 3-u10/v10+stress)
# FORCING = name of forcing directory (if MAKE_FORCE >=1 ; if not change FN in ${N}.csh)
# FO = old forcing frequency 
# FN = new forcing frequency
setenv MAKE_FORCE 1
setenv FORCING CFSR_GOM
setenv FO 0.04166667
setenv FN 0.04166667

if (${MAKE_FORCE} < 0 || ${MAKE_FORCE} >= 4) then
  echo 'MAKE_FORCE bad value, should be between 0 and 3'
  exit 
endif

# --- post processing directory
cd POST
foreach t (Am.csh Ac.csh As.csh Ae.csh Ac_rcp.csh Am_rcp.csh As_rcp.csh)
  sed -e "s|setenv EX .*|setenv EX ${PN}|g" ${PO}/POST/${O}${t} >! ${N}${t}
end
# --- pre processing directory
cd ../PRE
foreach t ( preA.csh preB.csh F.csh G.csh L.csh M.csh P.csh T.csh W.csh V.csh )
  sed -e "s|setenv EX .*|setenv EX ${PN}|g" -e "s|  FINC   = .*${FO}.*|  FINC   = ${FN}|g" ${PO}/PRE/${O}${t} >! ${N}${t}
end
# --- run directory
cd ..
foreach t ( .csh  pbs.csh _nest_link.csh)
  sed  -e "s|setenv EX .*|setenv EX ${PN}|g" ${PO}/${O}${t} >! ${N}${t}
end
cp ${PO}/${O}.awk_yrflag3 ${N}.awk_yrflag3
cp ${PO}/${O}.awk_yrflag4 ${N}.awk_yrflag4
cp ${PO}/nest_mon.awk nest_mon.awk
cp ${PO}/ice_in*    .
cp ${PO}/dummy*.csh .
cp ${PO}/blkdat.input* ${PO}/ports.input* ${PO}/tracer.input* .
cp ${PO}/archs.input .
printf "%ds/${O}/${N}/g\n" {6} | sed -f - ${PO}/blkdat.input >! test.tmp

# --- yrflag and calendar
setenv YRFLAG `grep yrflag blkdat.input | awk '{print $1}'`
setenv LN     `grep -n yrflag blkdat.input | awk '{print $1}' | rev |cut -c 2- | rev`
if (${MAKE_FORCE} == 0 ) then
  printf "%ds/${YRFLAG}/4/g\n" {${LN}} | sed -f - test.tmp >! blkdat.input
  cp ${PO}/${O}.awk_yrflag4 ${N}.awk
else
  printf "%ds/${YRFLAG}/3/g\n" {${LN}} | sed -f - test.tmp >! blkdat.input
  cp ${PO}/${O}.awk_yrflag3 ${N}.awk
endif
/bin/rm test.tmp

#
# --- experiment run sequence:
#
setenv Y01 094
setenv YXX 094
mlist ${Y01} ${YXX} 1 a b c d e f g h i j k l
#mlist ${Y01} ${YXX} 1 a 
cp LIST LIST++
setenv day1 `echo "LIMITS" | awk -f ${N}.awk y01=${Y01} ab=a | awk '{print $1}'`
setenv day2 `echo "LIMITS" | awk -f ${N}.awk y01=${Y01} ab=a | awk '{print $2}'`
#setenv restart -  ## - means no restart (+ means restart)
setenv restart +  ## - means no restart (+ means restart)
cat >! ${N}y${Y01}a.limits <<EOF
${restart}${day1}  ${day2}
EOF

# --- create scratch directory
mkdir -p ${SCRN}/${DN}/data/
cd       ${SCRN}/${DN}/data/

# --- create forcing directory if forcing on the fly
if (${MAKE_FORCE} >= 1) then
  mkdir flux # airtmp vapmix or spchum 
  mkdir pcip # precip
  mkdir lrad # longwave down
  mkdir grad # shortwave down
  #mkdir ssta # surface temperature
  mkdir mslp # surface pressure
  switch (${MAKE_FORCE})
    case '1': 
       mkdir wvel  # u10-v10 wind
       breaksw
    case '2': 
       mkdir wind  # wind-stress
       breaksw
    case '3': 
       mkdir wind wvel # wind-stress and u10-v10
       breaksw
  endsw
endif
mkdir nest

# --- create relax directory
cd ${DS}/relax/
ln -s ${O} ${N}

cd ${PN}

# --- create EXPT.src file (define experiment environement)
setenv X `echo ${N} | awk '{printf("%04.1f", $1*0.1)}'`
cat >! EXPT.src << EOF1
# --- OS is operating system of machine
# --- R  is region name.
# --- V  is source code version number.
# --- T  is topography number.
# --- K  is number of layers.
# --- E  is expt number (NNN).
# --- X  is expt number (NN.N).
# --- P  is primary path.
# --- D  is permanent directory.
# --- S  is scratch directory, must not be the permanent directory.
# --- DS is the datasets directory.
# --- N  is the name of the atmospheric forcing (PRE-processing).
# --- MAKE_FORCE is logical for creating forcing at run time.
#
setenv OS ${OS}
setenv R  ${RN}
setenv V  2.3.01
setenv T  07
setenv K  41 
setenv E  ${N}
setenv X  ${X}
setenv P  ${DN}/data
setenv D  ${PN}/data
setenv S  ${SCRN}/${DN}/data/
setenv DS ${DS}
setenv N  cfsr_gom
setenv W  /p/work1/abozec/HYCOM-examples/datasets/${FORCING} 
setenv MAKE_FORCE ${MAKE_FORCE}

# --- ARCHIVE is logical for archive transfer to Newton.
# --- QSUBMIT is local submit command.
setenv ARCHIVE 0 
#setenv QSUBMIT qsub
setenv QSUBMIT ~wallcraf/bin/q_navo

# --- mnsqa  is logical for postproc mean and std deviation arch.
# --- mnsqe  is logical for postproc mean and std deviation arche.
# --- statm  is logical for postproc basin-wide statistics from daily means.
# --- plots  is logical for postproc plots.
# --- transp is logical for postproc sample transports.
# --- data2d is logical for postproc data2d extraction.
# --- netcdf is logical for postproc conversion to netCDF.
#
setenv mnsqa 1
setenv mnsqe 0
setenv statm 1
setenv plots 0
setenv transp 0
setenv data2d 0
setenv netcdf 1 
EOF1

#
# --- create data directories on archive:
#
#ssh newton mkdir -p /u/home/$user/${DN}/data
#ssh newton mkdir -p /u/home/$user/${DN}/data/skill
#ssh newton mkdir -p /u/home/$user/${DN}/data/data2d
#ssh newton mkdir -p /u/home/$user/${DN}/data/profiles
#ssh newton mkdir -p /u/home/$user/${DN}/data/movie
#
# --- softlink relax directory to a previous case if appropriate
#ln -s ${DS}/relax/021 ${DS}/relax/${N}
#ssh newton ln -s "021" /u/home/${user}/${DN}/../relax/$N
