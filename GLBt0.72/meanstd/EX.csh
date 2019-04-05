#
set echo
#
# --- EX for awk
#
foreach f ( [ms]*.csh )
  /bin/mv ${f} ${f}++
  sed -e 's? r=? ex=${EX} r=?g' ${f}++ >  ${f}
end
