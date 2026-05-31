# Narrative
# --------
# #perf
#
# Extracted from stzlisttest.ring, block #246.

load "../../../stzBase.ring"


pr()

# ItemsAndTheirPositions(), also called ItemsZ(), can do
# the job in a reasonable performance when the number of
# items in the list is around 1000 items

o1 = new stzList(1:1_000 + 3 + 5 + 7 + 10 + 100 + 1000)
ShowShort( o1.ItemsZ() )
#--> [
#	[ 1, [ 1 ] ],
#	[ 2, [ 2 ] ],
#	[ 3, [ 3, 10001 ] ],
#	"...",
#	[ 998, [ 998 ] ],
#	[ 999, [ 999 ] ],
#	[ 1000, [ 1000, 1006 ]
# ]

pf()
# Executed in 1.09 second(s) in Ring 1.21
