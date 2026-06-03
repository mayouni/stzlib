# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #73.

load "../../stzBase.ring"

pr()

	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceAt([ 1, 20 ], "ring", :By = "♥♥♥") # Or ReplaceSubstringAtPositions()

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

pf()
# Executed in 0.07 second(s)
