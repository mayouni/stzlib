# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #440.

load "../../../stzBase.ring"


StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of = "A", :By = "*", :StartingAt = 5)
	? Content() #--> [ "*" , "B", "C", "A", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
