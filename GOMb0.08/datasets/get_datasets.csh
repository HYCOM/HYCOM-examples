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
#wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_CORE2_6hrly.tar.gz
#tar xvf force_CORE2_6hrly.tar.gz

# --- get wind-stress offset
# --- N.B.: can be created using ${R}/force/offset
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_offset.tar.gz
tar xvf force_offset.tar.gz

# --- get rivers data, 
# --- N.B.: can be created using ${R}/force/rivers
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_rivers.tar.gz
tar xvf force_rivers.tar.gz

# --- get seawifs data,
# --- N.B.: can be created using ${R}/force/seawifs
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_seawifs.tar.gz
tar xvf force_seawifs.tar.gz

# --- get relax T and S climatology data
# --- N.B.: can be created using ${R}/relax scripts with
# --- HYCOM-examples/datasets/WOA13_HYCOM or HYCOM-examples/datasets/PHC3_HYCOM
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_010.tar.gz
tar xvf relax_010.tar.gz

# --- get bottom drag files
# --- N.B.: can be created using ${R}/relax/DRAG scripts
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_DRAG.tar.gz
tar xvf relax_DRAG.tar.gz

# --- get SSSRMX file
# --- N.B.: can be created using ${R}/relax/SSSRMX scripts
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_SSSRMX.tar.gz
tar xvf relax_SSSRMX.tar.gz

# --- get nest files
# --- N.B.: can be created using GLBb0.08/subregion scripts with
# --- HYCOM-examples/datasets/nest
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/subregion.tar.gz
tar xvf subregion.tar.gz

# --- get topo data
# --- N.B.: can be created using ${R}/topo
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo.tar.gz
tar xvf topo.tar.gz



