# Narrative
# --------
# Test 3: Greedy vs Non-Greedy
#
# Extracted from stzRegexTest.ring, block #35.
#
# CORRECTED 2026-11-12. Both blocks asserted #--> TRUE, and TRUE is the answer
# whichever way the greediness goes. So this test passed unchanged over a library
# in which MatchSegmentsIn and MatchFirstSegmentIn were BYTE-IDENTICAL and neither
# was lazy: the comments beside each call stated an intent the assertions could
# not see. The extent of the match is the whole question here, and a boolean
# cannot carry it, so the SPANS are asserted now.

load "../../stzBase.ring"


pr()

txt = "<div>First</div><div>Second</div>"

? len(txt)
#--> 33

# Matching all (greedy) with MatchSegmentsIn(): both divs

o1 = new stzRegex("<div>.*</div>")

? o1.MatchSegmentsIn(txt)
#--> TRUE

? o1.CapturedLength()
#--> 33

# Matching one (non-greedy) with MatchFirstSegmentIn(): the first div only

o2 = new stzRegex("<div>.*</div>")

? o2.MatchFirstSegmentIn(txt)
#--> TRUE

? o2.CapturedLength()
#--> 16

# MatchOneSegment() is the name SCOPE_ORIENTED_PROGRAMMING.md and the regex
# deepdive give this act. It is the same call.

o3 = new stzRegex("<div>.*</div>")

? o3.MatchOneSegment(txt)
#--> TRUE

? o3.CapturedLength()
#--> 16

prf()

pf()
