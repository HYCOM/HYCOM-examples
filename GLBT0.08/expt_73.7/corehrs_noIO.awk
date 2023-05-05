#

BEGIN	{
	cores = -1
	}

/statistics/ {
	oldc = cores
	cores = $8
#	print "cores =" cores " oldc =" oldc
	next
	}

/zaiowr/	{
	w = $8
#	print "w = " w
	next
	}

/zaiord/	{
	r = $8
#	print "r = " r
	next
	}

/total/ {
	if (oldc == cores ) {
		printf("%s\t (%7.1f )\t%7.2f\t%7.2f core hrs\n", $0, $8-r-w, (cores*($8-r-w))/3600.0, (cores*(r+w))/3600.0)
		cores = -1
		}
	next
	}

	{
	printf("BAD INPUT LINE: $s\n", $0)
	}
