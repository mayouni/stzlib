# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #43.
#ERR Error (R14) : Calling Method without definition: boundsof

load "../../stzBase.ring"

pr()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<<", ">>>"], [ "(((", ")))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()
#--> [ ["<<", ">>"], [ "((", "))" ] ]

pf()
# Executed in 0.03 second(s).
