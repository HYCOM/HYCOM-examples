#!/bin/csh
#PBS -N HY01525
#PBS -j oe
#PBS -o HY01525.log
#PBS -W umask=027
#PBS -l application=hycom
# 1525=1*117+11*128
#PBS -l select=1:ncpus=128:mpiprocs=117+11:ncpus=128:mpiprocs=128
#PBS -l place=scatter:excl
#PBS -l walltime=0:30:00
#PBS -A ONRDC10855122
#PBS -q debug
#
set echo
set time = 1
set timestamp
#
echo $PBS_JOBID
#
wc -l $PBS_NODEFILE
uniq  $PBS_NODEFILE
#
hostname
uname -a
#
setenv OS `uname`
switch ($OS)
case 'SunOS':
    fpversion
    breaksw
case 'IRIX64':
    hinv -c processor
    hinv -c memory
    breaksw
case 'Linux':
    head -40 /proc/cpuinfo
    head -40 /proc/meminfo
    which aprun
    if (! $status) then
      if ($?XTPE_NETWORK_TARGET) then
        if ($XTPE_NETWORK_TARGET == "aries") then
#         setenv OS XC30
          setenv OS XC40
        endif
        setenv APRUN1 "aprun -n 1"
      else
        setenv OS SHASTA
        unset echo
        module restore PrgEnv-intel
        module use --append /p/app/modulefiles
        module load bct-env
        module load cray-pals
#       cray-mpich/8.1.[12] do not work
        module swap cray-mpich/8.1.19
        module list
        set echo
      endif
    endif
    if ($OS == "Linux") then
    which dplace
    if (! $status) then
      setenv OS HPE
    endif
    endif
     if ($OS == "Linux") then
    which poe
    if (! $status) then
      setenv OS IDP
    endif
    endif
    breaksw
endsw
#
# --- Experiment GLBT0.08 - 73.7 - 2.2.01_relo
#
# --- 41 layer HYCOM on 0.08 degree global region.
# --- 73.7 - GOFS 3.1 like benchmark run - SPLIT_IO
#
# --- Set parallel configuration.
# --- NOMP = number of OpenMP threads, 0 for no OpenMP, 1 for inactive OpenMP
# --- NMPI = number of MPI    tasks,   0 for no MPI
#
setenv NOMP 0
setenv NMPI 1525
#
# --- V is source code version number.
# --- P is primary path to benchmark.
# --- S is scratch directory.
# --- D is prebuilt data file directory
#
setenv V 2.3.01-2023-03-19
setenv P HYCOM-examples/GLBT0.08
setenv S /p/work1/${user}/$P/expt_73.7/${OS}/data_${NMPI}
setenv D /p/work1/${user}/$P/expt_73.7/DATA
#setenv D ${home}/$P/expt_73.7/DATA
#
# --- I/O performance often depend on --stripe-count, i.e. on -c
# --- Do not set the number of stripes larger than mpe in patch.input
#
mkdir -p $S
if ($OS == "XC30") then
  lfs setstripe    $S -S 1048576 -i -1 -c 16
endif
if ($OS == "XC40") then
  lfs setstripe    $S -S 2097152 -i -1 -c 4
endif
if ($OS == "SHASTA") then
  lfs setstripe    $S -S 1048576 -i -1 -c 32
endif
if ($OS == "HPE") then
  lfs setstripe    $S -S 1048576 -i -1 -c 8
endif
if ($OS == "HPEI") then
  lfs setstripe    $S -S 1048576 -i -1 -c 16
