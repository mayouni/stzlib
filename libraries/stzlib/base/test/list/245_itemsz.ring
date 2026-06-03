# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #245.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ])
? @@( o1.ItemsZ() ) # Or ItemsAndTheirPositions()
#--> [
#	[ "Ab", [ 1, 3, 6 ] ],
#	[ "Im", [ 2 ] ],
#	[ "Cf", [ 4, 7 ] ],
#	[ "Fd", [ 5 ] ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.8
