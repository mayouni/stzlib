# Narrative
# --------
# o1 = new stzList(
#
# Extracted from stzlisttest.ring, block #257.

load "../../stzBase.ring"

pr()

	1:10 + //0_000 +
	10 +
	"10" +
	[1, 2, 3] +
	'[1, 2, 3]' +
	
	[1, 2, 3] +
	10 +
	'[ 1* 2* 3 ]'
)

//? o1.ContainsDuplicates()
#--> TRUE

? @@( o1.FindDuplicates() )
#--> [
#	[ "10", [ 10, 10001 ] ],
#	[ "100", [ 100, 10002 ] ],
#	[ "1000", [ 1000, 10003 ] ]
# ]

pf()
# Executed in 2.19 second(s)
