#

/zaiord/ {
	zr = $8
#	print "zr =" zr
	next
	}

/zaiowr/ {
	zw = $8
#	print "zw =" zw
	next
	}

/xc/	{
	xc = $8
#	print "xc =" xc
	next
	}

/total/ {
	printf("%s\t%5.2f (%5.2f) wall mins\n", $0, $8/60.0, ($8-za-zw-xc)/60.0 )
	next
	}

	{
	printf("BAD INPUT LINE: $s\n", $0)
	}
