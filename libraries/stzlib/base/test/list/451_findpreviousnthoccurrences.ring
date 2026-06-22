# Narrative
# --------
# Finding and removing chosen ordinal occurrences while scanning backward.
#
# In [ "A", "B", "A", "C", "A", "D", "A" ] the value "A" sits at positions
# 1, 3, 5, 7. Starting at position 6 and looking toward the head, the
# occurrences encountered are counted 1st, 2nd, 3rd... going backward.
# FindPreviousNthOccurrences([2,3], "A", 6) asks for the 2nd and 3rd such
# previous occurrences, which land at positions 3 and 5. The Remove* form
# deletes exactly those occurrences in place (Content() then shows the list
# minus the "A" at 3 and 5), and PreviousNthOccurrencesRemoved is the
# non-mutating sibling that returns the pruned list. The named :of and
# :StartingAt arguments make the intent read like prose.
#
# Extracted from stzlisttest.ring, block #451.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindPreviousNthOccurrences([2, 3], "A", 6)
	#--> [ 3, 5 ]

	RemovePreviousNthOccurrences([2, 3], :of = "A", :StartingAt = 6)
	? Content()
	#--> [ "A", "B", "C", "D", "A" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? PreviousNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 6)
	#--> [ "A", "B", "C", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
