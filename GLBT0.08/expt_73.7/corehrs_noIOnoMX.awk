#

BEGIN	{
	cores = -1
	}

/statistics/ {
	oldc = cores
	cores = $8
 	print "cores =" cores " oldc =" oldc
	next
	}

/zaiowr/	{
	w = $8
 	print "w = " w
	next
	}

/zaiord/	{
	r = $8
 	print "r = " r
	next
	}

/xcmaxr/	{
	x = $8
 	print "x = " x
	next
	}

/total/ {
	if (oldc == cores ) {
 		print "r+w+x = " r+w+x
		printf("%s\t (%7.1f )\t%7.2f\t%7.2f\t%7.2f core hrs\n", $0, $8-r-w-x, (cores*($8-r-w-x))/3600.0, (cores*(r+w+x))/3600.0, (cores*x)/3600.0)
		cores = -1
		}
	next
	}

	{
	printf("BAD INPUT LINE: $s\n", $0)
	}
