# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #444.
#ERR Error (R3) : Calling Function without definition: replacenextnthoccurrences

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	ReplaceNextNthOccurrences([1, 2], :of = "A", :with = "*",  :StartingAt = 3)
	? @@( Content() )
	#--> [ "A" , "B", "A", "C", "*", "D", "*" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? @@( NextNthOccurrencesReplaced([1, 2], :Of = "A", :With = "*",  :StartingAt = 3 ) )
	#--> [ "A", "B", "A", "C", "*", "D", "*" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
