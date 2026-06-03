# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #68.
#ERR Error (R14) : Calling Method without definition: removext

load "../../stzBase.ring"

pr()

	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveXT("♥♥♥", :AtPositions = [ 1, 9, 17 ])

	? o1.Content() #--> "ring ruby php"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.17
