# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #448.

load "../../stzBase.ring"


StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6)
	? Content() #--> [ "A", "-", "-", "-", "A", "-", "A" ]
}

pf()
# Executed in 0.01 second(s).
