# Narrative
# --------
# Replaces selected previous (backward) occurrences of a value, each with its own substitute.
#
# Starting just before position 6 and scanning backward, ReplacePreviousNthOccurrencesST
# targets the 3rd-previous and 1st-previous occurrences of "A" (counting "A"s that lie
# before the start) and swaps them for the parallel list [ "#3", "#1" ]. The Nth selector
# [3, 1] is paired by index with the :With list, so the 3rd-back "A" becomes "#3" and the
# 1st-back "A" becomes "#1". Untargeted "A"s and all other items are left untouched, and a
# replacement may itself be a nested list ([ "#3", "#1" ]), which the list engine inserts
# verbatim as a single element.
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
