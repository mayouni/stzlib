# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #69.

load "../../stzBase.ring"


	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveAt([ 1, 9, 17 ], "♥♥♥") # Or RemoveSubstringAtPositions()

	? o1.Content()
	#--> "ring ruby php"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.17
