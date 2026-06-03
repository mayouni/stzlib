# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #447.
#ERR Error (R3) : Calling Function without definition: removenextnthoccurrence

load "../../stzBase.ring"

pr()

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content()
	#--> [ "A", "-", "-", "A", "-", "-", "A" ]
}

pf()
# Executed in almost 0 second(s).
