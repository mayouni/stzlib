# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #447.

load "../../../stzBase.ring"


StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content()
	#--> [ "A", "-", "-", "A", "-", "-", "A" ]
}

pf()
# Executed in almost 0 second(s).
