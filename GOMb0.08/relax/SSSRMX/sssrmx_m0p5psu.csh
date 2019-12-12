#

set echo
set time = 1
C
C --- Generate HYCOM spacially varying sssrmx.
C --- Version for constant sssrmx.
C
source ~/HYCOM-examples/GOMb0.08/relax/EXPT.src
cd ${DS}/relax/
mkdir -p SSSRMX
cd SSSRMX

cat <<'E-o-D' >! sssrmx_m0p5psu.b
Maximum SSS difference for relaxation (psu); negative to stop relaxing at -val.
-0.5 everywhere



  sssrmx: range =   -0.5000   -0.5000
'E-o-D'
C
C --- constant field does not need an .a file
C
echo "Dummy File" >! sssrmx_m0p5psu.a
