# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #43.

load "../../stzBase.ring"

pr()

o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? o1.BoundsOf("Ring")
#--> [ ["<<<", ">>>"], [ "(((", ")))" ] ]

? o1.BoundsOfXT("Ring", :UpToNChars = 2) # Or BoundsOfUpToNChars()
#--> [ ["<<", ">>"], [ "((", "))" ] ]

pf()
# Executed in 0.03 second(s).
