BEGIN { n = 1 ; o = 1 }
{
	output = $1 ; total = $2 ; projdata = $3


# at last, create an array of good particles, then subtract out the bad ones
	for(i=1;i<=total;i++)
		good[i] = 1
	"date +'%a %b %d %H:%M:%S %Y'" | getline date
	printf(" ; %s  %s   %s\n", projdata, output, date) > output
	for(i=1;i<=total;i++)
		if(good[i])
			printf(" %04d 2 %11.6f %11.6f\n", o++, i, 1.0) > output
}
