#! /bin/csh -x
#
# --- check that the C comment command is available.
#
C >& /dev/null
if (! $status) then
  if (-e ${home}/HYCOM-tools/bin/C) then
    set path = ( ${path} ${home}/HYCOM-tools/bin )
  else
    echo "Please put the command HYCOM-tools/bin/C in your path"
  endif
endif
#
set echo
set time = 1
set timestamp
C
C --- Experiment GOMb0.08 - 01.0 series
C --- 41 layer sig2star HYCOM on 0.08 degree Gulf of Mexico region
C --- 01.0 - No winds, 1 day run for template restart
C --- 01.1 - nested inside   GLBb0.08 53.X daily
C ---        Initialize from GLBb0.08 53.X at mean archive 1994_01.
C ---        No offlux, chl turbidity.
C ---        17-term equation of state, 2.3.00
C ---        Use WOA13 for SSS relaxation.
C ---        depth_GOMb0.08_07.
C ---        1 year to get Montgomery Potential correction
C --- 01.2 - twin of 01.1 with Montgomery correction from 1 year of 01.1

C --- EX is experiment directory, required because batch systems often start scripts in home
C
setenv EX /p/home/${user}/HYCOM-examples/GOMb0.08/expt_01.2
C
C --- Preamble, defined in EXPT.src
C
C --- OS is operating system of machine
C --- R is region name.
C --- V is source code version number.
C --- T is topography number.
C --- K is number of layers.
C --- E is expt number.
C --- P is primary path.
C --- D is permanent directory.
C --- SCR is the scratch directory prefix.
C --- S is scratch directory, must not be the permanent directory.
C --- DS is the datasets directory.
C --- MAKE_FORCE is logical for creating forcing at run time.
C --- N is the name of the atmospheric forcing for PRE-processing.
C
source ${EX}/EXPT.src
C
C --- Set parallel configuration, see ../README/README.expt_parallel.
C --- NOMP = number of OpenMP threads, 0 for no OpenMP, 1 for inactive OpenMP
C --- NMPI = number of MPI    tasks,   0 for no MPI
C
switch ($OS)
case 'Linux':
  setenv NOMP 0
  setenv NMPI 30
  breaksw
case 'HPE':
  unset echo
  module purge
  module load costinit
  module load compiler/intel/2017.4.196
  module load mpt/2.17
  module list
  set echo
  setenv NOMP 0
  setenv NMPI 47
  breaksw
case 'IDP':
  module swap mpi mpi/intel/impi/4.1.0
  module load mkl
  module list
  setenv NOMP 0
  setenv NMPI 30
  breaksw
case 'ICE': 
  lfs setstripe    $S -S 1048576 -i -1 -c 8
  setenv NOMP 0
  setenv NMPI 30
  breaksw
case 'XC30':
#  lfs setstripe    $S -S 1048576 -i -1 -c 24
  lfs setstripe    $S -S 1048576 -i -1 -c  8
  setenv NOMP 0
  setenv NMPI 47
  breaksw
case 'XC40':
#  lfs setstripe    $S -S 1048576 -i -1 -c 24
  lfs setstripe    $S -S 1048576 -i -1 -c  8
#  lfs setstripe    $S -S 1048576 -i -1 -c 48
  setenv NOMP 0
  setenv NMPI 61
  breaksw
case 'SHASTA':
  unset echo
  module -s swap PrgEnv-cray PrgEnv-intel
  module -s use --append /p/app/modulefiles
# cray-mpich/8.1.[12] do not work
  module -s swap cray-mpich/8.1.4
  module list
  set echo
  setenv NOMP 0
  setenv NMPI 122 
  breaksw
case 'AIX':
  if      (-e /gpfs/work) then
#     ERDC MSRC, under PBS
      setenv POE  pbspoe
  else if (-e /scr) then
#     NAVO MSRC, under LoadLeveler or LSF
    if ($?LSB_JOBINDEX) then
       setenv POE mpirun.lsf
    else
       setenv POE poe
    endif
  else
#     ARL MSRC, under GRD
      setenv POE  grd_poe
  endif
  setenv NOMP 0
  setenv NMPI 30
  breaksw
default:
    echo 'Unknown Operating System: ' $OS
    exit (1)
endsw
C
C --- get to the scratch directory
C
mkdir -p $S
cd       $S
C
C --- For whole year runs.
C ---   Y01 initial model year of this run.
C ---   YXX is the last model year of this run, and the first of the next run.
C ---   A and B are identical, typically blank.
C --- For part year runs.
C ---   A is this part of the year, B is next part of the year.
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- For a few hour/day run
C ---   A   is the start day and hour, of form "dDDDhHH".
C ---   B   is the end   day and hour, of form "dXXXhYY".
C ---   Y01 is the start model year of this run.
C ---   YXX is the end   model year of this run, usually Y01.
C --- Note that these variables are set by the .awk generating script.
C
setenv A "a"
setenv B "b"
setenv Y01 "094"
setenv YXX "094"
setenv YOF `echo ${Y01} | awk '{printf("%04.0f", $1+1900)}'`
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}

C --- annual offset, if needed
C
setenv YOF ""
#setenv YOF `echo ${Y01} | awk '{printf("%04.0f", $1+1900)}'`
C
C --- local input files.
C
if (-e    ${D}/../${E}y${Y01}${A}.limits) then
  /bin/cp ${D}/../${E}y${Y01}${A}.limits limits
else
#  use "LIMITI"  when starting a run after day zero.
#  use "LIMITS9" (say) for a 9-day run
  echo "LIMITS" | awk -f ${D}/../${E}.awk y01=${Y01} ab=${A} >! limits
endif
cat limits
C
if (-e    ${D}/../ports.input_${Y01}${A}) then
  /bin/cp ${D}/../ports.input_${Y01}${A} ports.input
else
  /bin/cp ${D}/../ports.input ports.input
endif
C
if (-e    ${D}/../tracer.input_${Y01}${A}) then
  /bin/cp ${D}/../tracer.input_${Y01}${A} tracer.input
else
  /bin/cp ${D}/../tracer.input tracer.input
endif
C
if (-e    ${D}/../blkdat.input_${Y01}${A}) then
  /bin/cp ${D}/../blkdat.input_${Y01}${A} blkdat.input
else
  /bin/cp ${D}/../blkdat.input blkdat.input
endif
C
if (-e      ${D}/../archs.input_${Y01}${A}) then
  /bin/cp   ${D}/../archs.input_${Y01}${A} archs.input
else if (-e ${D}/../archs.input) then
  /bin/cp   ${D}/../archs.input archs.input
endif
C
if (-e      ${D}/../profile.input_${Y01}${A}) then
  /bin/cp   ${D}/../profile.input_${Y01}${A} profile.input
else if (-e ${D}/../profile.input) then
  /bin/cp   ${D}/../profile.input profile.input
else
  touch profile.input
endif
if (! -z profile.input) then
  if (-e       ./ARCHP) then
    /bin/mv -f ./ARCHP ./ARCHP_$$
  endif
  mkdir        ./ARCHP
