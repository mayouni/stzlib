# Narrative
# --------
# WORKING WITH MARQUERS
#
# Extracted from stzStringTest.ring, block #606.

load "../../../stzBase.ring"


pr()

? StzStringQ("My name is #.").ContainsMarquers()
#--> FALSE

? StzStringQ("My name is #0.").ContainsMarquers()
#--> TRUE

? StzStringQ("My name is #1.").ContainsMarquers()
#--> TRUE

? StzStringQ("My name is #01.").ContainsMarquers()
#--> TRUE

? @@( Q("bla #0 bla bla #1 bla #2 blabla").Marquers() )
#--> [ "#0", "#1", "#2" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.53 second(s) in Ring 1.14
