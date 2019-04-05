#!/bin/csh

set echo

# --- script to fetch non domain-specific datasets
# --- S is scratch directory
# --- DS is datasets directory
setenv S /p/work1/${user}
setenv DS ${S}/HYCOM-examples/datasets
mkdir -p ${DS}
cd ${DS}/

# --- get CORE2 NYF data 
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/datasets/CORE2_NYF.tar.gz
tar xvf CORE2_NYF.tar.gz

# --- get WOA13 for HYCOM T and S climatology data
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/datasets/WOA13_HYCOM.tar.gz
tar xvf WOA13_HYCOM.tar.gz

# --- get PHC3 for HYCOM T and S climatology data
#wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/datasets/PHC3_HYCOM.tar.gz
#tar xvf PHC3_HYCOM.tar.gz




