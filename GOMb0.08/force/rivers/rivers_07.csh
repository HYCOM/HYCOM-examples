#!/bin/csh
#
set echo
set time = 1
C
C --- Create HYCOM monthly rivers file.
C --- Global version, includes hycom_arctic with region-specific idm jdm

C --- set copy command
if (-e ~${user}/bin/pget) then
C --- remote copy
  setenv pget ~${user}/bin/pget
  setenv pput ~${user}/bin/pput
else
C --- local copy
  setenv pget cp
  setenv pput cp
endif

C
C --- P is primary path,
C --- S is scratch directory,
C --- D is permanent directory,
C --- T is topog. identifier,
C
C
setenv DS /p/work1/${user}/HYCOM-examples/GOMb0.08/datasets
setenv D ${DS}/force/rivers
setenv P ${DS}/force/rivers
setenv S ${P}/SCRATCH
setenv T 07
C
mkdir -p $S
cd       $S
C
C --- Input.
C
touch regional.grid.a regional.grid.b
if (-z regional.grid.b) then
  ${pget} ${DS}/topo/regional.grid.b regional.grid.b &
endif
if (-z regional.grid.a) then
  ${pget} ${DS}/topo/regional.grid.a regional.grid.a &
endif
C
touch fort.51 fort.51A
if (-z fort.51) then
  ${pget} ${DS}/topo/depth_GOMb0.08_${T}.b fort.51 &
endif
if (-z fort.51A) then
  ${pget} ${DS}/topo/depth_GOMb0.08_${T}.a fort.51A &