endif
C
if (-e ./cice) then
  touch   PET0.ESMF_LogFile
  /bin/rm -f  *ESMF_LogFile
  if (-e    ${D}/../ice_in_${Y01}${A}) then
    /bin/cp ${D}/../ice_in_${Y01}${A} ice_in
  else
    /bin/cp ${D}/../ice_in ice_in
  endif
endif
if ($NMPI != 0) then
# setenv NPATCH `echo $NMPI | awk '{printf("%04d", $1)}'`
  setenv NPATCH `echo $NMPI | awk '{printf("%03d", $1)}'`
  /bin/rm -f patch.input
  /bin/cp ${DS}/topo/partit/depth_${R}_${T}.${NPATCH}s8 patch.input
C
  /bin/rm -f archt.input
  if (-e      ${D}/../archt.input_${Y01}${A}) then
    /bin/cp   ${D}/../archt.input_${Y01}${A} archt.input
  else if (-e ${D}/../archt.input) then
    /bin/cp   ${D}/../archt.input archt.input
  else
    touch archt.input
  endif
  if (! -z archt.input) then
    if (-e       ./ARCHT) then
      /bin/mv -f ./ARCHT ./ARCHT_$$
    endif
    mkdir ./ARCHT
    switch ($OS)
    case 'ICE':
      lfs setstripe ./ARCHT -S 1048576 -i -1 -c 8
      breaksw
    case 'XC30':
      lfs setstripe ./ARCHT -S 1048576 -i -1 -c  8
#     lfs setstripe ./ARCHT -S 1048576 -i -1 -c 24
      breaksw
    case 'XC40':
      lfs setstripe ./ARCHT -S 1048576 -i -1 -c  8
#     lfs setstripe ./ARCHT -S 1048576 -i -1 -c 24
#     lfs setstripe ./ARCHT -S 1048576 -i -1 -c 48
      breaksw
    endsw
    cd    ./ARCHT
    /bin/cp ../archt.input  .
    /bin/cp ../patch.input  .
    /bin/ln ../regional.*.? .
    ${home}/HYCOM-tools/topo/src/topo_subset < archt.input
    cat patch.subreg | xargs mkdir
    /bin/rm -f regional.*.?
    cd ..
  endif
endif
C
C --- check that iexpt from blkdat.input agrees with E from this script.
C
setenv EB `grep "'iexpt ' =" blk* | awk '{printf("%03d", $1)}'`
if ($EB != $E) then
  cd $D/..
  /bin/mv -f LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
#C
#C --- turn on detailed debugging.
#C
#touch PIPE_DEBUG
C
C --- pget, pput "copy" files between scratch and permanent storage.
C --- Can both be cp if the permanent filesystem is mounted locally.
C
switch ($OS)
case 'AIX':
case 'unicos':
case 'HPE':      
case 'SHASTA':
case 'ICE':      
case 'IDP':
case 'XC30':
case 'XC40':
    if      (-e   ~${user}/bin/pget_navo) then
      setenv pget ~${user}/bin/pget_navo
      setenv pput ~${user}/bin/pput_navo
    else if (-e   ~${user}/bin/pget) then
      setenv pget ~${user}/bin/pget
      setenv pput ~${user}/bin/pput
    else
      setenv pget /bin/cp
      setenv pput /bin/cp
    endif
    breaksw
default:
    setenv pget /bin/cp
    setenv pput /bin/cp
endsw
C
C --- input files from file server.
C
touch regional.depth.a regional.depth.b
if (-z regional.depth.a) then
   ${pget} ${DS}/topo/depth_${R}_${T}.a regional.depth.a &
endif
if (-z regional.depth.b) then
   ${pget} ${DS}/topo/depth_${R}_${T}.b regional.depth.b &
endif
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.a) then
   ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
if (-z regional.grid.b) then
   ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-e ./cice) then
C
C --- CICE non-synoptic files.
C
  touch  regional.cice.r cice.prec_lanl_12.r cice.rhoa_ncar85-88_12.r
  if (-z regional.cice.r) then
     ${pget} ${DS}/topo/regional.cice_${T}.r regional.cice.r &
  endif
  if (-z cice.prec_lanl_12.r) then
#    ${pget} ${DS}/force/cice/cice.prec_lanl_12.r cice.prec_lanl_12.r &
     ${pget} ${DS}/force/cice/pre_gpcp.r cice.prec_lanl_12.r &
#    ${pget} ${DS}/force/cice/pre_ncar.r cice.prec_lanl_12.r &
  endif
  if (-z cice.rhoa_ncar85-88_12.r) then
#    ${pget} ${DS}/force/cice/cice.rhoa_ncar85-88_12.r cice.rhoa_ncar85-88_12.r &
     ${pget} ${DS}/force/cice/rho_constant.r cice.rhoa_ncar85-88_12.r &
  endif
endif
C
C --- vapmix or spchum
C
setenv flxflg `grep flxflg ${D}/../blkdat.input | awk '{print $1}'`
if  ( $flxflg != 5 ) then
  setenv HUM vapmix
else
  setenv HUM spchum 
endif
C
if (${MAKE_FORCE} == 0) then
C
C --- Climatological atmospheric forcing.
C
  setenv FN CORE2_NYF_6hr 
  touch forcing.wndewd.a forcing.wndnwd.a 
  touch forcing.radflx.a forcing.shwflx.a forcing.${HUM}.a forcing.precip.a
  touch forcing.airtmp.a forcing.seatmp.a forcing.surtmp.a
  touch forcing.wndewd.b forcing.wndnwd.b forcing.wndspd.b
  touch forcing.radflx.b forcing.shwflx.b forcing.${HUM}.b forcing.precip.b
  touch forcing.airtmp.b forcing.seatmp.b forcing.surtmp.b
  if (-z forcing.wndewd.a) then
     ${pget} ${DS}/force/${FN}/wndewd.a      forcing.wndewd.a &
  endif
  if (-z forcing.wndewd.b) then
     ${pget} ${DS}/force/${FN}/wndewd.b      forcing.wndewd.b &
  endif
  if (-z forcing.wndnwd.a) then
     ${pget} ${DS}/force/${FN}/wndnwd.a      forcing.wndnwd.a &
  endif
  if (-z forcing.wndnwd.b) then
     ${pget} ${DS}/force/${FN}/wndnwd.b      forcing.wndnwd.b &
  endif
#  if (-z forcing.wndspd.a) then
#     ${pget} ${DS}/force/${FN}/wndspd.a      forcing.wndspd.a &
#  endif
#  if (-z forcing.wndspd.b) then
#     ${pget} ${DS}/force/${FN}/wndspd.b      forcing.wndspd.b &
#  endif
  if (-z forcing.${HUM}.a) then
     ${pget} ${DS}/force/${FN}/${HUM}.a      forcing.${HUM}.a &
  endif
  if (-z forcing.${HUM}.b) then
     ${pget} ${DS}/force/${FN}/${HUM}.b      forcing.${HUM}.b &
  endif
  setenv AO ""
# setenv AO "_037c"
  if (-z forcing.airtmp.a) then
     ${pget} ${DS}/force/${FN}/airtmp${AO}.a forcing.airtmp.a &
  endif
  if (-z forcing.airtmp.b) then
     ${pget} ${DS}/force/${FN}/airtmp${AO}.b forcing.airtmp.b &
  endif
  setenv PO ""
