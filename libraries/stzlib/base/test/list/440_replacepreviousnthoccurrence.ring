# Narrative
# --------
# ReplacePreviousNthOccurrence scans a list backward from a start
# position and replaces the Nth matching value it meets.
#
# Here the list [ "A", "B", "C", "A", "D", "A" ] is searched for "A"
# starting at position 5, moving toward the front. The 1st previous "A"
# sits at position 4 and the 2nd at position 1, so the 2nd-previous
# match (position 1) is rewritten to "*", yielding
# [ "*", "B", "C", "A", "D", "A" ]. This mirror of the forward
# Replace*NthOccurrence family lets callers count matches from the
# right of an anchor point instead of from the list head.
#
# Extracted from stzlisttest.ring, block #440.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplacePreviousNthOccurrence(2, :of = "A", :By = "*", :StartingAt = 5)
	? Content() #--> [ "*", "B", "C", "A", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
