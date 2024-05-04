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
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/CORE2_NYF.tar.gz
#tar xvf CORE2_NYF.tar.gz

# --- get CFSR data for Gulf of Mexico region (1994-2010)
wget http://data..hycom.org/pub/GitHub/HYCOM-examples/datasets/CFSR_GOM.tar.gz
tar xvf CFSR_GOM.tar.gz

# --- get CFSv2 data for Gulf of Mexico region (2011-2018)
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/CFSv2_GOM.tar.gz
#tar xvf CFSv2_GOM.tar.gz

# --- get WOA13 for HYCOM T and S climatology data
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/WOA13_HYCOM.tar.gz
tar xvf WOA13_HYCOM.tar.gz

# --- get WOA18 for HYCOM T and S climatology data
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/WOA18_HYCOM.tar.gz
#tar xvf WOA18_HYCOM.tar.gz

# --- get PHC3 for HYCOM T and S climatology data
#wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/PHC3_HYCOM.tar.gz
#tar xvf PHC3_HYCOM.tar.gz

# --- get HYCOM Reanalysis 53.X global files (to create nest files if necessary)
mkdir -p nest
# --- get monthly mean from GLBb0.08 53.X reanalysis (for nest)
wget http://data.hycom.org/datasets/GLBb0.08/expt_53.X/data/meanstd/53X_archMN.1994_*_2015_*.[ab]

# --- get a January monthly means from GLBb0.08 53.X reanalysis (for restart)
wget http://data.hycom.org/datasets/GLBb0.08/expt_53.X/data/meanstd/53X_archMN.1994_01.[ab]
cd ../

# --- get raw data for Chlorophyll (if needed)
wget http://data.hycom.org/pub/GitHub/HYCOM-examples/datasets/seawifs.tar.gz
tar xvf seawifs.tar.gz