# setenv PO "-regress-gpcp"
# setenv PO "_zero"
  if (-z forcing.precip.a) then
     ${pget} ${DS}/force/${FN}/precip${PO}.a forcing.precip.a &
  endif
  if (-z forcing.precip.b) then
     ${pget} ${DS}/force/${FN}/precip${PO}.b forcing.precip.b &
  endif
  setenv FO ""
# setenv FO "-regress-isccp_fd"
## with CORE forcing, we use longwave down and shortwave down (lwflag=-1)
  if (-z forcing.radflx.a) then
     ${pget} ${DS}/force/${FN}/lwdflx${FO}.a forcing.radflx.a &
  endif
  if (-z forcing.radflx.b) then
     ${pget} ${DS}/force/${FN}/lwdflx${FO}.b forcing.radflx.b &
  endif
  if (-z forcing.shwflx.a) then
     ${pget} ${DS}/force/${FN}/swdflx${FO}.a forcing.shwflx.a &
  endif
  if (-z forcing.shwflx.b) then
     ${pget} ${DS}/force/${FN}/swdflx${FO}.b forcing.shwflx.b &
  endif
# if (-z forcing.surtmp.a) then
#    ${pget} ${DS}/force/${FN}/surtmp.a      forcing.surtmp.a &
# endif
# if (-z forcing.surtmp.b) then
#    ${pget} ${DS}/force/${FN}/surtmp.b      forcing.surtmp.b &
# endif
  setenv FS ""
# setenv FS $FN
# setenv FS PF_SST-mn6hr
# setenv FS RS_SST-mn6hr
# setenv FS NOAA_OISST-mn6hr
  if ($FS != "") then
    if (-z forcing.seatmp.a) then
       ${pget} ${DS}/force/${FS}/seatmp.a      forcing.seatmp.a &
    endif
    if (-z forcing.seatmp.b) then
       ${pget} ${DS}/force/${FS}/seatmp.b      forcing.seatmp.b &
    endif
  endif
endif
C
C --- time-invarent wind stress offset
C
#setenv OFS "_era40-nogaps"
setenv OFS ""
if   ($OFS != "") then
  touch  forcing.ofstrs.a
  touch  forcing.ofstrs.b
  if (-z forcing.ofstrs.a) then
     ${pget} ${DS}/force/offset/ofstrs${OFS}.a forcing.ofstrs.a &
  endif
  if (-z forcing.ofstrs.b) then
     ${pget} ${DS}/force/offset/ofstrs${OFS}.b forcing.ofstrs.b &
  endif
endif
C
if ($YOF != "") then
C
C --- annual heat flux offset, pre-positioned offlux files
C
# setenv OFF "_153"
  setenv OFF ""
  if   ($OFF != "") then
    touch offlux${OFF}*
    /bin/rm forcing.offlux.a forcing.offlux.b
    touch   forcing.offlux.a forcing.offlux.b
    if (-z  forcing.offlux.a) then
      ln -f ./offlux${OFF}_${YOF}_${T}.a forcing.offlux.a &
    endif
    if (-z  forcing.offlux.b) then
      ln -f ./offlux${OFF}_${YOF}_${T}.b forcing.offlux.b &
    endif
  endif
else
C
C --- time-invarent heat flux offset
C
  setenv OFF ""
# setenv OFF "_153yr3+yr5_bx25"
  if   ($OFF != "") then
    touch  forcing.offlux.a forcing.offlux.b
    if (-z forcing.offlux.a) then
       ${pget} ${DS}/force/offset/offlux${OFF}_${T}.a forcing.offlux.a &
    endif
    if (-z forcing.offlux.b) then
       ${pget} ${DS}/force/offset/offlux${OFF}_${T}.b forcing.offlux.b &
    endif 
  endif 
endif 
C
touch  forcing.rivers.a
touch  forcing.rivers.b
if (-z forcing.rivers.a) then
   ${pget} ${DS}/force/rivers/rivers_${T}.a forcing.rivers.a &
endif
if (-z forcing.rivers.b) then
   ${pget} ${DS}/force/rivers/rivers_${T}.b forcing.rivers.b &
endif
C
touch  forcing.chl.a
touch  forcing.chl.b
if (-z forcing.chl.a) then
   ${pget} ${DS}/force/seawifs/chl.a forcing.chl.a &
endif
if (-z forcing.chl.b) then
   ${pget} ${DS}/force/seawifs/chl.b forcing.chl.b &
endif
C
touch  relax.rmu.a relax.saln.a relax.temp.a relax.intf.a
touch  relax.rmu.b relax.saln.b relax.temp.b relax.intf.b
if (-z relax.rmu.a) then
   ${pget} ${DS}/relax/${E}/relax_rmu.a relax.rmu.a  &
endif
if (-z relax.rmu.b) then
   ${pget} ${DS}/relax/${E}/relax_rmu.b relax.rmu.b  &
endif
if (-z relax.saln.a) then
   ${pget} ${DS}/relax/${E}/relax_sal.a relax.saln.a &
endif
if (-z relax.saln.b) then
   ${pget} ${DS}/relax/${E}/relax_sal.b relax.saln.b &
endif
if (-z relax.temp.a) then
   ${pget} ${DS}/relax/${E}/relax_tem.a relax.temp.a &
endif
if (-z relax.temp.b) then
   ${pget} ${DS}/relax/${E}/relax_tem.b relax.temp.b &
endif
if (-z relax.intf.a) then
   ${pget} ${DS}/relax/${E}/relax_int.a relax.intf.a &
endif
if (-z relax.intf.b) then
   ${pget} ${DS}/relax/${E}/relax_int.b relax.intf.b &
endif
#C
#touch  tbaric.a
#touch  tbaric.b
#if (-z tbaric.a) then
#   ${pget} ${DS}/relax/${E}/tbaric.a tbaric.a  &
#endif
#if (-z tbaric.b) then
#   ${pget} ${DS}/relax/${E}/tbaric.b tbaric.b  &
#endif
C
setenv XS ""
#setenv XS "GDEM42_07"
if   ($XS != "") then
  touch  relax.ssh.a
  if (-z relax.ssh.a) then
     ${pget} ${DS}/relax/SSH/relax_ssh_${XS}.a relax.ssh.a &
  endif
  touch  relax.ssh.b
  if (-z relax.ssh.b) then
     ${pget} ${DS}/relax/SSH/relax_ssh_${XS}.b relax.ssh.b &
  endif
endif
C
#setenv XM "153"
setenv XM "011"
if   ($XM != "") then
  touch  relax.montg.a
  if (-z relax.montg.a) then
     ${pget} ${DS}/relax/SSH/relax_montg_${XM}_1994.a relax.montg.a &
  endif
  touch  relax.montg.b
  if (-z relax.montg.b) then
     ${pget} ${DS}/relax/SSH/relax_montg_${XM}_1994.b relax.montg.b &
  endif
