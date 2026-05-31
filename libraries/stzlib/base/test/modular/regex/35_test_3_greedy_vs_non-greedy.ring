# Narrative
# --------
# Test 3: Greedy vs Non-Greedy
#
# Extracted from stzRegexTest.ring, block #35.

load "../../../stzBase.ring"


pr()

txt = "<div>First</div><div>Second</div>"

o1 = new stzRegex("<div>.*</div>")

# Matching all (greedy) with MatchSegmentsIn()

? o1.MatchSegmentsIn(txt) # matches both divs
#--> TRUE

# Matching first (non-greedy) with MatchFirstSegmentIn()

? o1.MatchFirstSegmentIn(txt) # matches first div
#--> TRUE

prf()
# Executed in 0.02 second(s) in Ring 1.22
