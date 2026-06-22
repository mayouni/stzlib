# Narrative
# --------
# Replacing the Nth matching item counted forward from a start position.
#
# ReplaceNextNthOccurrenceST(N, :Of = value, :With = repl, :StartingAt = pos)
# scans the list from position pos onward, counts occurrences of the target
# value, and rewrites only the Nth one it finds. Here the list ["A","B","C",
# "A","D","A"] has "A" at positions 1, 4 and 6. Starting at position 2 the
# scan ignores the leading "A" at 1; the first match found is position 4, the
# second is position 6, so the 2nd next occurrence (position 6) becomes "*".
# This is the position-anchored sibling of the plain occurrence replacers,
# letting you target a match relative to where you begin looking.
#
# Extracted from stzlisttest.ring, block #439.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "C", "A", "D", "A" ]) {
	ReplaceNextNthOccurrenceST(2, :Of = "A", :With = "*", :StartingAt = 2 )
	? Content()
	#--> [ "A", "B", "C", "A", "D", "*" ]
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