endif
cd       $S
#
# --- For part year runs.
# ---   A is this part of the year, B is next part of the year.
# ---   Y01 is the start model year of this run.
# ---   YXX is the end   model year of this run, usually Y01.
#
setenv A "g"
setenv B "h"
setenv Y01 "001"
setenv YXX "001"
C
echo "Y01 =" $Y01 "YXX = " $YXX  "A =" ${A} "B =" ${B}
#
# --- prebuilt input files
#
touch      ar  flx  hycom ovr  patch.input sum 
/bin/rm -f ar* flx* hycom ovr* patch.input sum* 
/bin/cp -u ${D}/* .
#/bin/cp blkdat.input_$V blkdat.input
#/bin/cp  archs.input_$V archs.input
#
# --- model executable
#
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
/bin/cp ${home}/${P}/src_${V}_relo_${TYPE}/hycom .
#
/bin/ls -laFq
#
if ($NMPI == 0) then
#
# --- run the model, without MPI or SHMEM
#
    if ($NOMP == 0) then
      setenv NOMP 1
    endif
#
    /bin/rm -f core
    touch core
    date
    switch ($OS)
    case 'AIX':
        setenv OMP_DYNAMIC	FALSE
	setenv OMP_NUM_THREADS	$NOMP
        ./hycom
        breaksw
    case 'ICE':
        source /usr/share/modules/init/csh
	source /usr/local/bin/2009_Nov_suggested_modules
	limit stacksize unlimited
        setenv OMP_NUM_THREADS	$NOMP
	setenv OMP_STACKSIZE	127M
        ./hycom
        breaksw
    default:
        env OMP_NUM_THREADS=$NOMP ./hycom
    endsw
    date
#
# --- end model run
#
else
#
# --- run the model, with MPI or SHMEM and perhaps also with OpenMP.
# --- $NMPI MPI tasks and $NOMP THREADs, if compiled for OpenMP.
#
    setenv NPATCH `echo $NMPI | awk '{printf("%05d", $1)}'`
    if (-e patch.input_${NPATCH}s8) then
      ln   patch.input_${NPATCH}s8 patch.input
    else
      echo "ERROR - requested patch file" patch.input_${NPATCH}s8 "does not exist"
      exit
    endif
    date
    switch ($OS)
    case 'SunOS':
        setenv OMP_NUM_THREADS $NOMP
#       mpirun -np $NMPI ./hycom
        pam ./hycom
        breaksw
    case 'OSF1':
        setenv OMP_NUM_THREADS $NOMP
        prun -n $NMPI ./hycom
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
          time aprun -n $NMPI1 -S $NMPI1S ./hycom : -n $NMPI2 -d 1 ./hycom
#         time aprun -n $NMPI -d 1 ./hycom
        else if ($NOMP == 2) then
          time aprun -n $NMPI -d 2 ./hycom
        else if ($NOMP == 3) then
          time aprun -n $NMPI -d 3 ./hycom
        else if ($NOMP == 4) then
          time aprun -n $NMPI -d 4 ./hycom
        endif
        breaksw
    case 'ICE':
        source /usr/share/modules/init/csh
        if ($NOMP == 0) then
	    setenv MPI_DSM_DISTRIBUTE	yes
            setenv MPI_BUFS_PER_HOST	768
            setenv MPI_BUFS_PER_PROC	128
            mpiexec_mpt -np $NMPI ./hycom
        else
	    limit stacksize unlimited
            setenv OMP_NUM_THREADS	$NOMP
	    setenv OMP_STACKSIZE	127M
	    setenv MPI_DSM_DISTRIBUTE	yes
            setenv MPI_BUFS_PER_HOST	768
            setenv MPI_BUFS_PER_PROC	128
            mpiexec_mpt -np $NMPI omplace -nt $NOMP ./hycom
        endif
        breaksw
    case 'XC40':
        if ($NOMP == 0) then
          setenv NOMP 1
        endif
        unset echo
        module load craype-hugepages2M
        module list
        set echo
        setenv MPI_COLL_OPT_ON           1
        setenv MPICH_RANK_REORDER_METHOD 1
        setenv MPICH_MAX_SHORT_MSG_SIZE  65536
        setenv MPICH_UNEX_BUFFER_SIZE    90M
        setenv MPICH_VERSION_DISPLAY     1
        setenv MPICH_ENV_DISPLAY         1
        setenv NO_STOP_MESSAGE
        if ($NOMP == 0 || $NOMP == 1) then
          setenv NMPI1  `expr $NMPI % 32`
          if ($NMPI1 == 0) then
            setenv NMPI1 32
          endif
          setenv NMPI2  `expr $NMPI - $NMPI1`
          setenv NMPI11 `expr $NMPI1 + 1`
          setenv NMPI1S `expr $NMPI11 / 2`
          time aprun -m800h -n $NMPI1 -S $NMPI1S ./hycom : -n $NMPI2 -d 1 ./hycom
#         time aprun -m800h -n $NMPI -d 1 ./hycom
        else if ($NOMP == 2) then
          time aprun -m800h -n $NMPI -d 2 ./hycom
        else if ($NOMP == 3) then
          time aprun -m800h -n $NMPI -d 3 ./hycom
        else if ($NOMP == 4) then
          time aprun -m800h -n $NMPI -d 4 ./hycom
        endif
        breaksw
    case 'SHASTA':
        setenv LD_LIBRARY_PATH           ${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
        setenv MPICH_VERSION_DISPLAY     1
        setenv MPICH_ENV_DISPLAY         1
        setenv MPICH_ABORT_ON_ERROR      1
        setenv ATP_ENABLED               1
        setenv NO_STOP_MESSAGE           1
        if ($NOMP == 0 || $NOMP == 1) then
          setenv OMP_NUM_THREADS 1
#         128 cores per dual-socket node, 16 cores per NUMA node
          setenv CPU_NUMA "112-127:48-63:96-111:32-47:80-95:16-31:64-79:0-15"
          time mpiexec --mem-bind local --cpu-bind list:$CPU_NUMA -n $NMPI ./hycom
        else
          setenv OMP_NUM_THREADS $NOMP
          setenv OMP_STACKSIZE   127M
          setenv KMP_AFFINITY    disabled
          time mpiexec -mem-bind local -n $NMPI -depth $NOMP ./hycom
        endif
        breaksw
   case 'HPE':
        if ($NOMP == 0) then
#         48 cores per node, 24 cores per NUMA node
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
          setenv MPI_DISPLAY_SETTINGS   1
          #setenv MPI_VERBOSE2          1
          #setenv MPI_BUFS_PER_HOST     768
          #setenv MPI_BUFS_PER_PROC     128
          setenv MPI_DSM_DISTRIBUTE     yes
          setenv MPI_DSM_CPULIST        "$NMPIDSM"
          setenv MPI_DSM_VERBOSE        1
          setenv KMP_AFFINITY           disabled
          setenv OMP_NUM_THREADS        0
          mpiexec_mpt -np $NMPI ./hycom
        else
          limit stacksize unlimited
          setenv MPI_DISPLAY_SETTINGS   1
          setenv MPI_VERBOSE2           1
          setenv MPI_VERBOSE2           1
          #setenv MPI_BUFS_PER_HOST     768
          #setenv MPI_BUFS_PER_PROC     128
          setenv KMP_AFFINITY           disabled
          setenv OMP_NUM_THREADS        $NOMP
          setenv OMP_STACKSIZE          127M
          mpiexec_mpt -np $NMPI omplace -nt $NOMP ./hycom
        endif
        breaksw
    case 'HPEI':
# ---   environment variables added for HYCOM, native Intel MPI
        setenv I_MPI_JOB_RESPECT_PROCESS_PLACEMENT      1
        setenv I_MPI_EXTRA_FILESYSTEM                   on
        setenv I_MPI_EXTRA_FILESYSTEM_LIST              lustre
# ---   environment variables from NAVGEM tuning, native Intel MPI
        setenv I_MPI_EAGER_THRESHOLD    1024000
        setenv I_MPI_ADJUST_ALLREDUCE   '4:4-7;12:7-12;9:12-38;10:38-243;11:243-480'
        setenv PSM2_RTS_CTS_INTERLEAVE  1
        setenv PSM2_RCVTHREAD           0
        setenv PSM2_MTU                 7
        setenv PSM2_BOUNCE_SZ           2048
        if ($NOMP == 0) then
            setenv OMP_NUM_THREADS      1
            mpirun -np $NMPI ./hycom
        else
            setenv OMP_NUM_THREADS      $NOMP
            mpirun -np $NMPI ./hycom
        endif
        breaksw
    case 'ICE':
        source /usr/share/modules/init/csh
        if ($NOMP == 0) then
	    setenv MPI_DSM_DISTRIBUTE	yes
            setenv MPI_BUFS_PER_HOST	768
            setenv MPI_BUFS_PER_PROC	128
            mpiexec_mpt -np $NMPI ./hycom
        else
	    limit stacksize unlimited
            setenv OMP_NUM_THREADS	$NOMP
	    setenv OMP_STACKSIZE	127M
	    setenv MPI_DSM_DISTRIBUTE	yes
            setenv MPI_BUFS_PER_HOST	768
            setenv MPI_BUFS_PER_PROC	128
            mpiexec_mpt -np $NMPI omplace -nt $NOMP ./hycom
        endif
        breaksw
    case 'IDP':
# ---   debugging
#       setenv I_MPI_DEBUG                      5
# ---   From "Using IntelMPI on Discover"
# ---   https://modelingguru.nasa.gov/docs/DOC-1670
        setenv I_MPI_DAPL_SCALABLE_PROGRESS     1
        setenv I_MPI_DAPL_RNDV_WRITE            1
        setenv I_MPI_JOB_STARTUP_TIMEOUT        10000
        setenv I_MPI_HYDRA_BRANCH_COUNT         512
        setenv DAPL_ACK_RETRY            7
        setenv DAPL_ACK_TIMER            23
        setenv DAPL_RNR_RETRY            7
        setenv DAPL_RNR_TIMER            28
# ---   intel scaling suggestions
        setenv DAPL_CM_ARP_TIMEOUT_MS    8000
        setenv DAPL_CM_ARP_RETRY_COUNT   25
        setenv DAPL_CM_ROUTE_TIMEOUT_MS  20000
        setenv DAPL_CM_ROUTE_RETRY_COUNT 15
        setenv DAPL_MAX_CM_RESPONSE_TIME 20
        setenv DAPL_MAX_CM_RETRIES       15
        if ($NOMP == 0) then
            setenv OMP_NUM_THREADS      1
            mpirun ./hycom
        else
            setenv OMP_NUM_THREADS      $NOMP
            mpirun ./hycom
        endif
        breaksw
    case 'IRIX64':
        limit descriptors 2000
        limit
        if ($TYPE == "shmem") then
            setenv OMP_NUM_THREADS  1
            setenv SMA_DSM_TOPOLOGY free
            setenv SMA_DSM_VERBOSE  1
            setenv SMA_VERSION      1
            env NPES=$NMPI ./hycom
        else
            setenv OMP_NUM_THREADS  $NOMP
            setenv MPI_DSM_VERBOSE  1
            setenv MPI_REQUEST_MAX  8192
            mpirun -np $NMPI ./hycom < /dev/null
        endif
        breaksw
    case 'AIX':
	if ($NOMP == 0) then
            setenv MP_SHARED_MEMORY	yes
            setenv MP_EAGER_LIMIT	65536
            setenv MP_SINGLE_THREAD	yes
	else
            setenv MP_SHARED_MEMORY	yes
            setenv MP_EAGER_LIMIT	65536
            setenv MP_SINGLE_THREAD	no
            setenv OMP_DYNAMIC		FALSE
	    setenv OMP_NUM_THREADS	$NOMP
	endif
        if ( $?GRD_TOTAL_MPI_TASKS ) then
            grd_poe    ./hycom
        else if ( $?PBS_SERVER ) then
            poepbs     ./hycom
        else if ( $?LSB_JOBINDEX ) then
            mpirun.lsf ./hycom
        else
            poe        ./hycom
        endif
        breaksw
    case 'unicosmk':
        mpprun -n $NMPI ./hycom
        breaksw
    default:
        setenv OMP_NUM_THREADS $NOMP
        mpirun -np $NMPI ./hycom
    endsw
    date
#
# --- end model run
#
endif
