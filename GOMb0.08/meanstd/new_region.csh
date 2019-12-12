#
set echo
#
# --- 1st pass at a new region, scripts may need further editing
#
setenv HO HYCOM-examples
setenv HN HYCOM-examples
#setenv HO hycom
#setenv HN hycom
setenv RO GLBt0.72
setenv RN GOMb0.08
#
mkdir -p ~/${HN}/${RN}/meanstd
#
# --- start in old directory
#
cd ~/${HO}/$RO/meanstd
foreach f ( *.csh )
# sed -e "s/${RO}/${RN}/g" -e "s?/${HO}/?/${HN}/?g" ${f} > ~/${HN}/${RN}/postproc/${f}
  sed -e "s/${RO}/${RN}/g" -e "s?/HYCOM-examples/?/${HN}/?g" ${f} > ~/${HN}/${RN}/meanstd/${f}
end
#
/bin/cp new_account.csh *.awk ${HN}/${RN}/meanstd