endif
C
#${pget} ${D}/../../../ALL/force/src/pcip_riv_mon . &
cp ~/HYCON-tools/force/src/pcip_riv_mon . &
wait
chmod a+rx pcip_riv_mon
C
/bin/rm -f fort.14*
C
setenv FOR014A fort.14A
setenv FOR051A fort.51A
C
/bin/rm -f core
touch core
C
./pcip_riv_mon <<'E-o-D'
 &RTITLE
  CTITLE = '1234567890123456789012345678901234567890123456789012345678901234567890123456789',
  CTITLE = 'Mississippi(2),Atchafalaya,Usumacinta,Mobile,Papaloapan,Apalachicola,',
           'and 27 others',
           ' ',
 /
 &RIVERS
  NRIVERS =   34,
  NSMOOTH =    5,
  MAXDIST =   30,
  IGNORE  = .TRUE.,
  IJRIVER =  
  113  152
  110  150
   85  157
   70    8
  126  173
   31    9
  163  160
   70    8
    4   57
   46    2
  118  169
  108  167
   54  160
   41  159
  186  154
   13   33
   34  148
  136  169
   54  160
   70    8
   12  107
   28  145
   20  140
   11   37
   22   17
   12   36
    8   39
   82   10
   10  134
  176   53
  220   53
  188   61
  185   58
  202   69
  TSCALE  = 1.E-6, !m^3/s to Sv
  TRIVER  =    
    6956.0    8390.3    9974.7   11056.3   10116.2    7961.3
    5778.1    3938.9    3172.9    3379.6    3825.6    5527.5
    6956.0    8390.3    9974.7   11056.3   10116.2    7961.3
    5778.1    3938.9    3172.9    3379.6    3825.6    5527.5
    6708.3    6858.4    8486.6   10129.0    9361.6    7201.0
    4757.3    3279.1    2785.8    3349.9    4077.7    6374.2
    1546.7    1259.9    1009.9     746.7     749.8    1900.0
    3076.5    3351.8    4390.8    4427.7    3172.8    2435.0
    1616.0    2091.2    1727.6    2119.2     982.3     463.8
     312.1     297.6     266.9     359.1     337.8    1129.0
     609.2     571.1     527.5     553.0     539.2    1056.2
    1450.6    1494.8    1742.1    1165.6     797.2     653.4
     876.1    1200.4    1326.7    1027.9     698.9     546.2
     608.0     541.7     459.0     436.6     464.1     691.2
     349.0     359.4     228.5     240.3     267.0     466.3
     849.5    1002.4    1319.5    1067.1     562.7     391.6
     173.2     144.9     130.0     121.6     154.1     437.5
     832.8     749.9    1383.9    1022.5     381.8     239.9
     234.2     175.4     119.0      80.2      71.8     258.0
     599.2     940.2    1129.8     610.0     384.0     357.0
     435.2     528.1     573.4     529.8     305.3     149.9
     148.2     112.9     101.5      85.8     142.5     285.2
     434.4     559.8     585.6     547.9     348.6     160.0
     127.3     104.1      81.7      83.4     118.8     278.9
     323.7     371.9     351.3     348.1     351.9     251.7
     147.2     122.5     112.3      65.2      80.8     254.6
     200.7     241.7     268.8     301.2     365.0     319.0
     118.7      62.5      76.6     117.3     179.4     217.8
     289.2     288.5     311.3     298.9     252.1     184.9
     107.3      93.0     105.3     119.4     140.4     225.1
      98.9      83.4      70.5      62.6      89.1     226.0
     281.0     337.5     450.0     379.8     192.2     107.5
     164.7     223.2     199.7     265.6     457.4     327.1
     142.7      69.1     101.6     131.6     160.3     150.6
     271.9     359.6     377.8     349.6     188.6     148.3
      84.6     121.1      85.2      80.8      76.5     147.9
     182.4     234.0     227.5     260.5     246.7     231.4
     142.4     101.7      88.3      74.8      84.7     141.6
     131.3     143.6     131.7     150.0     150.3     154.3
     124.0     120.0     116.5     161.7     178.0     166.7
     147.7     147.3     159.0     152.7     128.7      94.4
      54.8      47.5      53.8      61.0      71.7     114.9
     105.9     105.6     114.0     109.4      92.3      67.7
      39.3      34.1      38.5      43.7      51.4      82.4
      84.8      84.5      91.2      87.6      73.9      54.2
      31.5      27.3      30.9      35.0      41.2      66.0
      50.8      36.8      31.2      24.6      28.1      64.6
      55.8      60.8     107.2      98.4      71.6      47.6
      32.2      33.2      21.1      22.2      24.7      43.1
      78.5      92.6     121.9      98.6      52.0      36.2
      13.7      11.5       9.6       7.8      14.1      45.0
      73.0      95.2     122.2      86.6      41.1      19.8
      21.6      17.9      16.4      14.1      21.4      61.5
     124.0      47.5       0.0      58.0      87.5      54.9
      29.7      19.9      19.4      16.4      15.0      20.2
      33.6      33.6      61.7      99.1      86.3      64.7
       9.7       6.9       5.4      10.9      37.5      36.7
      19.8      29.1      63.6      58.8      14.8       7.5
       4.8       4.0       2.9       4.0      12.3      26.1
      13.4      11.7      17.8      19.7      12.2       5.6
       1.9       1.6       1.5       1.1       6.8      27.7
      13.0       9.6      19.2      18.9       5.4       2.3
       1.4       1.4       1.1       1.6       3.2       7.1
       4.1       3.3       5.1       6.3       2.7       1.5
       0.9       0.7       0.6       1.1       2.9       8.0
       4.4       4.9       5.6       4.1       2.5       1.0
       0.7       0.6       0.4       0.6       1.9       4.0
       2.1       1.8       2.7       3.0       1.9       0.9
 /
'E-o-D'
C
C --- Output.
C
mv fort.14  rivers_${T}.b
mv fort.14A rivers_${T}.a
#${pput} rivers_${T}.b ${D}/rivers_${T}.b
#${pput} rivers_${T}.a ${D}/rivers_${T}.a
C
C --- Delete all files.
C
#/bin/rm -f core* fort.* regional.grid.* pcip_riv_mon