endif
C
setenv XR "_m0p5psu"
#setenv XR ""
if   ($XR != "") then
  touch  relax.sssrmx.a
  if (-z relax.sssrmx.a) then
     ${pget} ${DS}/relax/SSSRMX/sssrmx${XR}.a relax.sssrmx.a &
  endif
  touch  relax.sssrmx.b
  if (-z relax.sssrmx.b) then
     ${pget} ${DS}/relax/SSSRMX/sssrmx${XR}.b relax.sssrmx.b &
  endif
endif
C
#setenv XSE "sp"
setenv XSE ""
if   ($XSE != "") then
  touch  relax.sefold.a
  if (-z relax.sefold.a) then
     ${pget} ${DS}/relax/${E}/sefold_${XSE}.a relax.sefold.a &
  endif
  touch  relax.sefold.b
  if (-z relax.sefold.b) then
     ${pget} ${DS}/relax/${E}/sefold_${XSE}.b relax.sefold.b &
  endif
endif
C
touch  cb.a
touch  cb.b
if (-z cb.a) then
   ${pget} ${DS}/relax/DRAG/cb_${T}_10mm.a cb.a  &
endif
if (-z cb.b) then
   ${pget} ${DS}/relax/DRAG/cb_${T}_10mm.b cb.b  &
endif
#C
#touch cbar.a
#touch cbar.b
#if (-z cbar.a) then
#   ${pget} ${DS}/relax/${E}/cbar.a cbar.a  &
#endif
#if (-z cbar.b) then
#   ${pget} ${DS}/relax/${E}/cbar.b cbar.b  &
#endif
#C
#touch iso.sigma.a
#touch iso.sigma.b
#if (-z iso.sigma.a) then
#   ${pget} ${DS}/relax/${E}/iso_sigma.a iso.sigma.a  &
#endif
#if (-z iso.sigma.b) then
#   ${pget} ${DS}/relax/${E}/iso_sigma.b iso.sigma.b  &
#endif
#C
#touch iso.top.a
#touch iso.top.b
#if (-z iso.top.a) then
#   ${pget} ${DS}/relax/${E}/iso_top.a iso.top.a  &
#endif
#if (-z iso.top.b) then
#   ${pget} ${DS}/relax/${E}/iso_top.b iso.top.b  &
#endif
#C
#touch  thkdf2.a
#touch  thkdf2.b
#if (-z thkdf2.a) then
#   ${pget} ${DS}/relax/${E}/thkdf2.a thkdf2.a  &
#endif
#if (-z thkdf2.b) then
#   ${pget} ${DS}/relax/${E}/thkdf2.b thkdf2.b  &
#endif
#C
#touch thkdf4.a
#touch thkdf4.b
#if (-z thkdf4.a) then
#   ${pget} ${DS}/relax/${E}/thkdf4.a thkdf4.a  &
#endif
#if (-z thkdf4.b) then
#   ${pget} ${DS}/relax/${E}/thkdf4.b thkdf4.b  &
#endif
C
touch veldf2.a
touch veldf2.b
if (-z veldf2.a) then
   ${pget} ${DS}/relax/${E}/veldf2.a veldf2.a  &
endif
if (-z veldf2.b) then
   ${pget} ${DS}/relax/${E}/veldf2.b veldf2.b  &
endif
#C
#touch veldf4.a
#touch veldf4.b
#if (-z veldf4.a) then
#   ${pget} ${DS}/relax/${E}/veldf4.a veldf4.a  &
#endif
#if (-z veldf4.b) then
#   ${pget} ${DS}/relax/${E}/veldf4.b veldf4.b  &
#endif
C
#setenv TT ".lim17"
setenv TT ""
C
#touch tidal.rh.a
#touch tidal.rh.b
#if (-z tidal.rh.a) then
#   ${pget} ${DS}/relax/DRAG/tidal.rh.${T}${TT}.a tidal.rh.a  &
#endif
#if (-z tidal.rh.b) then
#   ${pget} ${DS}/relax/DRAG/tidal.rh.${T}${TT}.b tidal.rh.b  &
#endif
C
C --- restart input
C
touch   restart_in.a restart_in.b restart_out.a restart_out.b restart_out1.a restart_out1.b
if (-z restart_in.b) then
  setenv RI "       0.00"
else
  setenv RI `head -2 restart_in.b | tail -1 | awk  '{printf("%11.2f\n", $5)}'`
endif
if (-z restart_out.b) then
  setenv RO "       0.00"
else
  setenv RO `head -2 restart_out.b | tail -1 | awk  '{printf("%11.2f\n", $5)}'`
endif
if (-z restart_out1.b) then
  setenv R1 "       0.00"
else
  setenv R1 `head -2 restart_out1.b | tail -1 | awk  '{printf("%11.2f\n", $5)}'`
endif
setenv LI `awk  '{printf("%11.2f\n", $1)}' limits`
C
if (`echo $LI | awk '{if ($1 <= 0.0) print 1; else print 0}'`) then
C --- no restart needed
  /bin/rm -f restart_in.a   restart_in.b
  /bin/rm -f restart_out.a  restart_out.b
  /bin/rm -f restart_out1.a restart_out1.b
else if (`echo $LI $RI | awk '{if ($1-0.1 < $2 && $1+0.1 > $2) print 1; else print 0}'`) then
C --- restart is already in restart_in
  /bin/rm -f restart_out.a  restart_out.b
  /bin/rm -f restart_out1.a restart_out1.b
else if (`echo $LI $RO | awk '{if ($1-0.1 < $2 && $1+0.1 > $2) print 1; else print 0}'`) then
C --- restart is in restart_out
  /bin/mv -f restart_out.a  restart_in.a
  /bin/mv -f restart_out.b  restart_in.b
  /bin/rm -f restart_out1.a restart_out1.b
else if (`echo $LI $R1 | awk '{if ($1-0.1 < $2 && $1+0.1 > $2) print 1; else print 0}'`) then
C ---   restart is in restart_out1
  /bin/mv -f restart_out1.a restart_in.a
  /bin/mv -f restart_out1.b restart_in.b
  /bin/rm -f restart_out.a  restart_out.b
else
C ---   get restart from permenant storage
  /bin/rm -f restart_in.a   restart_in.b
  /bin/rm -f restart_out.a  restart_out.b
  /bin/rm -f restart_out1.a restart_out1.b
  ${pget} ${S}/restart_${Y01}${A}.a restart_in.a &
  ${pget} ${S}/restart_${Y01}${A}.b restart_in.b &
endif
if (-e ./cice) then
C
C --- CICE restart input
C
touch  cice.restart_in cice.restart_out
if (-z cice.restart_in) then
  setenv RI "       0.00"
else
  setenv RI `cice_stat cice.restart_in  | awk  '{printf("%11.2f\n", $4)}'`
endif
if (-z cice.restart_out) then
  setenv RO "       0.00"
else
  setenv RO `cice_stat cice.restart_out | awk  '{printf("%11.2f\n", $4)}'`
endif
setenv LI `awk  '{printf("%11.2f\n", $1)}' limits`
C
if (`echo $LI $RI | awk '{if ($1-0.1 < $2 && $1+0.1 > $2) print 1; else print 0}'`) then
C --- restart is already in cice.restart_in
  /bin/rm -f cice.restart_out
