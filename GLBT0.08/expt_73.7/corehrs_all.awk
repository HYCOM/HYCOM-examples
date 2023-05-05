#

BEGIN	{
	cores = -1
	}

/statistics/ {
	oldc = cores
	cores = $8
#	print "cores =" cores " oldc =" oldc
	if (oldc == cores) print
	next
	}

/time =/ {
	if (oldc == cores)
		printf("%s\t%7.2f core hrs\n", $0, (cores*$8)/3600.0)
	next
	}

	{
	printf("BAD INPUT LINE: $s\n", $0)
	}
