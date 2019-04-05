#
set echo
#
# --- switch PBS account
#
foreach f ( [ms]*.csh )
  /bin/mv ${f} ${f}++
# sed -e "s/ ONRDC10855122/ NRLSS03755018/g"  ${f}++ >  ${f}
  sed -e "s/ NRLSS03755018/ ONRDC10855122/g"  ${f}++ >  ${f}
end
