#
BEGIN	{
	n = 0
	}

	{ 
	n = n + 1
#	print "n = " n
	if (n == 2) {
		printf("%s\t%5.2f wall mins\n", $0, $8/60.0 )
		n= 0
		}
	}
