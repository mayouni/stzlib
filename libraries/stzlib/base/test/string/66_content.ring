# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #66.

load "../../stzBase.ring"

pr()

	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveAt(6, "♥♥♥") # Or RemoveSubStringAtPosition()

	? o1.Content()
	#--> "ring ruby php"

pf()
# Executed in 0.01 second(s)
