# Narrative
# --------
# Matching nested HTML tags
#
# Extracted from stzRegexTest.ring, block #13.

load "../../stzBase.ring"


pr()

rx("<([^>]+)>(?R)*") { ? MatchRecursive("<div><b>HELLO</b></div>") }
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
