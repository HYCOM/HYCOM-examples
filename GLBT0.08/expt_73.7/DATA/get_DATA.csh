#!/bin/csh

set echo

# --- script to fetch GLBT0.08 benchmark datasets
# --- R is configuration name
# --- S is scratch directory
# --- DS is datasets directory
setenv R  GLBT0.08
setenv S  /p/work1/${user}
setenv DS ${S}/HYCOM-examples/
mkdir -p ${DS}
cd ${DS}/

# --- get GLBT0.08 input files
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA1.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA1.tar.lis
tar xvf GLBT0.08_737_DATA1.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA2.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA2.tar.lis
tar xvf GLBT0.08_737_DATA2.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA3.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA3.tar.lis
tar xvf GLBT0.08_737_DATA3.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA4.tar.gz
wget ftp://ftp.hycom.org/pub/GitHub/HYCOM-examples/${R}/datasets/GLBT0.08_737_DATA4.tar.lis
tar xvf GLBT0.08_737_DATA4.tar.gz

