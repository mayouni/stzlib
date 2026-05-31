# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #255.

load "../../../stzBase.ring"


aList = 1 : 30_000
aList + 1 + "*" + 10:12 + "B" + 2 + 1 + "*" + "A," + 3 + "*" + "B" + 10:12 + "B" + "A,"

o1 = new stzList(aList)
? @@(o1.DuplicatesZ())
#--> [
#	[ 1, [ 30001, 30006 ] ],
#	[ 2, [ 30005 ] ],
#	[ 3, [ 30009 ] ],
#	[ "*", [ 30007, 30010 ] ],
#	[ [ 10, 11, 12 ], [ 30012 ] ],
#	[ "B", [ 30011, 30013 ],
#	[ "A,", [ 30014 ] ]
# ]

pf()
# Executed in 10.70 second(s)
