# Narrative
# --------
# Partial Match: Processing streaming data
#
# Extracted from stzRegexTest.ring, block #7.

load "../../stzBase.ring"


pr()

o1 = new stzRegex("\d{2}:\d{2}:\d{2}")  # Time format

? o1.IsPartialMatch("12")		#--> TRUE
? o1.IsPartialMatch("12:")		#--> TRUE
? o1.IsPartialMatch("12:34")		#--> TRUE
? o1.IsPartialMatch("12:34:")		#--> TRUE
# ...and the last one is COMPLETE, so it is not PARTIAL. The class draws
# the distinction deliberately: IsPartialMatch() answers "partial and
# not complete", MatchInProgress() answers "still viable", and
# IsCompleteMatch() answers the other end. This file is about streaming,
# so it wants the viability question -- both are shown.
? o1.IsPartialMatch("12:34:56")		#--> FALSE
? o1.IsCompleteMatch("12:34:56")	#--> TRUE
? o1.MatchInProgress("12:34:56")	#--> TRUE

# The negative sibling: something that can never become a time.
? o1.IsPartialMatch("ab")		#--> FALSE
? o1.MatchInProgress("ab")		#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