else if (`echo $LI $RO | awk '{if ($1-0.1 < $2 && $1+0.1 > $2) print 1; else print 0}'`) then
C --- restart is in cice.restart_out
  /bin/mv -f cice.restart_out  cice.restart_in
else
C ---   get restart from permenant storage
  /bin/rm -f cice.restart_in
  /bin/rm -f cice.restart_out
  ${pget} ${S}/cice.restart_${Y01}${A} cice.restart_in &
endif
echo "cice.restart_in" >! cice.restart_file
endif
C
C --- model executable
C
if      ($NMPI == 0 && $NOMP == 0) then
  setenv TYPE one
else if ($NMPI == 0) then
  setenv TYPE omp
else if ($NOMP == 0) then
  if ( ! $?TYPE ) then
    setenv TYPE mpi
  endif
else
  setenv TYPE ompi
endif
if (-e ./cice) then
  setenv TYPE "cice_v4.0e"
  setenv HEXE hycom_cice
else
#  setenv HEXE hycom_latbdtf_nest
  setenv HEXE hycom
endif
/bin/cp ${D}/../../src_${V}_relo_${TYPE}/${HEXE} . &
C
C --- summary printout
C
touch      summary_out
/bin/mv -f summary_out summary_old
C
C --- heat transport output
C
touch      flxdp_out.a flxdp_out.b
/bin/mv -f flxdp_out.a flxdp_old.a
/bin/mv -f flxdp_out.b flxdp_old.b
C
touch      ovrtn_out
/bin/mv -f ovrtn_out ovrtn_old
C
C --- clean up old archive files, typically from batch system rerun.
C
mkdir KEEP
touch archv.dummy.b
foreach f (arch*.{a,b,txt})
  /bin/mv -f $f KEEP/$f
end
C
C --- Nesting input archive files.
C
if (-e ./nest) then
  cd ./nest
  touch rmu.a rmu.b
  if (-z rmu.a) then
     ${pget} ${DS}/relax/${E}/nest_rmu.a rmu.a &
  endif
  if (-z rmu.b) then
     ${pget} ${DS}/relax/${E}/nest_rmu.b rmu.b &
  endif
# create the links to nest files for this year
  if (${A} == a) then
  touch      arch.dummy.b
  /bin/rm -f arch*.[ab]

C link to pre-positioned archives
  csh ${D}/../${E}_nest_link.csh ${Y01} 
  endif
#  touch  archm_${Y01}${A}.tar.gz
#  if (-z archm_${Y01}${A}.tar.gz) then
#    ${pget} ${DS}/nest/${E}/archm_${Y01}${A}.tar.gz archm_${Y01}${A}.tar.gz
#  endif
#  tar xzvf archm_${Y01}${A}.tar.gz

# touch  nest_mon.tar.gz
# if (-z nest_mon.tar.gz) then
#   ${pget} ${DS}/nest/nest_mon.tar.gz .
# endif
# tar xzvf nest_mon.tar.gz
  cd ..
endif
C
C --- let all file copies complete.
C
wait
C
C --- zero file length means no rivers.
C
if (-z forcing.rivers.a) then
   /bin/rm -f forcing.rivers.[ab]
endif
C
C --- Just in time atmospheric forcing.
C
if ( ${MAKE_FORCE} >= 1 ) then
  # present run forcing
  /bin/rm -f ${E}preA${Y01}${A}.csh ${E}preA${Y01}${A}.log
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}preA.csh > ${E}preA${Y01}${A}.csh
  csh ${E}preA${Y01}${A}.csh >&  ${E}preA${Y01}${A}.log

  # next run forcing
  /bin/rm -f ${E}preB${YXX}${B}.csh ${E}preB${YXX}${B}.log
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../PRE/${E}preB.csh > ${E}preB${YXX}${B}.csh
  csh ${E}preB${YXX}${B}.csh >&  ${E}preB${YXX}${B}.log &

endif
wait
C
C --- Nesting input archive files for next segment.
C
if (-e ./nest) then
  if (! -e ./nest/nest.tar) then
    cd ./nest
#    touch  archm_${YXX}${B}.tar.gz
#    if (-z archm_${YXX}${B}.tar.gz) then
#      ${pget} ${DS}/nest/${E}/archm_${YXX}${B}.tar.gz archm_${YXX}${B}.tar.gz &
#    endif
    cd ..
  endif
endif
C
chmod ug+x ${HEXE}
/bin/ls -laFq
C
if (-e ./nest) then
  ls -laFq nest
endif
C
C ---  Check to make sure restart file is there
C
if (`echo $LI | awk '{print ($1 > 0.0)}'` && -z restart_in.a) then
  cd $D/..
  /bin/mv -f LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
C
if ($NMPI == 0) then
C
C --- run the model, without MPI or SHMEM
C
if ($NOMP == 0) then
  setenv NOMP 1
endif
C
switch ($OS)
case 'Linux':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    env OMP_NUM_THREADS=$NOMP MPSTKZ=8M ./${HEXE}
    breaksw
case 'ICE':
    limit stacksize unlimited
    setenv OMP_NUM_THREADS  $NOMP
    setenv OMP_STACKSIZE    127M
    ./${HEXE}
    breaksw
case 'HPE':
case 'SHASTA':
    limit stacksize unlimited
    setenv OMP_NUM_THREADS  $NOMP
    setenv OMP_STACKSIZE    127M
    ./${HEXE}
    breaksw
case 'AIX':
C
C   --- $NOMP CPUs/THREADs, if compiled for IBM OpenMP.
C
    /bin/rm -f core
    touch core
    setenv SPINLOOPTIME     500
    setenv YIELDLOOPTIME    500
    setenv XLSMPOPTS       "parthds=${NOMP}:spins=0:yields=0"
    ./${HEXE}
    breaksw
#case 'AIX':
#C
#C   --- $NOMP CPUs/THREADs, if compiled for KAI OpenMP.
#C
#    /bin/rm -f core
#    touch core
#    env OMP_NUM_THREADS=$NOMP ./${HEXE}
#    breaksw
case 'unicos':
C
C   --- $NOMP CPUs/THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    assign -V
    env OMP_NUM_THREADS=$NOMP ./${HEXE}
    if (! -z core)  debug -s ${HEXE} core
    assign -V
    assign -R
    breaksw
endsw
else
C
C --- run the model, with MPI or SHMEM and perhaps also with OpenMP.
C
touch patch.input
if (-z patch.input) then
C
C --- patch.input is always required for MPI or SHMEM.
C
  cd $D/..
  /bin/mv -f LIST LIST_BADRUN
  echo "BADRUN" > LIST
  exit
endif
C
switch ($OS)
case 'Linux':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
C
    /bin/rm -f core
    touch core
    setenv OMP_NUM_THREADS $NOMP
    mpirun -np $NMPI ./${HEXE}
    breaksw
