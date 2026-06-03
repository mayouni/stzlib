# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #445.

load "../../stzBase.ring"


StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrencesST([1, 2 ], :of = "A", :with = "*",  :StartingAt = 5)
	? @@( Content() )
	#--> [ "*" , "B", "*", "C", "*", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
