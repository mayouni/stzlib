# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #411.
#ERR Error (R14) : Calling Method without definition: endswithnumbern

load "../../stzBase.ring"

pr()

o1 = new stzString("Amount: +132.45")
? o1.EndsWithANumber()
#--> TRUE

? o1.EndsWithNumberN("132.45")
#--> TRUE

? o1.TrailingNumber()
#--> "+132.45"

pf()
# Executed in 0.04 second(s) in Ring 1.21