case 'ICE':
    if ($NOMP == 0) then
	limit stacksize unlimited
        setenv MPI_DSM_DISTRIBUTE   yes
        setenv MPI_BUFS_PER_HOST    768
        setenv MPI_BUFS_PER_PROC    128
        setenv MPI_GROUP_MAX        128
        time mpiexec_mpt -np $NMPI ./${HEXE}
    else
        limit stacksize unlimited
        setenv OMP_NUM_THREADS      $NOMP
        setenv OMP_STACKSIZE        127M
        setenv MPI_DSM_DISTRIBUTE   yes
        setenv MPI_BUFS_PER_HOST    768
        setenv MPI_BUFS_PER_PROC    128
        setenv MPI_GROUP_MAX        128
        time mpiexec_mpt -np $NMPI omplace -nt $NOMP ./${HEXE}
    endif
    breaksw
case 'HPE':
    if ($NOMP == 0) then
#     48 cores per node, 24 cores per NUMA node
      setenv NMPI1  `expr $NMPI % 48`
      if ($NMPI1 == 0) then
        setenv NMPI1 48
      endif
      setenv NMPI11 `expr $NMPI1 + 1`
      setenv NMPI1S `expr $NMPI11 / 2`
      setenv NMPI1R `expr $NMPI1 - $NMPI1S`
      setenv NMPI1A `expr $NMPI1S - 1`
      setenv NMPI1B `expr $NMPI1R + 23`
      if     ($NMPI1 == 1) then
        setenv NMPIDSM "0:0-47:allhosts"
      else
        setenv NMPIDSM "0-${NMPI1A},24-${NMPI1B}:0-47:allhosts"
      endif
      echo $NMPIDSM
      setenv MPI_GROUP_MAX             96
      setenv MPI_DISPLAY_SETTINGS       1
      setenv MPI_VERBOSE                1
      setenv MPI_VERBOSE2              1
      #setenv MPI_BUFS_PER_HOST         768
      #setenv MPI_BUFS_PER_PROC         128
      setenv MPI_DSM_DISTRIBUTE         yes
      setenv MPI_DSM_CPULIST            "$NMPIDSM"
      #setenv MPI_DSM_VERBOSE           1
      setenv KMP_AFFINITY               disabled
      setenv OMP_NUM_THREADS            1
      setenv NO_STOP_MESSAGE
      mpiexec_mpt -np $NMPI ./${HEXE}
    else
      limit stacksize unlimited
      setenv MPI_GROUP_MAX             96
      setenv MPI_DISPLAY_SETTINGS       1
      setenv MPI_VERBOSE                1
      setenv MPI_VERBOSE2               1
      #setenv MPI_BUFS_PER_HOST         768
      #setenv MPI_BUFS_PER_PROC         128
      setenv KMP_AFFINITY               disabled
      setenv OMP_NUM_THREADS            $NOMP
      setenv OMP_STACKSIZE              127M
      setenv NO_STOP_MESSAGE
      mpiexec_mpt -np $NMPI omplace -nt $NOMP ./${HEXE}
    endif
    breaksw
case 'IDP':
# ---   From "Using IntelMPI on Discover"
# ---   https://modelingguru.nasa.gov/docs/DOC-1670
        setenv I_MPI_DAPL_SCALABLE_PROGRESS	1
        setenv I_MPI_DAPL_RNDV_WRITE		1
        setenv I_MPI_JOB_STARTUP_TIMEOUT	10000
        setenv I_MPI_HYDRA_BRANCH_COUNT		512
        setenv DAPL_ACK_RETRY		 7
        setenv DAPL_ACK_TIMER		 23
        setenv DAPL_RNR_RETRY		 7
        setenv DAPL_RNR_TIMER		 28
# ---   intel scaling suggestions
        setenv DAPL_CM_ARP_TIMEOUT_MS	 8000
        setenv DAPL_CM_ARP_RETRY_COUNT	 25
        setenv DAPL_CM_ROUTE_TIMEOUT_MS  20000
        setenv DAPL_CM_ROUTE_RETRY_COUNT 15
        setenv DAPL_MAX_CM_RESPONSE_TIME 20
        setenv DAPL_MAX_CM_RETRIES	 15
        if ($NOMP == 0) then
            setenv OMP_NUM_THREADS      1
            mpirun ./${HEXE}
        else
            setenv OMP_NUM_THREADS      $NOMP
            mpirun ./${HEXE}
        endif
        breaksw
case 'XC30':
    if ($NOMP == 0) then
      setenv NOMP 1
    endif
    setenv OMP_NUM_THREADS           $NOMP
    setenv MPI_COLL_OPT_ON           1
    setenv MPICH_RANK_REORDER_METHOD 1
    setenv MPICH_MAX_SHORT_MSG_SIZE  65536
    setenv MPICH_UNEX_BUFFER_SIZE    90M
    setenv MPICH_VERSION_DISPLAY     1
    setenv MPICH_ENV_DISPLAY         1
    setenv NO_STOP_MESSAGE
    if ($NOMP == 0 || $NOMP == 1) then
      setenv NMPI1  `expr $NMPI % 24`
      if ($NMPI1 == 0) then
        setenv NMPI1 24
      endif
      setenv NMPI2  `expr $NMPI - $NMPI1`
      setenv NMPI11 `expr $NMPI1 + 1`
      setenv NMPI1S `expr $NMPI11 / 2`
      time aprun -n $NMPI1 -S $NMPI1S ./${HEXE} : -n $NMPI2 -d 1 ./${HEXE}
#     time aprun -n $NMPI -d 1 ./${HEXE}
    else if ($NOMP == 2) then
      time aprun -n $NMPI -d 2 ./${HEXE}
    else if ($NOMP == 3) then
      time aprun -n $NMPI -d 3 ./${HEXE}
    else if ($NOMP == 4) then
      time aprun -n $NMPI -d 4 ./${HEXE}
    endif
    breaksw
case 'XC40':
    if ($NOMP == 0) then
      setenv NOMP 1
    endif
    setenv OMP_NUM_THREADS           $NOMP
    setenv MPI_COLL_OPT_ON           1
    setenv MPICH_RANK_REORDER_METHOD 1
    setenv MPICH_MAX_SHORT_MSG_SIZE  65536
    setenv MPICH_UNEX_BUFFER_SIZE    90M
    setenv MPICH_VERSION_DISPLAY     1
    setenv MPICH_ENV_DISPLAY         1
    setenv NO_STOP_MESSAGE
    if ($NOMP == 0 || $NOMP == 1) then
#     32 cores per node, 16 cores per NUMA node
      setenv NMPI1  `expr $NMPI % 32`
      if ($NMPI1 == 0) then
        setenv NMPI1 32
      endif
      setenv NMPI2  `expr $NMPI - $NMPI1`
      setenv NMPI11 `expr $NMPI1 + 1`
      setenv NMPI1S `expr $NMPI11 / 2`
      time aprun -n $NMPI1 -S $NMPI1S ./${HEXE} : -n $NMPI2 -d 1 ./${HEXE}
#     time aprun -n $NMPI -d 1 ./${HEXE}
    else if ($NOMP == 2) then
      time aprun -n $NMPI -d 2 ./${HEXE}
    else if ($NOMP == 3) then
      time aprun -n $NMPI -d 3 ./${HEXE}
     else if ($NOMP == 4) then
      time aprun -n $NMPI -d 4 ./${HEXE}
    endif
    breaksw
