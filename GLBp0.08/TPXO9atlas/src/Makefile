# Makefile created by mkmf $Id: mkmf,v 4.18 2002/08/09 18:21:53 vb Exp $ 
# hand edited by Alan Wallcraft, 01/24/2013

include ./template_gfortran

.DEFAULT:
	-touch $@

all: calcSAL.x

shsec.o: shsec.f
	$(FC) $(FFLAGS) -c	shsec.f
hrfft.o: hrfft.f
	$(FC) $(FFLAGS) -c	hrfft.f
sphcom.o: sphcom.f
	$(FC) $(FFLAGS) -c	sphcom.f
shaec.o: shaec.f
	$(FC) $(FFLAGS) -c	shaec.f
calcSAL.o: calcSAL.f
	$(FC) $(FFLAGS) -c	calcSAL.f

SRC = shsec.f hrfft.f sphcom.f shaec.f calcSAL.f
OBJ = shsec.o hrfft.o sphcom.o shaec.o calcSAL.o

clean: 
	-rm -f $(OBJ) calcSAL.x

calcSAL.x: $(OBJ)
	$(LD) $(OBJ) -o calcSAL.x $(LDFLAGS)
