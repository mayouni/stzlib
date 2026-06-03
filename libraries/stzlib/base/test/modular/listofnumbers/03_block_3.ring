# Narrative
# --------
# */
#
# Extracted from stzlistofnumberstest.ring, block #3.

load "../../../stzBase.ring"

pr()

o1 = new stzListOfNumbers([ 1, 2, 12, 20, 13, 25, 7, 14, 8, 5, 9 ])
? @@NL( o1.ClassifyByNearestTo([ 5, 10, 20 ]) )
#--> [
#	[ 5, [ 1, 2, 7 ] ],
#	[ 10, [ 12, 13, 14, 8, 9 ] ],
#	[ 20, [ 25 ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
