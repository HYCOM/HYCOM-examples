#! /bin/csh -x
#PBS -N 999pbs
#PBS -j oe
#PBS -o 999pbsXX.log
#PBS -W umask=027 
#PBS -l application=hycom
#       47=47
#PBS -l select=1:ncpus=48:mpiprocs=47
#PBS -l place=scatter:excl
#PBS -l walltime=00:10:00
#PBS -A NRLSS03755018 
#PBS -q debug 
#
set echo
C
C --- Automatic Run Script.
C --- Submit with msub, or msub_csh, or msub_pbs command.
C --- Multiple segment version, set no. of segments on foreach below.
C
setenv EX /p/home/abozec/HYCOM-examples/GOMb0.08/expt_01.0
cd ${EX}
C
C --- E is expt, P is permenant directory,  SE is /tmp directory.
C
source ${EX}/EXPT.src
setenv SE ${S}/../

switch ($OS)
case 'AIX':
  hostname
  setenv TMPDIR /scr/${user}
  breaksw
case 'SunOS':
# assumes /usr/5bin is before /bin and /usr/bin in PATH.
  setenv TMPDIR /tmp
  breaksw
case 'Linux':
case 'XT3':
case 'XC30':
case 'XC40':
case 'HPE':
case 'HPEI':
case 'OSF1':
case 'IRIX64':
  setenv TMPDIR /tmp
  breaksw
case 'unicos':
    setenv ACCT "NO2031"
#   newacct $ACCT
#   source ~/.login
    breaksw
default:
    echo 'Unknown Operating System: ' $OS
    exit (1)
endsw
C
setenv
if ($?JOBNAME) then
    setenv PBS_JOBNAME ${JOBNAME}
    setenv PBS_JOBID   $$
endif
C
C
ls -laFq
C
C --- check the RUNNING flag.
C
if ( -e RUNNING && ! -e RUNNING_$PBS_JOBID) then
C
C --- MODEL IS ALREADY RUNNING - EXIT.
C
  exit
endif
touch RUNNING
touch RUNNING_$PBS_JOBID
C
C --- Number of segments specified by y and n foreach loops
C --- Use '( 1 )' in both for a single segment per run.
C
@ i = 0
foreach y ( 1  )
  foreach m ( 1 2 3 4 5 6 7 8 9 10 11 12 )
    @ i = $i + 1
    echo "Starting SEGMENT " $i
C
C --- Check the model list.
C
touch LIST
if ( -z LIST ) then
C
C --- MODEL RUN IS COMPLETE - EXIT.
C
  /bin/rm -f RUNNING
  /bin/rm -f RUNNING_$PBS_JOBID
  exit
endif
C
C --- Take the next run from LIST.
C
setenv Y01 `head -1 LIST | awk '{print $1}'`
C
if ( `echo $Y01 | egrep 'com' | wc -l` != 0 ) then
C
C --- Precalculated model script.
C
  setenv SCRIPT ${Y01}
  if (! -e $SCRIPT ) then
C
C --- PREDEFINED SCRIPT DOES NOT EXIST - EXIT.
C
    ls -laFq
    /bin/rm -f RUNNING
    /bin/rm -f RUNNING_$PBS_JOBID
    exit
  endif
else
C
C --- Generate the next model script.
C
  setenv AB `head -1 LIST | awk '{print $2}'`
  setenv SCRIPT ${E}y${Y01}${AB}.csh
  /bin/rm -f ${SCRIPT}
  awk -f ${E}.awk y01=${Y01} ab=${AB} ${E}.csh > ${SCRIPT}
endif
C
C --- Run the Script.
C
set script = $SCRIPT
set reqname = ${PBS_JOBNAME}
ln -fs ${reqname}.log $script:r.log
df -k
C
mkdir -p $SE
cp  ${SCRIPT} $SE/${SCRIPT}
cd  $SE
C
C ---------------------------------------------------------------------------
csh ${SCRIPT}
C ---------------------------------------------------------------------------
C
cd  $EX
C
C --- Clean Up.
C
ls -laFq
C
mv LIST LISTOLD
head -1 LISTOLD | comm -23 LISTOLD - > LIST
diff LIST LISTOLD
/bin/rm -f LISTOLD
C
C --- end of SEGMENT foreach loops
C
  end
end
C
C --- Final Clean Up.
C
/bin/rm -f RUNNING
/bin/rm -f RUNNING_$PBS_JOBID
C
touch LIST
if ( -z LIST ) then
C
C --- MODEL RUN IS COMPLETE - EXIT.
C
  exit
endif
C
C --- Submit the next job.
C
cat - > $TMPDIR/$$.awk <<'E-o-A'
BEGIN { for ( i=65;i <= 89; i++)
		c[sprintf("%c",i)] = sprintf("%c",i+1)
}
/[0-9]$/  { printf("%s%s\n",$0,"A")}
/[A-Y]$/  { printf("%s%s\n",substr($0,1,length($0)-1),c[substr($0,length($0))])}
/[1-9]Z$/ { printf("%s%s%s\n",substr($0,1,length($0)-2),substr($0,length($0)-1,1)+1,"A")}
/0Z$/     { next }
'E-o-A'
#
set newname = `echo ${reqname} | cut -c 2- | awk -f $TMPDIR/$$.awk`
#
/bin/rm -f $TMPDIR/$$.awk
if ( `echo $newname | wc -l` != 0 ) then
    if ($?JOBNAME) then
        setenv JOBNAME ${newname}
#       /bin/nice -7 csh ${E}pbs.csh >& ${newname}.log &
        csh ${E}pbs.csh >& ${newname}.log &
    else
#       kinit -R
#       qsub -N R${newname} -j oe -o R${newname}.log ${E}pbs.csh
#             -j oe -o R${newname}.log < ${E}pbs.csh
        sed -e "s/^#PBS  *-N .*/#PBS -N R${newname}/" -e "s/^#PBS  *-o .*/#PBS -o R${newname}.log/" ${E}pbs.csh >! ${E}pbs_$$.csh
        qsub    ${E}pbs_$$.csh
        /bin/rm ${E}pbs_$$.csh
    endif
else
C
C --- newname failed
C
    echo $newname
    echo $newname | wc -l
endif
C
C --- Exit.
C
exit
