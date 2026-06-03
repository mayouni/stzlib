# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #705.
#ERR Error (R14) : Calling Method without definition: partsusingxt

load "../../stzBase.ring"

pr()

o1 = new stzString("__b和平س__a_ووو")

? @@( o1.PartsUsingXT(' StzCharQ(@char).Script() ') )
#--> [ "__", "b", "和平", "س", "__", "a", "_", "ووو" ]

pf()
# Executed in 0.13 second(s) in Ring 1.22
