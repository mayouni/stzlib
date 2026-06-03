# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #603.

load "../../stzBase.ring"

pr()

o1 = new stzList( L(' "♥1" : "♥9" ') )
? @@SP( o1 / [ "Mansoor", "Teeba", "Haneen" ] )
#-->
# [
#	[ "Mansoor", 	[ "♥1", "♥2", "♥3" ] ],
#	[ "Teeba", 	[ "♥4", "♥5", "♥6" ] ],
#	[ "Haneen", 	[ "♥7", "♥8", "♥9" ] ]
# ]

pf()
# Executed in 0.17 second(s) in Ring 1.22
