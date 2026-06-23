# Narrative
# --------
# Backward-scanning removal: drop the Nth occurrence of a value located
# BEFORE a given position.
#
# Starting from a list with "A" at positions 1, 4, 6 and 8,
# RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6) scans
# leftward from position 6 and removes the 2nd "A" it encounters going
# backward (the one at position 4), leaving 7 items. The :Of and
# :StartingAt named directives make the intent read like a sentence, and
# Content() then returns the mutated list for inspection.
#
# Extracted from stzlisttest.ring, block #448.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemovePreviousNthOccurrence(2, :Of = "A", :StartingAt = 6)
	? Content() #--> [ "A", "-", "-", "-", "A", "-", "A" ]
}

pf()
# Executed in 0.01 second(s).
