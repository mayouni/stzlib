# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #446.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrencesST([3, 1], "A", :With = [ "#3", "#1" ], :StartingAt = 6)
	? @@( Content() )
	#--> [ [ "#3", "#1" ], "B", "A", "C", [ "#3", "#1" ], "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
