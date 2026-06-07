# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #767.

load "../../stzBase.ring"

pr()

o1 = new stzString("exeeeeeTUNIS")
 	
? @@( o1.RepeatedLeadingChar() )
#--> ""

? @@( o1.RepeatedLeadingChars() )
#--> ""

pf()
# Executed in 0.01 second(s).
