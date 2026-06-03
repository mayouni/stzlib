# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #449.

load "../../stzBase.ring"


StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 2)
	? Content() #--> [ "A" , "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 2)
	#--> [ "A" , "B", "A", "C", "D" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
