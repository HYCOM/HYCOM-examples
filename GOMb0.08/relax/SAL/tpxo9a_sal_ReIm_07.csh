#
set echo
#
# --- fill in any SAL data voids for target bathymetry
#
cd       ~/HYCOM-examples/GOMb0.08/relax/SAL
#
setenv X ~/HYCOM-examples/GOMb0.08/TPXO9atlas
setenv T ~/HYCOM-examples/GOMb0.08/topo
#
/bin/rm -f       tpxo9a_sal_ReIm_07.a
hycom_fill    $X/tpxo9a_sal_hReIm_GLBp.a $T/depth_GOMb0.08_07.a 263 193 tpxo9a_sal_ReIm_07.a 99 >! tpxo9a_sal_ReIm_07.B
cut -c 1-8    $X/tpxo9a_sal_hReIm_GLBp.b   >! tpxo9a_sal_ReIm_07.B1
grep "min"       tpxo9a_sal_ReIm_07.B >! tpxo9a_sal_ReIm_07.B2
paste tpxo9a_sal_ReIm_07.B1 tpxo9a_sal_ReIm_07.B2 >! tpxo9a_sal_ReIm_07.b
#
hycom_sea_ok $T/depth_GOMb0.08_07.a tpxo9a_sal_ReIm_07.a 263 193
