# Narrative
# --------
# Test 2: Line Matching
#
# Extracted from stzRegexTest.ring, block #34.

load "../../stzBase.ring"


pr()

txt = "First: Line1
Second: Line2
Third: Line3"

o1 = new stzRegex("^Second:.*$")

# Line matching with MatchLinesIn()

? o1.MatchLinesIn(txt)  # Or simly MatchLine(txt)
#--> TRUE

prf()

pf()
# Executed in 0.01 second(s) in Ring 1.22
