#
# --- awk script that returns the model day and yrflag (3) 
# --- of the monthly nested archive identified by y01 and ab.
# --- result can be piped into hycom_wind_date to identify the archive file.
#
# --- Usage:  echo "" | awk -f nest_mon.awk y01=002 ab=c | hycom_wind_date
#
# --- Based on the standard model script for actual months
#

BEGIN { np = 12
        nd = 365
	ti = 366/np
	nq = np
	for ( i=0; i < nq; i++) {
		cb[sprintf("%c",i+97)] = sprintf("%c",i+98)
		ia[sprintf("%c",i+97)] = i
		}
	cb[sprintf("%c",nq+96)] = "a"
#		actual calendar months, non-leap year
		mf["a"] =   0
		ml["a"] =  31
		mf["b"] =  31
		ml["b"] =  59
		mf["c"] =  59
		ml["c"] =  90
		mf["d"] =  90
		ml["d"] = 120
		mf["e"] = 120
		ml["e"] = 151
		mf["f"] = 151
		ml["f"] = 181
		mf["g"] = 181
		ml["g"] = 212
		mf["h"] = 212
		ml["h"] = 243
		mf["i"] = 243
		ml["i"] = 273
		mf["j"] = 273
		ml["j"] = 304
		mf["k"] = 304
		ml["k"] = 334
		mf["l"] = 334
		ml["l"] = 365
}

END	{
#
# ---  based on the LIMITS case of the standard model awk script
#
		Y01 = int(y01)
#		model day = wind day = days since Jan 1st 1901
		ty = nd*(Y01-1) + (Y01-1 - (Y01-1)%4)/4 + 1
#		actual calendar months
		ts = ty + mf[ab]
#                      allow for leap years
		if (Y01%4 == 0 && mf[ab] > 40 ) 
			ts = ts + 1

#		actual calendar months
		tm = ty + ml[ab]
		if (Y01%4 == 0 && ml[ab] > 40 ) 
			tm = tm + 1
		printf( " %14.5f 3\n",  0.5*(ts+tm) )
}
