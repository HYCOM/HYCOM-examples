#
# Usage: echo $cwd | awk -f depth.awk
# Returns: bathymetry filename
#
	{
	n = split($0,d,"/")
	printf("depth_%s_%s\n", d[n-3],d[n])
	}
