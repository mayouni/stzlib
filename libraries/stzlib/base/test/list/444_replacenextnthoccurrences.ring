# Narrative
# --------
# Replaces selected occurrences of a value, counted forward from a position.
#
# ReplaceNextNthOccurrences([1, 2], :of = "A", :with = "*", :StartingAt = 3)
# scans the list from index 3 onward, enumerates the occurrences of "A" it
# meets there (1st, 2nd, ...), and replaces only those whose ordinal is in
# [1, 2]. Starting at 3 the remaining "A"s sit at positions 3, 5, 7; the
# 1st and 2nd of THESE (positions 5 and 7) become "*", leaving the earlier
# "A"s untouched. NextNthOccurrencesReplaced is the non-mutating twin that
# returns the new list instead of editing in place.
#
# Extracted from stzlisttest.ring, block #444.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplaceNextNthOccurrences([1, 2], :of = "A", :with = "*",  :StartingAt = 3)
	? @@( Content() )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? @@( NextNthOccurrencesReplaced([1, 2], :Of = "A", :With = "*",  :StartingAt = 3 ) )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
