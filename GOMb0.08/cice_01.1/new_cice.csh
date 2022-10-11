#!/bin/csh
set echo
#
# --- build new cice_ files from old.
# --- some files will need additional manual editing.
#
#  O = old experiment number
#  N = new experiment number
setenv  O 011 
setenv  N 011 

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
#setenv EO `echo ${O} | awk '{printf("cice_%04.1f", $1*0.1)}'`
setenv EO `echo ${O} | awk '{printf("expt_%04.1f", $1*0.1)}'`
setenv EN `echo ${N} | awk '{printf("cice_%04.1f", $1*0.1)}'`
setenv DO HYCOM-examples/${RO}/${EO}
setenv DN HYCOM-examples/${RN}/${EN}
#  build in ~/hycom
#setenv DO hycom/${RO}/${EO}
#setenv DN hycom/${RN}/${EN}
setenv PO ~/${DO}
setenv PN ~/${DN}
# --- create subdirectory
cd    $PN
mkdir -p PRE data

# --- set up scratch directory prefix
#  OS   = OS name (to determine the scratch dir prefix)
#  SCRN = new scratch directory prefix, must be separate from permanent path
setenv OS   Linux
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

# --- pre processing directory
cd PRE
foreach t ( preA.csh F.csh G.csh L.csh M.csh P.csh T.csh W.csh V.csh )
  sed -e "s|setenv EX .*|setenv EX ${PN}|g" -e "s|  FINC   = .*${FO}.*|  FINC   = ${FN}|g" ${PO}/PRE/${O}${t} >! ${N}${t}
end
# --- run directory
cd ..
foreach t ( .csh  pbs.csh )
  sed  -e "s|setenv EX .*|setenv EX ${PN}|g" ${PO}/${O}${t} >! ${N}${t}
end
cp ${PO}/${O}.awk_yrflag3 ${N}.awk_yrflag3
cp ${PO}/${O}.awk_yrflag4 ${N}.awk_yrflag4
cp ${PO}/${O}.awk_yrflag3 ${N}.awk
#cp ${PO}/${O}.awk_yrflag4 ${N}.awk
cp ${PO}/dummy*.csh .

#
# --- experiment run sequence:
#
setenv Y01 094
setenv YXX 094
mlist ${Y01} ${YXX} 1 a b c d e f g h i j k l
#mlist ${Y01} ${YXX} 1 a 
cp LIST LIST++

# --- create scratch directory
mkdir -p ${SCRN}/${DN}/data/
cd       ${SCRN}/${DN}/data/

# --- create forcing directory if forcing on the fly
if (${MAKE_FORCE} >= 1) then
  mkdir cice # CICE forcing files
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

cd ${PN}

# --- create EXPT.src file (define experiment environement)
setenv X `echo ${N} | awk '{printf("%04.1f", $1*0.1)}'`
cat >! EXPT.src << EOF1
# --- OS is operating system of machine
# --- R  is region name.
# --- E  is expt number (NNN).
# --- X  is expt number (NN.N).
# --- P  is primary path.
# --- D  is permanent directory.
# --- S  is scratch directory, must not be the permanent directory.
# --- DS is the datasets directory.
# --- N  is the name of the atmospheric forcing (PRE-processing).
# --- MAKE_FORCE is logical for creating forcing at run time.
# --- CICE_TYPE  is logical for CICE forcing file type (0=.r, 1=.nc)
#
setenv OS ${OS}
setenv R  ${RN}
setenv E  ${N}
setenv X  ${X}
setenv P  ${DN}/data
setenv D  ${PN}/data
setenv S  ${SCRN}/${DN}/data/
setenv DS ${DS}
setenv N  cfsr_gom
setenv W  /p/work1/$user/HYCOM-examples/datasets/${FORCING} 
setenv MAKE_FORCE ${MAKE_FORCE}
setenv CICE_TYPE  1

# --- ARCHIVE is logical for archive transfer to Newton.
# --- QSUBMIT is local submit command.
setenv ARCHIVE 0 
#setenv QSUBMIT qsub
setenv QSUBMIT ~wallcraf/bin/q_navo

#
# --- create data directories on archive:
#
#ssh newton mkdir -p /u/home/$user/${DN}/data/cice
