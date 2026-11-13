# Narrative
# --------
# Test 4: Line boundaries
#
# Extracted from stzRegexTest.ring, block #31.

load "../../stzBase.ring"


pr()

txt = "Start: Line1
End: Line2"

# 2026-11-13: was new stzRegex(""), which the constructor refuses, so nothing in
# this file ran and its promises were being charged as divergences.
o = new stzRegex("^End:.*$")
o.SetPattern("^End:.*$") # ^ only matches start of string

# Without MultiLine

? o.MatchXT(txt, 1, :MatchEntireContent, [])
#--> FALSE

# With MultiLine: now ^ matches start of any line

? o.MatchXT(txt, 1, :MatchEntireContent, [ :MultiLine ])
#--> TRUE

prf()

pf()
# Executed in almost 0 second(s) in Ring 1.22
