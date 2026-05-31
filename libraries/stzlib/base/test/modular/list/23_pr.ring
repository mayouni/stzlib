# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #23.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? @@( o1.IndexCS(FALSE) )
#--> [
#	[ "a", [ 1, 3 ] ],
#	[ "b", [ 2, 6, 7 ] ],
#	[ "c", [ 4 ] ],
#	[ "d", [ 5 ] ]
# ]

#NOTE: When casesitivity is used, all items are turned to lowercase in the output

pf()
# Executed in 0.03 second(s)
