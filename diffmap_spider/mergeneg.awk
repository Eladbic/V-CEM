BEGIN { n = 1 ; o = 1 }
{
	win = $1 ; output = $2 ; total = $3

# first, grab the project/data extenstion from the first input file
	getline < win
	projdata = $2

# next, read in the reference numbers for the bad images
	while( (getline < win) > 0 ) {
		if( $1 != ";" )
			bad[n++] = int($3)
	}

# at last, create an array of good particles, then subtract out the bad ones
	for(i=1;i<=total;i++)
		good[i] = 1
	for(i=1;i<n;i++)
		good[bad[i]] = 0
#	date = strftime("%a %b %d %H:%M:%S %Y")
	"date +'%a %b %d %H:%M:%S %Y'" | getline date
	printf(" ; %s  %s   %s\n", projdata, output, date) > output
	for(i=1;i<=total;i++)
		if(good[i])
			printf(" %04d 2 %11.6f %11.6f\n", o++, i, 1.0) > output
# alternately (??) :
#		printf(" %04d 2 %11.6f %11.6f\n", o++, i, good[i]) > output
}
