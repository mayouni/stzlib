# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #109.
#ERR Error (R14) : Calling Method without definition: nlistified

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 1:5, "hi!", StzNullObjectQ(), [ "a", "b" ] ])

? @@( o1.NListified(3) )
#--> [
#	[ 1, NULL, NULL ],
#	[ 1, 2, 3 ],
#	[ "hi!", NULL, NULL ],
#	[ @noname, NULL_, NULL ],
#	[ "a", "b", NULL ]
# ]

pf()
# Executed in 0.05 second(s)
