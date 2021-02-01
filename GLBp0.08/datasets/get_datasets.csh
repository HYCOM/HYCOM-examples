#!/bin/csh

set echo

# --- script to fetch GOMb0.08 datasets
# --- R is configuration name
# --- S is scratch directory
# --- DS is datasets directory
setenv R  GLBp0.08
setenv S  /p/work1/${user}
setenv DS ${S}/HYCOM-examples/${R}/datasets
mkdir -p ${DS}
cd ${DS}/

# --- get bottom drag file suitable for tidal simulation
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/relax_DRAG.tar.gz
tar xvf relax_DRAG.tar.gz

# --- get topo data
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo.tar.gz
tar xvf topo.tar.gz

# --- get TPXO9atlas Re/Im tidal signal and S.A.L.
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/TPXO9atlas.tar.gz
tar xvf TPXO9atlas.tar.gz




