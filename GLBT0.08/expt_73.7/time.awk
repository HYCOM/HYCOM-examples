#
# --- Given an input file containing 2 or more output strings from the 
# --- date command (greped from .log files); 
# --- appends the delta-time in mins between dates.
#
# --- Typical usage:  egrep " ..:..:.. " *.log /dev/null | awk -f d2m.awk
#
# --- the "/dev/null" forces egrep to always print the filename.
#
# --- Alan J. Wallcraft, NRL, September 1997.
#

/ [0-9][0-9]:[0-9][0-9]:[0-9][0-9] /	{ 
	n = split($1,file,":")
	fnew = file[1]
	n = split($4,time,":")
	wnew = (time[1]*60+time[2]+time[3]/60)
	if (fold != fnew)
		print
	else {
		if (wold > wnew ) 
			winc = (24*60 + wnew) - wold
		else
			winc = wnew  - wold
		printf("%s\t%5.2f wall mins\n", $0, winc)
	}
	fold = fnew
	wold = wnew
	next
}

	{ next }
