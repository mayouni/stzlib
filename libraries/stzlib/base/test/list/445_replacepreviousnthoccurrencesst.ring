# Narrative
# --------
# ReplacePreviousNthOccurrencesST targets specific previous occurrences of a
# value, selected by their ordinal rank, that lie before a starting position.
#
# Here the list is [A,B,A,C,A,D,A]. Scanning the occurrences of "A" that come
# BEFORE position 5, we find them at positions 1 and 3 (the A at 5 is the start
# anchor, not a "previous" hit). The panList [1,2] selects the 1st and 2nd of
# those previous occurrences -- i.e. positions 1 and 3 -- and rewrites each to
# "*", yielding [*,B,*,C,A,D,A]. A 2-element selector can therefore touch at
# most two cells; the older recorded 3-replacement variant is impossible.
#
# Extracted from stzlisttest.ring, block #445.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplacePreviousNthOccurrencesST([1, 2 ], :of = "A", :with = "*",  :StartingAt = 5)
	? @@( Content() )
	# Corrected: panList=[1,2] indexes the previous occurrences of "A"
	# before position 5, which are at [1,3] (A at 1 and 3; A at 5 is the
	# start, not "previous"). So indices 1,2 -> positions 1,3. The old
	# recorded output [*,B,*,C,*,D,A] (3 replacements) is impossible from
	# a 2-element panList -- confirmed by 444 and 446 which match the
	# function's anAllPos[panList[i]] rationale exactly.
	#--> [ "*", "B", "*", "C", "A", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
