#!/bin/csh

set echo

# --- script to fetch GOMb0.08 datasets
# --- R is configuration name
# --- S is scratch directory
# --- DS is datasets directory
setenv R  GOMb0.08
setenv S  /p/work1/${user}
setenv DS ${S}/HYCOM-examples/${R}/datasets
mkdir -p ${DS}
cd ${DS}/

# --- get atmospheric data, if not created on the fly
#wget htts://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_CORE2_6hrly.tar.gz
#tar xvf force_CORE2_6hrly.tar.gz

# --- get wind-stress offset
# --- N.B.: can be created using ${R}/force/offset
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_offset.tar.gz
tar xvf force_offset.tar.gz

# --- get rivers data, 
# --- N.B.: can be created using ${R}/force/rivers
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_rivers.tar.gz
tar xvf force_rivers.tar.gz
# --- depth_07 and 15 have the same rivers
ln -s $cwd/force/rivers/rivers_07.a force/rivers/rivers_15.a
ln -s $cwd/force/rivers/rivers_07.b force/rivers/rivers_15.b

# --- get seawifs data,
# --- N.B.: can be created using ${R}/force/seawifs
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_seawifs.tar.gz
tar xvf force_seawifs.tar.gz

# If using Nest file from GOFS3.1 1994-Aug 2024 and expt_01.0,expt_01.1,expt_01.2 and expt_01.3 
#
## --- get relax T and S climatology data
## --- N.B.: can be created using ${R}/relax scripts with
## --- HYCOM-examples/datasets/WOA13_HYCOM or HYCOM-examples/datasets/PHC3_HYCOM
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_010.tar.gz
#tar xvf relax_010.tar.gz
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_014.tar.gz
tar xvf relax_014.tar.gz
#
## --- get SSH files
## --- N.B.: can be created using ${R}/relax/SSH scripts
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SSH.tar.gz
#tar xvf relax_SSH.tar.gz
#
## --- get bottom drag files (and tidal drag files)
## --- N.B.: can be created using ${R}/relax/DRAG scripts
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_DRAG.tar.gz
#tar xvf relax_DRAG.tar.gz
#
## --- for tidal simulation
## # --- N.B.: can be created using ${R}/relax/SAL scripts
## #wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SAL_tides.tar.gz
## #tar xvf relax_SAL_tides.tar.gz
#
## --- get SSSRMX file
## --- N.B.: can be created using ${R}/relax/SSSRMX scripts
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SSSRMX.tar.gz
#tar xvf relax_SSSRMX.tar.gz
#
## --- get nest files
## --- N.B.: can be created using GLBb0.08/subregion scripts with
## --- HYCOM-examples/datasets/nest
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/subregion.tar.gz
#tar xvf subregion.tar.gz
#
## --- get topo data
## --- N.B.: can be created using ${R}/topo
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo.tar.gz
#tar xvf topo.tar.gz

# If using nest files from ESPC-D-V02/ GLby0.08 Sept 2024 to present and expt_01.4

# --- get relax T and S climatology data
# --- N.B.: can be created using ${R}/relax scripts with
# --- HYCOM-examples/datasets/WOA13_HYCOM or HYCOM-examples/datasets/PHC3_HYCOM
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_014_T15.tar.gz
tar xvf relax_014_T15.tar.gz

# --- get SSH files
# --- N.B.: can be created using ${R}/relax/SSH scripts
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SSH_T15.tar.gz
tar xvf relax_SSH_T15.tar.gz

# --- get bottom drag files (and tidal drag files)
# --- N.B.: can be created using ${R}/relax/DRAG scripts
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_DRAG_T15.tar.gz
tar xvf relax_DRAG_T15.tar.gz

# --- for tidal simulation
# # --- N.B.: can be created using ${R}/relax/SAL scripts
# #wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SAL_T15.tar.gz
# #tar xvf relax_SAL_T15.tar.gz

# --- get SSSRMX file
# --- N.B.: can be created using ${R}/relax/SSSRMX scripts
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SSSRMX.tar.gz
tar xvf relax_SSSRMX.tar.gz

# --- get nest files (DAILY)
# --- N.B.: can be created using GLBy0.08/subregion scripts
# --- data available from 2024/09 to 2025/05,i.e. 124i,124j,124k,124l,125a,125b,125c,125d,125e 
# --- HYCOM-examples/datasets/nest
mkdir -p nest
cd       nest
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/subregion_espc/archm_124i_espc.tar.gz
tar xvf archm_124i_espc.tar.gz
cd ../

# --- get topo data
# --- N.B.: can be created using ${R}/topo
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo_espc.tar.gz
tar xvf topo_espc.tar.gz
