#!/bin/csh

set echo

# --- script to fetch GLBt0.72 datasets
# --- R is configuration name
# --- S is scratch directory
# --- DS is datasets directory
setenv R  GLBt0.72
setenv S  /p/work1/${user}
setenv DS ${S}/HYCOM-examples/${R}/datasets
mkdir -p ${DS}
cd ${DS}/

# --- get atmospheric data, if not created on the fly
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_CORE2_6hrly.tar.gz
tar xvf force_CORE2_6hrly.tar.gz

# --- get rivers data, 
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_rivers.tar.gz
tar xvf force_rivers.tar.gz

# --- get seawifs data,
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/force_seawifs.tar.gz
tar xvf force_seawifs.tar.gz

# --- get relax T and S climatology data
# --- N.B.: can be created using ${R}/relax scripts with
# --- HYCOM-examples/datasets/WOA13_HYCOM or HYCOM-examples/datasets/PHC3_HYCOM
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_010.tar.gz
tar xvf relax_010.tar.gz

# --- get topo data
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo.tar.gz
tar xvf topo.tar.gz



