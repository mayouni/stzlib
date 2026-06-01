# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #72.

load "../../../stzBase.ring"


	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceXT("ring", :AtPositions = [ 1, 20 ], :By = "♥♥♥")

	? o1.Content() #--> "♥♥♥ ruby ring php ♥♥♥"

pf()
# Executed in 0.14 second(s)
