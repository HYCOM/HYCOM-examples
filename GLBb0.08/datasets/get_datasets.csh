#!/bin/csh

set echo

# --- script to fetch GLBb0.08 datasets
# --- R is configuration name
# --- S is scratch directory
# --- DS is datasets directory
setenv R  GLBb0.08
setenv S  /p/work1/${user}
setenv DS ${S}/HYCOM-examples/${R}/datasets
mkdir -p ${DS}
cd ${DS}/

# --- get topo 
wget "http://data.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/topo.tar.gz"
tar xvf topo.tar.gz