case 'SHASTA':
    wc -l $PBS_NODEFILE
    uniq  $PBS_NODEFILE
    setenv LD_LIBRARY_PATH           ${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
    setenv MPICH_VERSION_DISPLAY     1
    setenv MPICH_ENV_DISPLAY         1
    setenv MPICH_ABORT_ON_ERROR      1
    setenv ATP_ENABLED               1
    setenv NO_STOP_MESSAGE           1
    if ($NOMP == 0 || $NOMP == 1) then
      setenv OMP_NUM_THREADS 1
#     128 cores per dual-socket node, 16 cores per NUMA node
      setenv CPU_NUMA "112-127:48-63:96-111:32-47:80-95:16-31:64-79:0-15"
      time mpiexec --mem-bind local --cpu-bind list:$CPU_NUMA -n $NMPI ./${HEXE}
    else
      setenv OMP_NUM_THREADS $NOMP
      setenv OMP_STACKSIZE   127M
      setenv KMP_AFFINITY    disabled
      time mpiexec -mem-bind local -n $NMPI -depth $NOMP ./${HEXE}
    endif
    breaksw
case 'AIX':
C
C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for IBM OpenMP.
C
    /bin/rm -f core
    touch core
    setenv SPINLOOPTIME		500
    setenv YIELDLOOPTIME	500
    setenv XLSMPOPTS		"parthds=${NOMP}:spins=0:yields=0"
    setenv MP_SHARED_MEMORY	yes
    setenv MP_SINGLE_THREAD	yes
#   setenv MP_SINGLE_THREAD	no
    setenv MP_EAGER_LIMIT	65536
#   setenv MP_EUILIB		us
#   list where the MPI job will run
#   env MP_LABELIO=YES $POE hostname
    time $POE ./${HEXE}
    breaksw
#case 'AIX':
#C
#C   --- $NMPI MPI tasks and $NOMP THREADs, if compiled for KAI OpenMP.
#C
#    /bin/rm -f core
#    touch core
#    setenv OMP_NUM_THREADS	$NOMP
#    setenv MP_SHARED_MEMORY	yes
#    setenv MP_SINGLE_THREAD	yes
#    setenv MP_EAGER_LIMIT	65536
#    setenv MP_EUILIB		us
#    setenv MP_EUIDEVICE		css0
##   list where the MPI job will run
#    env MP_LABELIO=YES $POE hostname
#    time $POE ./${HEXE}
#    breaksw
default:
    echo "This O/S," $OS ", is not configured for MPI/SHMEM"
    exit (1)
endsw
endif
C
touch      PIPE_DEBUG
/bin/rm -f PIPE_DEBUG
C
C --- archive output in a separate tar directory
C
touch archv.dummy.a archv.dummy.b archv.dummy.txt
touch archm.dummy.a archm.dummy.b archm.dummy.txt
touch arche.dummy.a arche.dummy.b arche.dummy.txt
touch archs.dummy.a archs.dummy.b archs.dummy.txt
touch cice.dummy.nc
C
if (-e ./SAVE) then
  foreach t ( v s m e )
    foreach f (arch${t}.*.a)
      /bin/ln ${f} SAVE/${f}
    end
    foreach f (arch${t}.*.b)
      /bin/ln ${f} SAVE/${f}
    end
    foreach f (arch${t}.*.txt)
      /bin/ln ${f} SAVE/${f}
    end
  end
  foreach f (cice.*.nc)
    /bin/ln -f ${f} SAVE/${f}
  end
endif
C
foreach t ( e m s )

  mkdir ./tar${t}_${Y01}${A}
switch ($OS)
case 'ICE':
  lfs setstripe ./tar${t}_${Y01}${A} -S 1048576 -i -1 -c 8
  breaksw
endsw
  foreach f (arch${t}.*.a)
    /bin/mv ${f} ./tar${t}_${Y01}${A}/${E}_${f}
  end
  foreach f (arch${t}.*.b)
    /bin/mv ${f} ./tar${t}_${Y01}${A}/${E}_${f}
  end
  foreach f (arch${t}.*.txt)
    /bin/mv ${f} ./tar${t}_${Y01}${A}/${E}_${f}
  end
  date
end
# mkdir ./tarc_${Y01}${A}
#switch ($OS)
#case 'ICE':
#  lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 8
#  breaksw
#case 'XC30':
#  lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 8
## lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 24
#  breaksw
#case 'XC40':
#  lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 8
## lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 24
## lfs setstripe ./tarc_${Y01}${A} -S 1048576 -i -1 -c 48
#  breaksw
#endsw
if (-e ./cice ) then
 foreach f (cice_*.nc)
    /bin/mv ${f} ./tarc_${Y01}${A}/${E}_${f}
  end
endif
C 
if (! -z archt.input) then
  if (-e ./tart_${Y01}${A}) then
    /bin/mv ./tart_${Y01}${A} ./tart_${Y01}${A}_$$
  endif
  /bin/mv ./ARCHT ./tart_${Y01}${A}
endif
C
C --- add last day to next months tar directory, for actual day months only
C
setenv DL `awk  '{printf("%15.2f\n", $2)}' limits`
setenv DA `echo 3 1.0 1.0 $DL $DL | ~/HYCOM-tools/bin/hycom_nest_dates | head -1`
foreach t ( s e )
  mkdir ./tar${t}_${YXX}${B}
  ln -f ./tar${t}_${Y01}${A}/${E}_arch?.${DA}.* ./tar${t}_${YXX}${B}
end
C
C --- build and run or submit the tar script
C
#foreach t ( c e m s )
foreach t (  m s )
  awk -f $D/../${E}.awk y01=${Y01} ab=${A} $D/../POST/${E}A${t}.csh >! tar${t}_${Y01}${A}.csh
  ${QSUBMIT} tar${t}_${Y01}${A}.csh 
end
C
C --- heat transport statistics output
C
if (-e flxdp_out.a) then
  ${pput} flxdp_out.a ${S}/flxdp_${Y01}${A}.a
endif
if (-e flxdp_out.b) then
  ${pput} flxdp_out.b ${S}/flxdp_${Y01}${A}.b
endif
if (-e ovrtn_out) then
  ${pput} ovrtn_out ${S}/ovrtn_${Y01}${A}
endif
C
C --- restart output
C
if (-e restart_out.a) then
  ${pput} restart_out.a ${S}/restart_${YXX}${B}.a
endif
if (-e restart_out.b) then
  ${pput} restart_out.b ${S}/restart_${YXX}${B}.b
endif
endif
if (-e ./cice) then
C
C --- CICE restart output, assumes single-month runs
C
  /bin/mv cice.restart*01-00000 cice.restart_out
  if (-e cice.restart_out) then
    ${pput} cice.restart_out ${S}/cice.restart_${YXX}${B}
  endif
endif
C
if (${MAKE_FORCE} >= 1) then
C
C --- Delete just in time wind and flux files.
C
  touch summary_out
  tail -1 summary_out
  tail -1 summary_out | grep -c "^normal stop"
  if ( `tail -1 summary_out | grep -c "^normal stop"` == 1 ) then
    /bin/rm -f ./wind/*_${Y01}${A}.[ab]
    /bin/rm -f ./wspd/*_${Y01}${A}.[ab]
    /bin/rm -f ./wvel/*_${Y01}${A}.[ab]
    /bin/rm -f ./grad/*_${Y01}${A}.[ab]
    /bin/rm -f ./flux/*_${Y01}${A}.[ab]
    /bin/rm -f ./flxt/*_${Y01}${A}.[ab]
    /bin/rm -f ./lrad/*_${Y01}${A}.[ab]
    /bin/rm -f ./mslp/*_${Y01}${A}.[ab]
    /bin/rm -f ./pcip/*_${Y01}${A}.[ab]
    /bin/rm -f ./ssta/*_${Y01}${A}.[ab]
    /bin/rm -f ./ssto/*_${Y01}${A}.[ab]
    /bin/rm -f ./cice/*_${Y01}${A}.[rB]
  endif
C
  if (-e ./wind/${E}w${Y01}${A}.csh) then
    /bin/mv ./wind/${E}w${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./wspd/${E}s${Y01}${A}.csh) then
    /bin/mv ./wspd/${E}s${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./wvel/${E}v${Y01}${A}.csh) then
    /bin/mv ./wvel/${E}v${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./grad/${E}g${Y01}${A}.csh) then
    /bin/mv ./grad/${E}g${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./flux/${E}f${Y01}${A}.csh) then
    /bin/mv ./flux/${E}f${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./flxt/${E}q${Y01}${A}.csh) then
    /bin/mv ./flxt/${E}q${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./lrad/${E}l${Y01}${A}.csh) then
    /bin/mv ./lrad/${E}l${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./mslp/${E}m${Y01}${A}.csh) then
    /bin/mv ./mslp/${E}m${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./pcip/${E}p${Y01}${A}.csh) then
    /bin/mv ./pcip/${E}p${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./ssta/${E}t${Y01}${A}.csh) then
    /bin/mv ./ssta/${E}t${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./ssto/${E}o${Y01}${A}.csh) then
    /bin/mv ./ssto/${E}o${Y01}${A}.{com,log} $D/..
  endif
C
C --- Wait for wind and flux interpolation of next segment.
C
  wait
C
  if (-e ./wind/${E}w${YXX}${B}.csh) then
    /bin/mv ./wind/${E}w${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./wspd/${E}s${Y01}${A}.csh) then
    /bin/mv ./wspd/${E}s${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./wvel/${E}v${Y01}${A}.csh) then
    /bin/mv ./wvel/${E}v${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./grad/${E}g${Y01}${A}.csh) then
    /bin/mv ./grad/${E}g${Y01}${A}.{com,log} $D/..
  endif
  if (-e ./flux/${E}f${YXX}${B}.csh) then
    /bin/mv ./flux/${E}f${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./flxt/${E}q${YXX}${B}.csh) then
    /bin/mv ./flxt/${E}q${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./lrad/${E}l${YXX}${B}.csh) then
    /bin/mv ./lrad/${E}l${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./mslp/${E}m${YXX}${B}.csh) then
    /bin/mv ./mslp/${E}m${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./pcip/${E}p${YXX}${B}.csh) then
    /bin/mv ./pcip/${E}p${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./ssta/${E}t${YXX}${B}.csh) then
    /bin/mv ./ssta/${E}t${YXX}${B}.{com,log} $D/..
  endif
  if (-e ./ssto/${E}o${YXX}${B}.csh) then
    /bin/mv ./ssto/${E}o${YXX}${B}.{com,log} $D/..
  endif
endif
C
C --- wait for nesting .tar file.
C
if (-e ./nest) then
  wait
endif
C
C --- HYCOM error stop is implied by the absence of a normal stop.
C
touch summary_out
tail -1 summary_out
tail -1 summary_out | grep -c "^normal stop"
if ( `tail -1 summary_out | grep -c "^normal stop"` == 0 ) then
  cd $D/..
  /bin/mv LIST LIST_BADRUN
  echo "BADRUN" > LIST
endif
C
C --- submit postprocessing scripts
C
mkdir -p postproc
cd       postproc
C
C --- 1 - meanstd
C
if (${mnsqa} == 1) then
  /bin/rm -f             pp_mnsqa_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X} \
         ${D}/../../postproc/pp_mnsqa.csh >! pp_mnsqa_${E}_${Y01}${A}.csh
  ${QSUBMIT}  pp_mnsqa_${E}_${Y01}${A}.csh
endif
C
if (${mnsqe} == 1) then
  /bin/rm -f             pp_mnsqe_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X} \
         ${D}/../../postproc/pp_mnsqe.csh >! pp_mnsqe_${E}_${Y01}${A}.csh
  ${QSUBMIT}   pp_mnsqe_${E}_${Y01}${A}.csh
endif
C
C --- 1b - basin-wide statistics from daily means
C
if (${statm} == 1) then
  /bin/rm -f             pp_statm_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X} \
         ${D}/../../postproc/pp_statm.csh >! pp_statm_${E}_${Y01}${A}.csh
  ${QSUBMIT}   pp_statm_${E}_${Y01}${A}.csh
endif
C
C --- 2 - plots
C
if (${plots} == 1) then
  /bin/rm -f            pp_plot_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X} \
         ${D}/../../postproc/pp_plot.csh >! pp_plot_${E}_${Y01}${A}.csh
  ${QSUBMIT}  pp_plot_${E}_${Y01}${A}.csh
endif
C
C --- 3 - sample transports
C
if (${transp} == 1) then
  /bin/rm -f            pp_tprt_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X}  \
         ${D}/../../postproc/pp_tprt.csh >! pp_tprt_${E}_${Y01}${A}.csh
  ${QSUBMIT}  pp_tprt_${E}_${Y01}${A}.csh
endif
C
C --- 4 - data2d extraction, moorings, ice creation and plotting
C
if (${data2d} == 1) then
  /bin/rm -f              pp_data2d_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X}  \
         ${D}/../../postproc/pp_data2d.csh >! pp_data2d_${E}_${Y01}${A}.csh
  ${QSUBMIT}    pp_data2d_${E}_${Y01}${A}.csh
endif
C
C --- 5 - to netCDF
C
if (${netcdf} == 1) then
  /bin/rm -f                pp_netcdf_${E}_${Y01}${A}.{csh,log}
  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X}  \
         ${D}/../../postproc/pp_netcdf.csh >! pp_netcdf_${E}_${Y01}${A}.csh
  ${QSUBMIT}      pp_netcdf_${E}_${Y01}${A}.csh
endif
#C
#C --- 6 - GLBb0.08 to GLBu0.08 to netCDF
#C
#  /bin/rm -f                pp_GLBu0.08_${E}_${Y01}${A}.{csh,log}
#  awk -f ${D}/../../postproc/postproc.awk y=${Y01} p=${A} ex=${EX} r=${R} x=${X}  \
#         ${D}/../../postproc/pp_GLBu0.08.csh >! pp_GLBu0.08_${E}_${Y01}${A}.csh
#  ${QSUBMIT}      pp_GLBu0.08_${E}_${Y01}${A}.csh
C
C --- wait for tar bundles to complete
C
wait
C
C  --- END OF MODEL RUN SCRIPT
C
