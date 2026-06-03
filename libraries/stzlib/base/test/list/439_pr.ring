# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #439.

load "../../stzBase.ring"


StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrenceST(2, :Of = "A", :With = "*", :StartingAt = 2 )
	? Content()
	#--> [ "A" , "B", "C", "A", "D", "*" ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
