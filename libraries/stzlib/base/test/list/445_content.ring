# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #445.
#ERR Error (R3) : Calling Function without definition: replacepreviousnthoccurrencesst

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
	#--> [ "*" , "B", "*", "C", "A", "D", "A" ]
}

pf()
# Executed in 0.01 second(s).
